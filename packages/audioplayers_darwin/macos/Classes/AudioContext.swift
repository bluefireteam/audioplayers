import MediaPlayer

// no-op impl of AudioContext for macos
struct AudioContext {
  func activateAudioSession(active: Bool) throws {
  }

  func apply() throws {
    throw AudioPlayerError.warning("AudioContext configuration is not available on macOS")
  }

  static func parse(args: [String: Any]) throws -> AudioContext? {
    return AudioContext()
  }
}
