import AVKit

private let defaultPlaybackRate: Double = 1.0
private let defaultVolume: Double = 1.0
private let defaultLooping: Bool = false

typealias Completer = () -> Void
typealias CompleterError = () -> Void

class WrappedMediaPlayer {
    private(set) var eventHandler: AudioPlayersStreamHandler
    private(set) var isPlaying: Bool
    var looping: Bool

    private var reference: SwiftAudioplayersDarwinPlugin
    private var player: AVPlayer?
    private var playbackRate: Double
    private var volume: Double
    private var url: String?

    private var observers: [TimeObserver]
    private var playerItemStatusObservation: NSKeyValueObservation?

    init(
        reference: SwiftAudioplayersDarwinPlugin,
        eventHandler: AudioPlayersStreamHandler,
        player: AVPlayer? = nil,
        playbackRate: Double = defaultPlaybackRate,
        volume: Double = defaultVolume,
        looping: Bool = defaultLooping,
        url: String? = nil
    ) {
        self.reference = reference
        self.eventHandler = eventHandler
        self.player = player
        self.observers = []
        self.playerItemStatusObservation = nil

        self.isPlaying = false
        self.playbackRate = playbackRate
        self.volume = volume
        self.looping = looping
        self.url = url
    }

    func setSourceUrl (
        url: String,
        isLocal: Bool,
        completer: Completer? = nil,
        completerError: CompleterError? = nil
    ) {
        let playbackStatus = player?.currentItem?.status

        if self.url != url || playbackStatus == .failed || playbackStatus == nil {
            reset()
            self.url = url
            let playerItem = createPlayerItem(url, isLocal)
            setupPlayerItemStatusObservation(playerItem, completer, completerError)
            let player = updatePlayer(playerItem) ?? createPlayer(playerItem)
            setupPositionObserver(player)
            setupSoundCompletedObserver(player, playerItem)
        } else {
            if playbackStatus == .readyToPlay {
                completer?()
            }
        }
    }

    func getDuration() -> Int? {
        guard let duration = getDurationCMTime() else {
            return nil
        }
        return fromCMTime(time: duration)
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
        if let player = self.player {
            configParameters(player: player)
            if #available(iOS 10.0, macOS 10.12, *) {
                player.playImmediately(atRate: Float(playbackRate))
            } else {
                player.play()
            }
            updateDuration()
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

    func seek(time: CMTime, completer: Completer? = nil) {
        guard let currentItem = player?.currentItem else {
            completer?()
            return
        }
        currentItem.seek(to: time) {
            finished in
            if !self.isPlaying {
                self.player?.pause()
            }
            self.eventHandler.onSeekComplete()
            if (finished) {
                completer?()
            }
        }
    }

    func stop(completer: Completer? = nil) {
        pause()
        seek(time: toCMTime(millis: 0), completer: completer)
    }

    func release(completer: Completer? = nil) {
        stop {
            self.reset()
            completer?()
        }
    }

    func dispose(completer: Completer? = nil) {
        release {
            completer?()
        }
    }

    private func getDurationCMTime() -> CMTime? {
        return player?.currentItem?.asset.duration
    }

    private func getCurrentCMTime() -> CMTime? {
        return player?.currentTime()
    }

    private func createPlayerItem(_ url: String, _ isLocal: Bool) -> AVPlayerItem {
        let parsedUrl = isLocal ? URL.init(fileURLWithPath: url.deletingPrefix("file://")) : URL.init(string: url)!
        let playerItem = AVPlayerItem.init(url: parsedUrl)
        playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithm.timeDomain
        return playerItem
    }

    private func createPlayer( _ playerItem: AVPlayerItem) -> AVPlayer {
        let player = AVPlayer.init(playerItem: playerItem)
        configParameters(player: player)
        self.player = player
        return player
    }

    private func updatePlayer( _ playerItem: AVPlayerItem) -> AVPlayer? {
        if let player = self.player {
            player.replaceCurrentItem(with: playerItem)
        }

        return self.player
    }

    private func setupPlayerItemStatusObservation(_ playerItem: AVPlayerItem, _ completer: Completer?, _ completerError: CompleterError?) {
        playerItemStatusObservation = playerItem.observe(\AVPlayerItem.status) { (playerItem, change) in
            let status = playerItem.status
            self.eventHandler.onLog(message: "player status: \(status), change: \(change)")

            switch playerItem.status {
            case .readyToPlay:
                self.updateDuration()
                completer?()
            case .failed:
                self.eventHandler.onLog(message: "error: \(String(describing: playerItem.error))")
                self.reset()
                completerError?()
            default:
                break
            }
        }
    }

    private func setupPositionObserver(_ player: AVPlayer) {
        let interval = toCMTime(millis: 200)
        let observer = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) {
            [weak self] time in
            self?.onTimeInterval(time: time)
        }
        self.observers.append(TimeObserver(player: player, observer: observer))
    }

    private func setupSoundCompletedObserver(_ player: AVPlayer, _ playerItem: AVPlayerItem) {
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: nil
        ) {
            [weak self] (notification) in
            self?.onSoundComplete()
        }
        self.observers.append(TimeObserver(player: player, observer: observer))
    }

    private func configParameters(player: AVPlayer) {
        if (isPlaying) {
            player.volume = Float(volume)
            player.rate = Float(playbackRate)
        }
    }

    private func reset() {
        playerItemStatusObservation?.invalidate()
        playerItemStatusObservation = nil
        for observer in observers {
            NotificationCenter.default.removeObserver(observer.observer)
        }
        observers = []
        player?.replaceCurrentItem(with: nil)
    }

    private func updateDuration() {
        guard let duration = player?.currentItem?.asset.duration else {
            return
        }
        if CMTimeGetSeconds(duration) > 0 {
            let millis = fromCMTime(time: duration)
            eventHandler.onDuration(millis: millis)
        }
    }

    private func onSoundComplete() {
        if !isPlaying {
            return
        }

        seek(time: toCMTime(millis: 0)) {
            if self.looping {
                self.resume()
            } else {
                self.isPlaying = false
            }
        }

        reference.controlAudioSession()
        eventHandler.onComplete()
    }

    private func onTimeInterval(time: CMTime) {
        let millis = fromCMTime(time: time)
        eventHandler.onCurrentPosition(millis: millis)
    }
}
