import MediaPlayer
import audioplayers_darwin_common

// no-op impl of AudioContext for macos
public struct AudioContext {
  public func activateAudioSession(active: Bool) throws {
  }

  public func apply() throws {
    throw AudioPlayerError.warning("AudioContext configuration is not available on macOS")
  }

  public static func parse(args: [String: Any]) throws -> AudioContext? {
    return AudioContext()
  }
}
