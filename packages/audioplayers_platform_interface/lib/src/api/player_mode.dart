/// This represents what kind of native implementation is used by the player.
///
/// Currently, this distinction is only relevant for Android.
///
/// Only the deprecated `audioplayers_android` implementation, which is based on
/// the Android `MediaPlayer` and `SoundPool`, supports switching modes.
/// The default Android implementation `audioplayers_android_exo` always plays
/// in [mediaPlayer] mode.
@Deprecated(
  'Player modes are deprecated, as low latency mode is only supported by '
  'the deprecated `audioplayers_android` package. '
  'This will be removed in a future release.',
)
enum PlayerMode {
  /// Ideal for long media files or streams.
  mediaPlayer,

  /// Ideal for short audio files, since it reduces the impacts on visuals or
  /// UI performance.
  ///
  /// In this mode the backend won't fire any duration, position or playback
  /// completion events. This means you are responsible for stopping the player.
  /// Also, it is not possible to use the seek method to set the audio to a
  /// specific position.
  ///
  /// Only supported by the deprecated `audioplayers_android` implementation,
  /// which is based on the Android `SoundPool`.
  /// The default Android implementation `audioplayers_android_exo` does not
  /// support this mode and falls back to [mediaPlayer].
  lowLatency,
}
