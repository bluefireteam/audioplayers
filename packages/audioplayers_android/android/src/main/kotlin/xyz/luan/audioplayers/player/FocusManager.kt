package xyz.luan.audioplayers.player

import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import xyz.luan.audioplayers.AudioContextAndroid

class FocusManager(
    private val player: WrappedPlayer,
    private val onGranted: () -> Unit,
    private val onLoss: (isTransient: Boolean) -> Unit
) {
    private val context: AudioContextAndroid
        get() = player.context


    // Listen also for focus changes, e.g. if interrupt playing with a phone call and resume afterward.
    private var audioFocusRequest: AudioFocusRequest? = null
    
    // Deprecated variant for listenfixing to focus changes
    private var audioFocusChangeListener: AudioManager.OnAudioFocusChangeListener? = null
    
    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest = AudioFocusRequest.Builder(context.audioFocus)
                .setAudioAttributes(context.buildAttributes())
                .setOnAudioFocusChangeListener { handleFocusResult(it) }
                .build()
        } else {
            audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { handleFocusResult(it) }
        }
    }

    private val audioManager: AudioManager
        get() = player.audioManager

    fun maybeRequestAudioFocus() {
        if (context.audioFocus == AudioManager.AUDIOFOCUS_NONE) {
            onGranted()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val result = audioManager.requestAudioFocus(audioFocusRequest!!)
            handleFocusResult(result)
        } else {
            @Suppress("DEPRECATION")
            val result = audioManager.requestAudioFocus(
                audioFocusChangeListener,
                AudioManager.STREAM_MUSIC,
                context.audioFocus,
            )
            handleFocusResult(result)
        }
    }

    fun handleStop() {
        if (context.audioFocus != AudioManager.AUDIOFOCUS_NONE) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager.abandonAudioFocus(audioFocusChangeListener)
            }
        }
    }

    private fun handleFocusResult(result: Int) {
        when (result) {
            AudioManager.AUDIOFOCUS_REQUEST_GRANTED -> {
                onGranted()
            }

            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                onLoss(true)
            }

            AudioManager.AUDIOFOCUS_LOSS -> {
                onLoss(false)
            }
        }
        // Keep playing source on `AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK` as sound is ducked.
    }
}
