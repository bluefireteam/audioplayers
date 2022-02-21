import MediaPlayer

struct AudioContext {
    let category: AVAudioSession.Category
    let options: [AVAudioSession.CategoryOptions]
    let defaultToSpeaker: Bool
    
    init() {
        self.category = .playAndRecord
        self.options = [.mixWithOthers]
        self.defaultToSpeaker = false
    }
    
    init(
        category: AVAudioSession.Category,
        options: [AVAudioSession.CategoryOptions],
        defaultToSpeaker: Bool
    ) {
        self.category = category
        self.options = options
        self.defaultToSpeaker = defaultToSpeaker
    }
}
