import AVKit

func log(_ items: Any...) {
    let string: String
    if items.count == 1, let s = items.first as? String {
        string = s
    } else if items.count > 1, let format = items.first as? String, let arguments = Array(items[1..<items.count]) as? [CVarArg] {
        string = String(format: format, arguments: arguments)
    } else {
        string = ""
    }
    debugPrint(string)
}

func toCMTime(millis: Int) -> CMTime {
    return toCMTime(millis: Float(millis))
}

func toCMTime(millis: Double) -> CMTime {
    return toCMTime(millis: Float(millis))
}

func toCMTime(millis: Float) -> CMTime {
    return CMTimeMakeWithSeconds(Float64(millis) / 1000, preferredTimescale: Int32(NSEC_PER_SEC))
}

func fromCMTime(time: CMTime) -> Int {
    let seconds: Float64 = CMTimeGetSeconds(time)
    let milliseconds: Int = Int(seconds * 1000)
    return milliseconds
}

class TimeObserver {
    let player: AVPlayer
    let observer: Any
    
    init(
        player: AVPlayer,
        observer: Any
    ) {
        self.player = player
        self.observer = observer
    }
}
