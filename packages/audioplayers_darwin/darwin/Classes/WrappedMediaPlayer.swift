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
  private var player: AVPlayer
  private var playbackRate: Double
  private var volume: Double
  private var url: String?

  private var positionObserver: TimeObserver!
  private var completionObserver: TimeObserver?
  private var playerItemStatusObservation: NSKeyValueObservation?

  init(
    reference: SwiftAudioplayersDarwinPlugin,
    eventHandler: AudioPlayersStreamHandler,
    player: AVPlayer = AVPlayer.init(),
    playbackRate: Double = defaultPlaybackRate,
    volume: Double = defaultVolume,
    looping: Bool = defaultLooping,
    url: String? = nil
  ) {
    self.reference = reference
    self.eventHandler = eventHandler
    self.player = player
    self.completionObserver = nil
    self.playerItemStatusObservation = nil

    self.isPlaying = false
    self.playbackRate = playbackRate
    self.volume = volume
    self.looping = looping
    self.url = url

    self.setUpPositionObserver(player)
  }

  func setSourceUrl(
    url: String,
    isLocal: Bool,
    completer: Completer? = nil,
    completerError: CompleterError? = nil
  ) {
    let playbackStatus = player.currentItem?.status

    if self.url != url || playbackStatus == .failed || playbackStatus == nil {
      reset()
      self.url = url
      do {
        let playerItem = try createPlayerItem(url, isLocal)
        // Need to observe item status immediately after creating:
        setUpPlayerItemStatusObservation(
          playerItem,
          completer: completer,
          completerError: completerError)
        // Replacing the player item triggers completion in setUpPlayerItemStatusObservation
        self.player.replaceCurrentItem(with: playerItem)
        self.setUpSoundCompletedObserver(self.player, playerItem)
      } catch {
        completerError?()
      }
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
    player.pause()
  }

  func resume() {
    isPlaying = true
    configParameters(player: player)
    if #available(iOS 10.0, macOS 10.12, *) {
      player.playImmediately(atRate: Float(playbackRate))
    } else {
      player.play()
    }
    updateDuration()
  }

  func setVolume(volume: Double) {
    self.volume = volume
    player.volume = Float(volume)
  }

  func setPlaybackRate(playbackRate: Double) {
    self.playbackRate = playbackRate
    if isPlaying {
      // Setting the rate causes the player to resume playing. So setting it only, when already playing.
      player.rate = Float(playbackRate)
    }
  }

  func seek(time: CMTime, completer: Completer? = nil) {
    guard let currentItem = player.currentItem else {
      completer?()
      return
    }
    currentItem.seek(to: time) {
      finished in
      if !self.isPlaying {
        self.player.pause()
      }
      self.eventHandler.onSeekComplete()
      if finished {
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
      self.url = nil
      completer?()
    }
  }

  func dispose(completer: Completer? = nil) {
    release {
      NotificationCenter.default.removeObserver(self.positionObserver.observer)
      completer?()
    }
  }

  private func getDurationCMTime() -> CMTime? {
    return player.currentItem?.asset.duration
  }

  private func getCurrentCMTime() -> CMTime? {
    return player.currentItem?.currentTime()
  }

  private func createPlayerItem(_ url: String, _ isLocal: Bool) throws -> AVPlayerItem {
    let tmpParsedUrl =
      isLocal ? URL.init(fileURLWithPath: url.deletingPrefix("file://")) : URL.init(string: url)
    if let parsedUrl = tmpParsedUrl {
      let playerItem = AVPlayerItem.init(url: parsedUrl)
      playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithm.timeDomain
      return playerItem
    } else {
      throw AudioPlayerError.error("Url not valid: \(url)")
    }
  }

  private func setUpPlayerItemStatusObservation(
    _ playerItem: AVPlayerItem,
    completer: Completer? = nil,
    completerError: CompleterError? = nil
  ) {
    playerItemStatusObservation = playerItem.observe(\AVPlayerItem.status) { (playerItem, change) in
      let status = playerItem.status
      self.eventHandler.onLog(message: "player status: \(status), change: \(change)")

      switch playerItem.status {
      case .readyToPlay:
        self.updateDuration()
        completer?()
      case .failed:
        self.reset()
        completerError?()
      default:
        break
      }
    }
  }

  private func setUpPositionObserver(_ player: AVPlayer) {
    let interval = toCMTime(millis: 200)
    let observer = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) {
      [weak self] time in
      self?.onTimeInterval(time: time)
    }
    self.positionObserver = TimeObserver(player: player, observer: observer)
  }

  private func setUpSoundCompletedObserver(_ player: AVPlayer, _ playerItem: AVPlayerItem) {
    let observer = NotificationCenter.default.addObserver(
      forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
      object: playerItem,
      queue: nil
    ) {
      [weak self] (notification) in
      self?.onSoundComplete()
    }
    self.completionObserver = TimeObserver(player: player, observer: observer)
  }

  private func configParameters(player: AVPlayer) {
    if isPlaying {
      player.volume = Float(volume)
      player.rate = Float(playbackRate)
    }
  }

  private func reset() {
    playerItemStatusObservation?.invalidate()
    playerItemStatusObservation = nil
    if let cObserver = completionObserver {
      NotificationCenter.default.removeObserver(cObserver.observer)
      completionObserver = nil
    }
    player.replaceCurrentItem(with: nil)
  }

  private func updateDuration() {
    guard let duration = player.currentItem?.asset.duration else {
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
