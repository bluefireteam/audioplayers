/// Indicates the state of the audio player.
enum PlayerState {
  /// initial state, stop has been called or an error occurred.
  stopped,

  /// Currently playing audio.
  playing,

  /// Pause has been called.
  paused,

  /// The audio successfully completed (reached the end).
  completed,

  /// The player has been disposed and should not be used anymore.
  disposed,
}
