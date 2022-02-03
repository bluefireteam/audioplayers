package xyz.luan.audioplayers

import android.content.Context
import android.os.Build
import android.os.Handler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import xyz.luan.audioplayers.player.WrappedPlayer
import xyz.luan.audioplayers.source.BytesSource
import xyz.luan.audioplayers.source.UrlSource
import java.lang.ref.WeakReference
import java.util.*

typealias FlutterHandler = (call: MethodCall, response: MethodChannel.Result) -> Unit

class AudioplayersPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var globalChannel: MethodChannel
    private lateinit var context: Context

    private val players = mutableMapOf<String, WrappedPlayer>()
    private val handler = Handler()
    private var positionUpdates: Runnable? = null

    private var defaultAudioContext = AudioContextAndroid()

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers")
        channel.setMethodCallHandler { call, response -> safeCall(call, response, ::handler) }
        globalChannel = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers.global")
        globalChannel.setMethodCallHandler { call, response -> safeCall(call, response, ::globalHandler) }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        stopPositionUpdates()
        players.values.forEach { it.release() }
        players.clear()
    }

    private fun safeCall(
        call: MethodCall,
        response: MethodChannel.Result,
        handler: FlutterHandler,
    ) {
        try {
            handler(call, response)
        } catch (e: Exception) {
            Logger.error("Unexpected error!", e)
            response.error("Unexpected error!", e.message, e)
        }
    }

    private fun globalHandler(call: MethodCall, response: MethodChannel.Result) {
        when (call.method) {
            "changeLogLevel" -> {
                val value = call.enumArgument<LogLevel>("value") ?: error("value is required")
                Logger.logLevel = value
            }
            "setGlobalAudioContext" -> {
                defaultAudioContext = call.audioContext()
            }
        }

        response.success(1)
    }

    private fun handler(call: MethodCall, response: MethodChannel.Result) {
        val playerId = call.argument<String>("playerId") ?: return
        val player = getPlayer(playerId)
        when (call.method) {
            "setSourceUrl" -> {
                val url = call.argument<String>("url") ?: error("url is required")
                val isLocal = call.argument<Boolean>("isLocal") ?: false
                player.source = UrlSource(url, isLocal)
            }
            "setSourceBytes" -> {
                val bytes = call.argument<ByteArray>("bytes") ?: error("bytes are required")
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                    error("Operation not supported on Android <= M")
                }
                player.source = BytesSource(bytes)
            }
            "resume" -> player.play()
            "pause" -> player.pause()
            "stop" -> player.stop()
            "release" -> player.release()
            "seek" -> {
                val position = call.argument<Int>("position") ?: error("position is required")
                player.seek(position)
            }
            "setVolume" -> {
                val volume = call.argument<Double>("volume") ?: error("volume is required")
                player.volume = volume.toFloat()
            }
            "setPlaybackRate" -> {
                val rate = call.argument<Double>("playbackRate") ?: error("playbackRate is required")
                player.rate = rate.toFloat()
            }
            "getDuration" -> {
                response.success(player.getDuration() ?: 0)
                return
            }
            "getCurrentPosition" -> {
                response.success(player.getCurrentPosition() ?: 0)
                return
            }
            "setReleaseMode" -> {
                val releaseMode = call.enumArgument<ReleaseMode>("releaseMode")
                    ?: error("releaseMode is required")
                player.releaseMode = releaseMode
            }
            "setPlayerMode" -> {
                val playerMode = call.enumArgument<PlayerMode>("playerMode")
                    ?: error("playerMode is required")
                player.playerMode = playerMode
            }
            "setAudioContext" -> {
                val audioContext = call.audioContext()
                player.updateAudioContext(audioContext)
            }
            else -> {
                response.notImplemented()
                return
            }
        }
        response.success(1)
    }

    private fun getPlayer(playerId: String): WrappedPlayer {
        return players.getOrPut(playerId) {
            WrappedPlayer(this, playerId, defaultAudioContext.copy())
        }
    }

    fun getApplicationContext(): Context {
        return context.applicationContext
    }

    fun handleIsPlaying() {
        startPositionUpdates()
    }

    fun handleDuration(player: WrappedPlayer) {
        channel.invokeMethod("audio.onDuration", buildArguments(player.playerId, player.getDuration() ?: 0))
    }

    fun handleComplete(player: WrappedPlayer) {
        channel.invokeMethod("audio.onComplete", buildArguments(player.playerId))
    }

    fun handleError(player: WrappedPlayer, message: String) {
        channel.invokeMethod("audio.onError", buildArguments(player.playerId, message))
    }

    fun handleSeekComplete(player: WrappedPlayer) {
        channel.invokeMethod("audio.onSeekComplete", buildArguments(player.playerId))
    }

    private fun startPositionUpdates() {
        if (positionUpdates != null) {
            return
        }
        positionUpdates = UpdateCallback(players, channel, handler, this).also {
            handler.post(it)
        }
    }

    private fun stopPositionUpdates() {
        positionUpdates = null
        handler.removeCallbacksAndMessages(null)
    }

    private class UpdateCallback(
        mediaPlayers: Map<String, WrappedPlayer>,
        channel: MethodChannel,
        handler: Handler,
        audioplayersPlugin: AudioplayersPlugin,
    ) : Runnable {
        private val mediaPlayers = WeakReference(mediaPlayers)
        private val channel = WeakReference(channel)
        private val handler = WeakReference(handler)
        private val audioplayersPlugin = WeakReference(audioplayersPlugin)

        override fun run() {
            val mediaPlayers = mediaPlayers.get()
            val channel = channel.get()
            val handler = handler.get()
            val audioplayersPlugin = audioplayersPlugin.get()
            if (mediaPlayers == null || channel == null || handler == null || audioplayersPlugin == null) {
                audioplayersPlugin?.stopPositionUpdates()
                return
            }
            var nonePlaying = true
            for (player in mediaPlayers.values) {
                if (!player.isActuallyPlaying()) {
                    continue
                }
                nonePlaying = false
                val key = player.playerId
                val duration = player.getDuration()
                val time = player.getCurrentPosition()
                channel.invokeMethod("audio.onDuration", buildArguments(key, duration ?: 0))
                channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time ?: 0))
            }
            if (nonePlaying) {
                audioplayersPlugin.stopPositionUpdates()
            } else {
                handler.postDelayed(this, 200)
            }
        }

    }

    companion object {
        private fun buildArguments(playerId: String, value: Any? = null): Map<String, Any> {
            return listOfNotNull(
                "playerId" to playerId,
                value?.let { "value" to it },
            ).toMap()
        }
    }
}

private inline fun <reified T : Enum<T>> MethodCall.enumArgument(name: String): T? {
    val enumName = argument<String>(name) ?: return null
    return enumValueOf<T>(enumName.split('.').last().toUpperCase(Locale.ROOT))
}

private fun MethodCall.audioContext(): AudioContextAndroid  {
    return AudioContextAndroid(
        isSpeakerphoneOn = argument<Boolean>("isSpeakerphoneOn") ?: error("isSpeakerphoneOn is required"),
        stayAwake = argument<Boolean>("stayAwake") ?: error("stayAwake is required"),
        contentType = argument<Int>("contentType") ?: error("contentType is required"),
        usageType = argument<Int>("usageType") ?: error("usageType is required"),
        audioFocus = argument<Int>("audioFocus"),
    )
}
