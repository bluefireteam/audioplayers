import AVKit

private let defaultPlaybackRate: Double = 1.0
private let defaultVolume: Double = 1.0
private let defaultLooping: Bool = false

class WrappedMediaPlayer {
    var reference: SwiftAudioplayersDarwinPlugin
    
    var playerId: String
    var player: AVPlayer?
    
    var observers: [TimeObserver]
    var keyValueObservation: NSKeyValueObservation?
    
    var isPlaying: Bool
    var playbackRate: Double
    var volume: Double
    var looping: Bool

    var url: String?
    var onReady: ((AVPlayer) -> Void)?
    
    init(
        reference: SwiftAudioplayersDarwinPlugin,
        playerId: String,
        player: AVPlayer? = nil,
        playbackRate: Double = defaultPlaybackRate,
        volume: Double = defaultVolume,
        looping: Bool = defaultLooping,
        url: String? = nil,
        onReady: ((AVPlayer) -> Void)? = nil
    ) {
        self.reference = reference
        self.playerId = playerId
        self.player = player
        self.observers = []
        self.keyValueObservation = nil
        
        self.isPlaying = false
        self.playbackRate = playbackRate
        self.volume = volume
        self.looping = looping
        self.url = url
        self.onReady = onReady
    }
    
    func dispose() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer.observer)
        }
        keyValueObservation?.invalidate()
        observers = []
    }
    
    func getDurationCMTime() -> CMTime? {
        guard let currentItem = player?.currentItem else {
            return nil
        }
        
        return currentItem.asset.duration
    }
    
    func getDuration() -> Int? {
        guard let duration = getDurationCMTime() else {
            return nil
        }
        return fromCMTime(time: duration)
    }
    
    private func getCurrentCMTime() -> CMTime? {
        guard let player = player else {
            return nil
        }
        return player.currentTime()
    }
    
    func getCurrentPosition() -> Int? {
        guard let time = getCurrentCMTime() else {
            return nil
        }
        return fromCMTime(time: time)
    }
    
    func pause() {
        isPlaying = false
        player?.pause()
    }
    
    func resume() {
        isPlaying = true
        if #available(iOS 10.0, macOS 10.12, *) {
            player?.playImmediately(atRate: Float(playbackRate))
        } else {
            player?.play()
        }
    }
    
    func setVolume(volume: Double) {
        self.volume = volume
        player?.volume = Float(volume)
    }
    
    func setPlaybackRate(playbackRate: Double) {
        self.playbackRate = playbackRate
        player?.rate = Float(playbackRate)
    }
    
    func seek(time: CMTime) {
        guard let currentItem = player?.currentItem else {
            return
        }
        currentItem.seek(to: time) {
            finished in
            if !self.isPlaying {
                self.player?.pause()
            }
            self.reference.onSeekComplete(playerId: self.playerId, finished: finished)
        }
    }
    
    func skipForward(interval: TimeInterval) {
        guard let currentTime = getCurrentCMTime() else {
            Logger.error("Cannot skip forward, unable to determine currentTime")
            return
        }
        guard let maxDuration = getDurationCMTime() else {
            Logger.error("Cannot skip forward, unable to determine maxDuration")
            return
        }
        let newTime = CMTimeAdd(currentTime, toCMTime(millis: interval * 1000))
        // if CMTime is more than max duration, limit it
        let clampedTime = CMTimeGetSeconds(newTime) > CMTimeGetSeconds(maxDuration) ? maxDuration : newTime
        seek(time: clampedTime)
    }
    
    func skipBackward(interval: TimeInterval) {
        guard let currentTime = getCurrentCMTime() else {
            Logger.error("Cannot skip forward, unable to determine currentTime")
            return
        }
        let newTime = CMTimeSubtract(currentTime, toCMTime(millis: interval * 1000))
        // if CMTime is negative, set it to zero
        let clampedTime = CMTimeGetSeconds(newTime) < 0 ? toCMTime(millis: 0) : newTime
        seek(time: clampedTime)
    }
    
    func stop() {
        pause()
        seek(time: toCMTime(millis: 0))
    }
    
    func release() {
        stop()
        dispose()
    }
    
    func onSoundComplete() {
        if !isPlaying {
            return
        }
        
        pause()
        if looping {
            seek(time: toCMTime(millis: 0))
            resume()
        }
        
        reference.controlAudioSession()
        reference.onComplete(playerId: playerId)
    }
    
    func onTimeInterval(time: CMTime) {
        let millis = fromCMTime(time: time)
        reference.onCurrentPosition(playerId: playerId, millis: millis)
    }
    
    func updateDuration() {
        guard let duration = player?.currentItem?.asset.duration else {
            return
        }
        if CMTimeGetSeconds(duration) > 0 {
            let millis = fromCMTime(time: duration)
            reference.onDuration(playerId: playerId, millis: millis)
        }
    }
    
    func setSourceUrl(
        url: String,
        isLocal: Bool,
        onReady: @escaping (AVPlayer) -> Void
    ) {
        let playbackStatus = player?.currentItem?.status
        
        if self.url != url || playbackStatus == .failed || playbackStatus == nil {
            let parsedUrl = isLocal ? URL.init(fileURLWithPath: url.deletingPrefix("file://")) : URL.init(string: url)!
            let playerItem = AVPlayerItem.init(url: parsedUrl)
            playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithm.timeDomain
            let player: AVPlayer
            if let existingPlayer = self.player {
                keyValueObservation?.invalidate()
                self.url = url
                dispose()
                existingPlayer.replaceCurrentItem(with: playerItem)
                player = existingPlayer
            } else {
                player = AVPlayer.init(playerItem: playerItem)
                
                self.player = player
                self.observers = []
                self.url = url
                
                // stream player position
                let interval = toCMTime(millis: 0.2)
                let timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) {
                    [weak self] time in
                    self!.onTimeInterval(time: time)
                }
                self.observers.append(TimeObserver(player: player, observer: timeObserver))
            }
            
            let anObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: nil
            ) {
                [weak self] (notification) in
                self!.onSoundComplete()
            }
            self.observers.append(TimeObserver(player: player, observer: anObserver))
            
            // is sound ready
            self.onReady = onReady
            let newKeyValueObservation = playerItem.observe(\AVPlayerItem.status) { (playerItem, change) in
                let status = playerItem.status
                Logger.info("player status: %@ change: %@", status, change)
                
                // Do something with the status...
                if status == .readyToPlay {
                    self.updateDuration()
                    
                    if let onReady = self.onReady {
                        self.onReady = nil
                        onReady(self.player!)
                    }
                } else if status == .failed {
                    self.reference.onError(playerId: self.playerId)
                }
            }
            
            keyValueObservation?.invalidate()
            keyValueObservation = newKeyValueObservation
        } else {
            if playbackStatus == .readyToPlay {
                onReady(player!)
            }
        }
    }
}
