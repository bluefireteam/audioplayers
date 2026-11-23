import AVFoundation
import Testing

@testable import audioplayers_darwin

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif

private let playerId = "p1"

/// The player does not play and every seek is held until the test finishes it, so the steps
/// happen in the same order on every run, without depending on the playback.
@Suite(.timeLimit(.minutes(1)))
@MainActor struct AudioplayersDarwinPluginTests {

  @Test func loopRestartsAfterSeekingToStart() async throws {
    let avPlayer = StubAVPlayer()
    let (plugin, events) = try await createLoopingPlayer(avPlayer: avPlayer)

    endPlayback(avPlayer)
    await avPlayer.waitForPendingSeeks(count: 1)
    avPlayer.finishSeeks()
    await events.waitForEvent("audio.onSeekComplete")

    #expect(events.count(of: "audio.onComplete") == 1)
    #expect(plugin.getPlayer(playerId: playerId)!.isPlaying)
    #expect(avPlayer.playCount == 2)
  }

  @Test func loopDoesNotRestartWhenStoppedWhileSeekingToStart() async throws {
    let avPlayer = StubAVPlayer()
    let (plugin, events) = try await createLoopingPlayer(avPlayer: avPlayer)

    endPlayback(avPlayer)
    await avPlayer.waitForPendingSeeks(count: 1)
    await call(plugin, "stop")
    avPlayer.finishSeeks()
    await events.waitForEvent("audio.onSeekComplete")

    #expect(!plugin.getPlayer(playerId: playerId)!.isPlaying)
    #expect(avPlayer.playCount == 1)
  }

  @Test func loopDoesNotRestartWhenPausedWhileSeekingToStart() async throws {
    let avPlayer = StubAVPlayer()
    let (plugin, events) = try await createLoopingPlayer(avPlayer: avPlayer)

    endPlayback(avPlayer)
    await avPlayer.waitForPendingSeeks(count: 1)
    await call(plugin, "pause")
    avPlayer.finishSeeks()
    await events.waitForEvent("audio.onSeekComplete")

    #expect(!plugin.getPlayer(playerId: playerId)!.isPlaying)
    #expect(avPlayer.playCount == 1)
  }

  // MARK: - Helpers

  /// Creates a plugin with a looping player, which has a source and was resumed.
  private func createLoopingPlayer(avPlayer: StubAVPlayer) async throws -> (
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
    #expect(avPlayer.playCount == 1)
    return (plugin, events)
  }

  /// Simulates that the player reached the end of its item.
  private func endPlayback(_ avPlayer: AVPlayer) {
    NotificationCenter.default.post(
      name: AVPlayerItem.didPlayToEndTimeNotification, object: avPlayer.currentItem)
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
