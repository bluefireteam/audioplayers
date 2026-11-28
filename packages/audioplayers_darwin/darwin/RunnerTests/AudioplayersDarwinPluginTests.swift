import AVFoundation
import Testing

@testable import audioplayers_darwin

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif

private let playerId = "p1"

/// The player plays a silent file, and the seek to the start of the loop is held until the test
/// forwards it, so the loop restarts at the same step on every run.
@Suite(.timeLimit(.minutes(1)))
@MainActor struct AudioplayersDarwinPluginTests {

  @Test func loopRestartsAfterSeekingToStart() async throws {
    let avPlayer = InspectableAVPlayer()
    let (plugin, events) = try await createLoopingPlayer(avPlayer: avPlayer)

    await endPlaybackAndHoldSeekToStart(avPlayer)
    await finishSeekToStart(avPlayer, events: events)

    #expect(events.count(of: "audio.onComplete") == 1)
    #expect(plugin.getPlayer(playerId: playerId)!.isPlaying)
    #expect(avPlayer.rate > 0)
    await call(plugin, "dispose")
  }

  @Test func loopDoesNotRestartWhenStoppedWhileSeekingToStart() async throws {
    let avPlayer = InspectableAVPlayer()
    let (plugin, events) = try await createLoopingPlayer(avPlayer: avPlayer)

    await endPlaybackAndHoldSeekToStart(avPlayer)
    await call(plugin, "stop")
    await finishSeekToStart(avPlayer, events: events)

    #expect(!plugin.getPlayer(playerId: playerId)!.isPlaying)
    #expect(avPlayer.rate == 0)
    await call(plugin, "dispose")
  }

  @Test func loopDoesNotRestartWhenPausedWhileSeekingToStart() async throws {
    let avPlayer = InspectableAVPlayer()
    let (plugin, events) = try await createLoopingPlayer(avPlayer: avPlayer)

    await endPlaybackAndHoldSeekToStart(avPlayer)
    await call(plugin, "pause")
    await finishSeekToStart(avPlayer, events: events)

    #expect(!plugin.getPlayer(playerId: playerId)!.isPlaying)
    #expect(avPlayer.rate == 0)
    await call(plugin, "dispose")
  }

  // MARK: - Helpers

  /// Creates a plugin with a looping player, which has a source and was resumed.
  private func createLoopingPlayer(avPlayer: InspectableAVPlayer) async throws -> (
    AudioplayersDarwinPlugin, TestEventSink
  ) {
    let plugin = AudioplayersDarwinPlugin(
      avFactory: StubAVFactory(player: avPlayer),
      binaryMessenger: StubBinaryMessenger())
    await call(plugin, "create")

    let events = TestEventSink()
    _ = plugin.getPlayer(playerId: playerId)!.eventHandler.onListen(
      withArguments: nil, eventSink: events.sink)

    await call(plugin, "setReleaseMode", ["releaseMode": "ReleaseMode.loop"])
    let url = try createSilentWavFile()
    await call(plugin, "setSourceUrl", ["url": url.path, "isLocal": true])
    await call(plugin, "resume")

    try #require(avPlayer.currentItem?.status == .readyToPlay)
    #expect(plugin.getPlayer(playerId: playerId)!.isPlaying)
    #expect(avPlayer.rate > 0)
    return (plugin, events)
  }

  /// Simulates that the player reached the end of its item, and waits until the player seeks to
  /// the start of the loop. Only this seek is held, so other seeks, e.g. of a stop, still complete.
  private func endPlaybackAndHoldSeekToStart(_ avPlayer: InspectableAVPlayer) async {
    avPlayer.holdsSeeks = true
    // At the end of its item, the player pauses itself (`actionAtItemEnd` is `.pause`).
    avPlayer.pause()
    NotificationCenter.default.post(
      name: AVPlayerItem.didPlayToEndTimeNotification, object: avPlayer.currentItem)
    await avPlayer.waitForHeldSeeks(count: 1)
    avPlayer.holdsSeeks = false
  }

  /// Forwards the held seek to the start of the loop, and waits until the player handled it.
  ///
  /// The seek complete event is sent after the player decided whether to restart the loop.
  /// Events of previous seeks, e.g. of a stop, were already received when their call returned.
  private func finishSeekToStart(_ avPlayer: InspectableAVPlayer, events: TestEventSink) async {
    let seekCompleteCount = events.count(of: "audio.onSeekComplete")
    avPlayer.finishSeeks()
    await events.waitForEvent("audio.onSeekComplete", count: seekCompleteCount + 1)
  }

  /// Calls a method of the plugin, like it is called from Dart, and waits for its result.
  private func call(
    _ plugin: AudioplayersDarwinPlugin, _ method: String, _ arguments: [String: Any] = [:]
  ) async {
    var arguments = arguments
    arguments["playerId"] = playerId
    let error: FlutterError? = await withCheckedContinuation { continuation in
      plugin.handle(FlutterMethodCall(methodName: method, arguments: arguments)) { result in
        continuation.resume(returning: result as? FlutterError)
      }
    }
    #expect(error == nil, "\(method) failed: \(error?.message ?? "")")
  }
}
