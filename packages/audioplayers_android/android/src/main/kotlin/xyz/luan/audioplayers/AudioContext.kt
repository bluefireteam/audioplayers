package xyz.luan.audioplayers

import android.annotation.SuppressLint
import android.media.AudioAttributes
import android.media.AudioAttributes.*
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import androidx.annotation.RequiresApi
import java.util.Objects

data class AudioContextAndroid(
    val isSpeakerphoneOn: Boolean,
    val stayAwake: Boolean,
    val contentType: Int,
    val usageType: Int,
    val audioFocus: Int,
    val audioMode: Int,
) {
    @SuppressLint("InlinedApi") // we are just using numerical constants
    constructor() : this(
        isSpeakerphoneOn = true,
        stayAwake = false,
        contentType = CONTENT_TYPE_MUSIC,
        usageType = USAGE_MEDIA,
        audioFocus = AudioManager.AUDIOFOCUS_GAIN,
        audioMode = AudioManager.MODE_NORMAL,
    )

    fun setAttributesOnPlayer(player: MediaPlayer) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            player.setAudioAttributes(buildAttributes())
        } else {
            @Suppress("DEPRECATION")
            player.setAudioStreamType(getStreamType())
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun buildAttributes(): AudioAttributes {
        return Builder()
            .setUsage(usageType)
            .setContentType(contentType)
            .build()
    }

    @Deprecated("This is used for Android older than LOLLIPOP", replaceWith = ReplaceWith("buildAttributes"))
    private fun getStreamType(): Int {
        return when (usageType) {
            USAGE_VOICE_COMMUNICATION -> AudioManager.STREAM_VOICE_CALL
            USAGE_NOTIFICATION_RINGTONE -> AudioManager.STREAM_RING
            else -> AudioManager.STREAM_MUSIC
        }
    }

    override fun hashCode() = Objects.hash(isSpeakerphoneOn, stayAwake, contentType, usageType, audioFocus, audioMode)

    override fun equals(other: Any?) = (other is AudioContextAndroid)
            && isSpeakerphoneOn == other.isSpeakerphoneOn
            && stayAwake == other.stayAwake
            && contentType == other.contentType
            && usageType == other.usageType
            && audioFocus == other.audioFocus
            && audioMode == other.audioMode
}
