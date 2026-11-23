import AVFoundation

@testable import audioplayers_darwin

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif

/// An AVPlayer subclass that does not play, but records play requests, and holds every seek until
/// `finishSeeks` is called.
final class StubAVPlayer: AVPlayer {
  private(set) var playCount = 0
  private var stubRate: Float = 0
  private var pendingSeeks: [@Sendable (Bool) -> Void] = []
  private var seekWaiters: [(count: Int, continuation: CheckedContinuation<Void, Never>)] = []

  override func play() {
    playCount += 1
  }

  override func playImmediately(atRate rate: Float) {
    playCount += 1
  }

  // Setting the rate of an AVPlayer would start the playback.
  override var rate: Float {
    get { stubRate }
    set { stubRate = newValue }
  }

  override func seek(to time: CMTime, completionHandler: @escaping @Sendable (Bool) -> Void) {
    pendingSeeks.append(completionHandler)
    let pendingCount = pendingSeeks.count
    let readyWaiters = seekWaiters.filter { $0.count <= pendingCount }
    seekWaiters.removeAll { $0.count <= pendingCount }
    readyWaiters.forEach { $0.continuation.resume() }
  }

  /// Waits until the given number of seeks is pending.
  func waitForPendingSeeks(count: Int) async {
    if pendingSeeks.count >= count {
      return
    }
    await withCheckedContinuation { continuation in
      seekWaiters.append((count: count, continuation: continuation))
    }
  }

  /// Finishes all pending seeks.
  func finishSeeks() {
    let seeks = pendingSeeks
    pendingSeeks.removeAll()
    seeks.forEach { $0(true) }
  }
}

final class StubAVFactory: WrappedAVObjectFactory {
  let avPlayer: AVPlayer

  init(player: AVPlayer = StubAVPlayer()) {
    self.avPlayer = player
  }

  func player() -> AVPlayer {
    return avPlayer
  }
}

final class StubBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(
    onChannel channel: String,
    message: Data?,
    binaryReply callback: FlutterBinaryReply? = nil
  ) {}
  func setMessageHandlerOnChannel(
    _ channel: String,
    binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    return 0
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

/// Records the names of the events sent on the event channel of a player.
final class TestEventSink {
  private typealias Waiter = (
    name: String, count: Int, continuation: CheckedContinuation<Void, Never>
  )

  private var eventNames: [String] = []
  private var waiters: [Waiter] = []

  var sink: FlutterEventSink {
    return { [weak self] event in
      guard let name = (event as? [String: Any])?["event"] as? String else {
        return
      }
      self?.add(name)
    }
  }

  func count(of name: String) -> Int {
    return eventNames.filter { $0 == name }.count
  }

  /// Waits until the event with the given name was received the given number of times.
  func waitForEvent(_ name: String, count: Int = 1) async {
    if self.count(of: name) >= count {
      return
    }
    await withCheckedContinuation { continuation in
      waiters.append((name: name, count: count, continuation: continuation))
    }
  }

  private func add(_ name: String) {
    eventNames.append(name)
    let receivedCount = count(of: name)
    let readyWaiters = waiters.filter { $0.name == name && $0.count <= receivedCount }
    waiters.removeAll { $0.name == name && $0.count <= receivedCount }
    readyWaiters.forEach { $0.continuation.resume() }
  }
}

/// Creates a silent WAV file, so the tests do not depend on assets or the network.
func createSilentWavFile(seconds: Int = 10) throws -> URL {
  let sampleRate: UInt32 = 8000
  let dataSize = sampleRate * UInt32(seconds)
  var data = Data()
  func append<T: FixedWidthInteger>(_ value: T) {
    withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
  }
  data.append(contentsOf: Array("RIFF".utf8))
  append(UInt32(36) + dataSize)
  data.append(contentsOf: Array("WAVEfmt ".utf8))
  append(UInt32(16))  // Size of the format chunk
  append(UInt16(1))  // PCM
  append(UInt16(1))  // Mono
  append(sampleRate)
  append(sampleRate)  // Byte rate
  append(UInt16(1))  // Block align
  append(UInt16(8))  // Bits per sample
  data.append(contentsOf: Array("data".utf8))
  append(dataSize)
  data.append(Data(repeating: 128, count: Int(dataSize)))

  let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).wav")
  try data.write(to: url)
  return url
}
