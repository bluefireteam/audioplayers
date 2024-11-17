package xyz.luan.audioplayers.player

import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import androidx.annotation.RequiresApi
import xyz.luan.audioplayers.AudioContextAndroid

class FocusManager(
    private val player: WrappedPlayer,
) {
    private var audioFocusChangeListener: AudioManager.OnAudioFocusChangeListener? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    private val context: AudioContextAndroid
        get() = player.context

    private val audioManager: AudioManager
        get() = player.audioManager

    fun maybeRequestAudioFocus(onGranted: () -> Unit, onLoss: (isTransient: Boolean) -> Unit) {
        if (context.audioFocus == AudioManager.AUDIOFOCUS_NONE) {
            onGranted()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            newRequestAudioFocus(onGranted, onLoss)
        } else {
            @Suppress("DEPRECATION")
            oldRequestAudioFocus(onGranted, onLoss)
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

    @RequiresApi(Build.VERSION_CODES.O)
    private fun newRequestAudioFocus(onGranted: () -> Unit, onLoss: (isTransient: Boolean) -> Unit) {
        val audioFocus = context.audioFocus

        // Listen also for focus changes, e.g. if interrupt playing with a phone call and resume afterward. 
        val audioFocusRequest = AudioFocusRequest.Builder(audioFocus)
            .setAudioAttributes(context.buildAttributes())
            .setOnAudioFocusChangeListener { handleFocusResult(it, onGranted, onLoss) }
            .build()
        this.audioFocusRequest = audioFocusRequest

        val result = audioManager.requestAudioFocus(audioFocusRequest)
        handleFocusResult(result, onGranted, onLoss)
    }

    @Deprecated("Use requestAudioFocus instead")
    private fun oldRequestAudioFocus(onGranted: () -> Unit, onLoss: (isTransient: Boolean) -> Unit) {
        val audioFocus = context.audioFocus
        audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { handleFocusResult(it, onGranted, onLoss) }
        @Suppress("DEPRECATION")
        val result = audioManager.requestAudioFocus(
            audioFocusChangeListener,
            AudioManager.STREAM_MUSIC,
            audioFocus,
        )
        handleFocusResult(result, onGranted, onLoss)
    }

    private fun handleFocusResult(result: Int, onGranted: () -> Unit, onLoss: (isTransient: Boolean) -> Unit) {
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
