import MediaPlayer

// no-op impl of AudioContext for macos
struct AudioContext {
    func activateAudioSession(active: Bool) {}

    func apply() {
        // no-op on macOS
    }

    static func parse(args: [String: Any]) -> AudioContext? {
        return AudioContext()
    }
}
