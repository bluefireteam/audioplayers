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

    private lateinit var methods: MethodChannel
    private lateinit var globalMethods: MethodChannel
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
        methods = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers")
        methods.setMethodCallHandler { call, response -> safeCall(call, response, ::methodHandler) }
        globalMethods = MethodChannel(binding.binaryMessenger, "xyz.luan/audioplayers.global")
        globalMethods.setMethodCallHandler { call, response -> safeCall(call, response, ::globalMethodHandler) }
        updateRunnable = UpdateRunnable(players, methods, handler, this)
        globalEvents = EventHandler(EventChannel(binding.binaryMessenger, "xyz.luan/audioplayers.global/events"))
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        stopUpdates()
        handler.removeCallbacksAndMessages(null)
        updateRunnable = null
        players.values.forEach { it.dispose() }
        players.clear()
        mainScope.cancel()
        soundPoolManager.dispose()
        globalEvents.dispose()
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
                response.error("Unexpected AndroidAudioError", e.message, e)
            }
        }
    }

    private fun globalMethodHandler(call: MethodCall, response: MethodChannel.Result) {
        when (call.method) {
            "setAudioContext" -> {
                val audioManager = getAudioManager()
                audioManager.mode = defaultAudioContext.audioMode
                audioManager.isSpeakerphoneOn = defaultAudioContext.isSpeakerphoneOn

                defaultAudioContext = call.audioContext()
            }

            "emitLog" -> {
                val message = call.argument<String>("message") ?: error("message is required")
                handleGlobalLog(message)
            }

            "emitError" -> {
                val code = call.argument<String>("code") ?: error("code is required")
                val message = call.argument<String>("message") ?: error("message is required")
                handleGlobalError(code, message, null)
            }

            else -> {
                response.notImplemented()
                return
            }
        }

        response.success(1)
    }

    private fun methodHandler(call: MethodCall, response: MethodChannel.Result) {
        val playerId = call.argument<String>("playerId") ?: return
        if (call.method == "create") {
            val eventHandler = EventHandler(EventChannel(binaryMessenger, "xyz.luan/audioplayers/events/$playerId"))
            players[playerId] = WrappedPlayer(this, eventHandler, defaultAudioContext.copy(), soundPoolManager)
            response.success(1)
            return
        }
        val player = getPlayer(playerId)
        try {
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

                "setBalance" -> {
                    val balance = call.argument<Double>("balance") ?: error("balance is required")
                    player.balance = balance.toFloat()
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

                "emitLog" -> {
                    val message = call.argument<String>("message") ?: error("message is required")
                    player.handleLog(message)
                }

                "emitError" -> {
                    val code = call.argument<String>("code") ?: error("code is required")
                    val message = call.argument<String>("message") ?: error("message is required")
                    player.handleError(code, message, null)
                }

                "dispose" -> {
                    handler.post {
                        player.dispose()
                        players.remove(playerId)
                    }
                }

                else -> {
                    response.notImplemented()
                    return
                }
            }
            response.success(1)
        } catch (e: Exception) {
            response.error("AndroidAudioError", e.message, e)
        }
    }

    private fun getPlayer(playerId: String): WrappedPlayer {
        return players[playerId] ?: error("Player has not yet been created or has already been disposed.")
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
        handler.post {
            player.eventHandler.success(
                "audio.onDuration",
                hashMapOf("value" to (player.getDuration() ?: 0))
            )
        }
    }

    fun handleComplete(player: WrappedPlayer) {
        handler.post { player.eventHandler.success("audio.onComplete") }
    }

    fun handlePrepared(player: WrappedPlayer, isPrepared: Boolean) {
        handler.post { player.eventHandler.success("audio.onPrepared", hashMapOf("value" to isPrepared)) }
    }

    fun handleLog(player: WrappedPlayer, message: String) {
        handler.post { player.eventHandler.success("audio.onLog", hashMapOf("value" to message)) }
    }

    fun handleGlobalLog(message: String) {
        handler.post { globalEvents.success("audio.onLog", hashMapOf("value" to message)) }
    }

    fun handleError(player: WrappedPlayer, errorCode: String?, errorMessage: String?, errorDetails: Any?) {
        handler.post { player.eventHandler.error(errorCode, errorMessage, errorDetails) }
    }

    fun handleGlobalError(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
        handler.post { globalEvents.error(errorCode, errorMessage, errorDetails) }
    }

    fun handleSeekComplete(player: WrappedPlayer) {
        handler.post {
            player.eventHandler.success("audio.onSeekComplete")
            player.eventHandler.success(
                "audio.onCurrentPosition", hashMapOf("value" to (player.getCurrentPosition() ?: 0))
            )
        }
    }

    override fun startUpdates() {
        updateRunnable?.let { handler.post(it) }
    }

    override fun stopUpdates() {
        updateRunnable?.let { handler.removeCallbacks(it) }
    }

    private class UpdateRunnable(
        mediaPlayers: ConcurrentMap<String, WrappedPlayer>,
        methodChannel: MethodChannel,
        handler: Handler,
        updateCallback: IUpdateCallback,
    ) : Runnable {
        private val mediaPlayers = WeakReference(mediaPlayers)
        private val methodChannel = WeakReference(methodChannel)
        private val handler = WeakReference(handler)
        private val updateCallback = WeakReference(updateCallback)

        override fun run() {
            val mediaPlayers = mediaPlayers.get()
            val channel = methodChannel.get()
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
                val time = player.getCurrentPosition()
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
        audioFocus = argument<Int>("audioFocus") ?: error("audioFocus is required"),
        audioMode = argument<Int>("audioMode") ?: error("audioMode is required"),
    )
}

class EventHandler(private val eventChannel: EventChannel) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    init {
        eventChannel.setStreamHandler(this)
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

    fun dispose() {
        eventSink?.let {
            it.endOfStream()
            onCancel(null)
        }
        eventChannel.setStreamHandler(null)
    }
}
