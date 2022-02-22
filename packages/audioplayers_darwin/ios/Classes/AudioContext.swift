import MediaPlayer

struct AudioContext : Equatable {
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
    
    static func ==(o1: AudioContext, o2: AudioContext) -> Bool {
        return o1.defaultToSpeaker == o2.defaultToSpeaker && o1.category == o2.category && o1.options == o2.options
    }
}
