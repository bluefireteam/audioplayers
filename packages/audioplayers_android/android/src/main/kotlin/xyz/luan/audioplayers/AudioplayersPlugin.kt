package xyz.luan.audioplayers


import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import xyz.luan.audioplayers.player.SoundPoolManager
import xyz.luan.audioplayers.player.WrappedPlayer
import xyz.luan.audioplayers.source.BytesSource
import xyz.luan.audioplayers.source.UrlSource
import java.lang.ref.WeakReference
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ConcurrentMap

typealias FlutterHandler = (call: MethodCall, response: MethodChannel.Result) -> Unit

class AudioplayersPlugin : FlutterPlugin, IUpdateCallback {
    private val mainScope = CoroutineScope(Dispatchers.Main)

    private lateinit var channel: MethodChannel
    private lateinit var globalChannel: MethodChannel
    private lateinit var globalEvents: EventHandler
    private lateinit var context: Context
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var soundPoolManager: SoundPoolManager

    private val players = ConcurrentHashMap<String, WrappedPlayer>()
    private val handler = Handler(Looper.getMainLooper())
    private var updateRunnable: Runnable? = null

    private var defaultAudioContext = AudioContextAndroid()

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        binaryMessenger = binding.binaryMessenger
        soundPoolManager = SoundPoolManager(this)
        channel = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers")
        channel.setMethodCallHandler { call, response -> safeCall(call, response, ::handler) }
        globalChannel = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers.global")
        globalChannel.setMethodCallHandler { call, response -> safeCall(call, response, ::globalHandler) }
        updateRunnable = UpdateRunnable(players, channel, handler, this)
        globalEvents = EventHandler(EventChannel(binding.binaryMessenger, "xyz.luan/audioplayers.global/events"))
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        stopUpdates()
        updateRunnable = null
        players.values.forEach { it.dispose() }
        players.clear()
        mainScope.cancel()
        soundPoolManager.dispose()
        globalEvents.endOfStream()
    }

    private fun safeCall(
        call: MethodCall,
        response: MethodChannel.Result,
        handler: FlutterHandler,
    ) {
        mainScope.launch(Dispatchers.IO) {
            try {
                handler(call, response)
            } catch (e: Exception) {
                handleGlobalError(e)
                response.error("Unexpected error!", e.message, e)
            }
        }
    }

    private fun globalHandler(call: MethodCall, response: MethodChannel.Result) {
        when (call.method) {
            "setGlobalAudioContext" -> {
                val audioManager = getAudioManager()
                audioManager.mode = defaultAudioContext.audioMode
                audioManager.isSpeakerphoneOn = defaultAudioContext.isSpeakerphoneOn

                defaultAudioContext = call.audioContext()
            }
        }

        response.success(1)
    }

    private fun handler(call: MethodCall, response: MethodChannel.Result) {
        val playerId = call.argument<String>("playerId") ?: return
        if (call.method == "create") {
            val eventHandler = EventHandler(EventChannel(binaryMessenger, "xyz.luan/audioplayers/events/$playerId"))
            players[playerId] =
                WrappedPlayer(this, playerId, defaultAudioContext.copy(), eventHandler, soundPoolManager)
            response.success(1)
            return
        }
        val player = getPlayer(playerId)
        when (call.method) {
            "dispose" -> {
                player.dispose()
                players.remove(playerId)
            }

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

            "setBalance" -> {
                handleError(player, NotImplementedError("setBalance is not currently implemented on Android"))
                response.notImplemented()
                return
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
                val releaseMode = call.enumArgument<ReleaseMode>("releaseMode") ?: error("releaseMode is required")
                player.releaseMode = releaseMode
            }

            "setPlayerMode" -> {
                val playerMode = call.enumArgument<PlayerMode>("playerMode") ?: error("playerMode is required")
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
        return players[playerId] ?: error("Player with id $playerId was not created!")
    }

    fun getApplicationContext(): Context {
        return context.applicationContext
    }

    fun getAudioManager(): AudioManager {
        return context.applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    fun handleIsPlaying() {
        startUpdates()
    }

    fun handleDuration(player: WrappedPlayer) {
        player.eventHandler.success("audio.onDuration", hashMapOf("value" to (player.getDuration() ?: 0)))
    }

    fun handleComplete(player: WrappedPlayer) {
        player.eventHandler.success("audio.onComplete")
    }

    fun handleLog(player: WrappedPlayer, message: String) {
        handler.post { player.eventHandler.success("audio.onLog", hashMapOf("value" to message)) }
    }

    fun handleGlobalLog(message: String) {
        handler.post { globalEvents.success("audio.onGlobalLog", hashMapOf("value" to message)) }
    }

    fun handleError(player: WrappedPlayer, error: Throwable) {
        handler.post { player.eventHandler.error(error.javaClass.name, error.message, error.stackTraceToString()) }
    }

    fun handleGlobalError(error: Throwable) {
        handler.post { globalEvents.error(error.javaClass.name, error.message, error.stackTraceToString()) }
    }

    fun handleSeekComplete(player: WrappedPlayer) {
        player.eventHandler.success("audio.onSeekComplete")
        player.eventHandler.success(
            "audio.onCurrentPosition", hashMapOf("value" to (player.getCurrentPosition() ?: 0))
        )
    }

    override fun startUpdates() {
        updateRunnable?.let { handler.post(it) }
    }

    override fun stopUpdates() {
        handler.removeCallbacksAndMessages(null)
    }

    private class UpdateRunnable(
        mediaPlayers: ConcurrentMap<String, WrappedPlayer>,
        channel: MethodChannel,
        handler: Handler,
        updateCallback: IUpdateCallback,
    ) : Runnable {
        private val mediaPlayers = WeakReference(mediaPlayers)
        private val channel = WeakReference(channel)
        private val handler = WeakReference(handler)
        private val updateCallback = WeakReference(updateCallback)

        override fun run() {
            val mediaPlayers = mediaPlayers.get()
            val channel = channel.get()
            val handler = handler.get()
            val updateCallback = updateCallback.get()
            if (mediaPlayers == null || channel == null || handler == null || updateCallback == null) {
                updateCallback?.stopUpdates()
                return
            }
            var isAnyPlaying = false
            for (player in mediaPlayers.values) {
                if (!player.isActuallyPlaying()) {
                    continue
                }
                isAnyPlaying = true
                val duration = player.getDuration()
                val time = player.getCurrentPosition()
                player.eventHandler.success("audio.onDuration", hashMapOf("value" to (duration ?: 0)))
                player.eventHandler.success("audio.onCurrentPosition", hashMapOf("value" to (time ?: 0)))
            }
            if (isAnyPlaying) {
                handler.postDelayed(this, 200)
            } else {
                updateCallback.stopUpdates()
            }
        }
    }
}

private interface IUpdateCallback {
    fun stopUpdates()
    fun startUpdates()
}

private inline fun <reified T : Enum<T>> MethodCall.enumArgument(name: String): T? {
    val enumName = argument<String>(name) ?: return null
    return enumValueOf<T>(enumName.split('.').last().toConstantCase())
}

fun String.toConstantCase(): String {
    return replace(Regex("(.)(\\p{Upper})"), "$1_$2").replace(Regex("(.) (.)"), "$1_$2").uppercase()
}

private fun MethodCall.audioContext(): AudioContextAndroid {
    return AudioContextAndroid(
        isSpeakerphoneOn = argument<Boolean>("isSpeakerphoneOn") ?: error("isSpeakerphoneOn is required"),
        stayAwake = argument<Boolean>("stayAwake") ?: error("stayAwake is required"),
        contentType = argument<Int>("contentType") ?: error("contentType is required"),
        usageType = argument<Int>("usageType") ?: error("usageType is required"),
        audioFocus = argument<Int>("audioFocus"),
        audioMode = argument<Int>("audioMode") ?: error("audioMode is required"),
    )
}

class EventHandler(channel: EventChannel) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    init {
        channel.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun success(method: String, arguments: Map<String, Any> = HashMap()) {
        eventSink?.success(arguments + Pair("event", method))
    }

    fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
        eventSink?.error(errorCode, errorMessage, errorDetails)
    }

    fun endOfStream() {
        eventSink?.endOfStream()
    }
}
