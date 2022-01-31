package xyz.luan.audioplayers

data class AudioContextAndroid(
  val isSpeakerphoneOn: Boolean,
  val stayAwake: Boolean,
  val contentType: Int, 
  val usageType: Int,
  val audioFocus: Int?,
)