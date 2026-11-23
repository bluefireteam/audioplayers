import AVFoundation

/// Protocol for AVFoundation object instance factory. Used for injecting framework objects in
/// tests.
protocol WrappedAVObjectFactory {
  /// Creates and returns an AVPlayer instance.
  func player() -> AVPlayer
}

/// Default implementation of the WrappedAVObjectFactory protocol, using real AVFoundation objects.
class DefaultAVFactory: WrappedAVObjectFactory {
  func player() -> AVPlayer {
    return AVPlayer()
  }
}
