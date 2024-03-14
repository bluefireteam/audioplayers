import AVFoundation
import AVKit

#if os(iOS)
  import Flutter
  import UIKit
  import MediaPlayer
#else
  import FlutterMacOS
  import AVFAudio
#endif

let channelName = "xyz.luan/audioplayers"

let globalChannelName = "xyz.luan/audioplayers.global"

public class SwiftAudioplayersDarwinPlugin: NSObject, FlutterPlugin {
  var registrar: FlutterPluginRegistrar
  var binaryMessenger: FlutterBinaryMessenger
  var methods: FlutterMethodChannel
  var globalMethods: FlutterMethodChannel
  var globalEvents: GlobalAudioPlayersStreamHandler

  var globalContext = AudioContext()
  var players = [String: WrappedMediaPlayer]()

  init(
    registrar: FlutterPluginRegistrar,
    binaryMessenger: FlutterBinaryMessenger,
    methodChannel: FlutterMethodChannel,
    globalMethodChannel: FlutterMethodChannel,
    globalEventChannel: FlutterEventChannel
  ) {
    self.registrar = registrar
    self.binaryMessenger = binaryMessenger
    self.methods = methodChannel
    self.globalMethods = globalMethodChannel
    self.globalEvents = GlobalAudioPlayersStreamHandler()

    do {
      try globalContext.apply()
    } catch {
      // ignore error on initialization
    }

    super.init()

    self.globalMethods.setMethodCallHandler(self.handleGlobalMethodCall)
    globalEventChannel.setStreamHandler(self.globalEvents)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    // apparently there is a bug in Flutter causing some inconsistency between Flutter and FlutterMacOS
    // See: https://github.com/flutter/flutter/issues/118103
    #if os(iOS)
      let binaryMessenger = registrar.messenger()
    #else
      let binaryMessenger = registrar.messenger
    #endif

    let methods = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
    let globalMethods = FlutterMethodChannel(
      name: globalChannelName, binaryMessenger: binaryMessenger)
    let globalEvents = FlutterEventChannel(
      name: globalChannelName + "/events", binaryMessenger: binaryMessenger)

    let instance = SwiftAudioplayersDarwinPlugin(
      registrar: registrar,
      binaryMessenger: binaryMessenger,
      methodChannel: methods,
      globalMethodChannel: globalMethods,
      globalEventChannel: globalEvents)
    registrar.addMethodCallDelegate(instance, channel: methods)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    dispose()
  }

  func dispose() {
    for (_, player) in self.players {
      player.dispose()
    }
    self.players = [:]
  }

  private func handleGlobalMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method

    guard let args = call.arguments as? [String: Any] else {
      result(
        FlutterError(
          code: "DarwinAudioError", message: "Failed to parse call.arguments from Flutter.",
          details: nil))
      return
    }

    // global handlers (no playerId)
    if method == "setAudioContext" {
      do {
        guard let context = try AudioContext.parse(args: args) else {
          result(
            FlutterError(
              code: "DarwinAudioError",
              message: "Error calling setAudioContext, context could not be parsed", details: nil))
          return
        }
        globalContext = context

        try globalContext.apply()
      } catch AudioPlayerError.warning(let warnMsg) {
        globalEvents.onLog(message: warnMsg)
      } catch {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error configuring global audio session: \(error)",
            details: nil))
      }
    } else if method == "emitLog" {
      guard let message = args["message"] as? String else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error calling emitLog, message cannot be null",
            details: nil))
        return
      }
      globalEvents.onLog(message: message)
    } else if method == "emitError" {
      guard let code = args["code"] as? String else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error calling emitError, code cannot be null",
            details: nil))
        return
      }
      guard let message = args["message"] as? String else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error calling emitError, message cannot be null",
            details: nil))
        return
      }
      globalEvents.onError(code: code, message: message, details: nil)
    } else {
      result(FlutterMethodNotImplemented)
      return
    }

    // default result (bypass by adding `return` to your branch)
    result(1)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method

    guard let args = call.arguments as? [String: Any] else {
      result(
        FlutterError(
          code: "DarwinAudioError", message: "Failed to parse call.arguments from Flutter.",
          details: nil))
      return
    }

    // player specific handlers
    guard let playerId = args["playerId"] as? String else {
      result(
        FlutterError(
          code: "DarwinAudioError", message: "Call missing mandatory parameter playerId.",
          details: nil))
      return
    }

    if method == "create" {
      self.createPlayer(playerId: playerId)
      result(1)
      return
    }

    guard let player = self.getPlayer(playerId: playerId) else {
      result(
        FlutterError(
          code: "DarwinAudioError",
          message: "Player has not yet been created or has already been disposed.", details: nil))
      return
    }

    if method == "pause" {
      player.pause()
    } else if method == "resume" {
      player.resume()
    } else if method == "stop" {
      player.stop {
        result(1)
      }
      return
    } else if method == "release" {
      player.release {
        result(1)
      }
      return
    } else if method == "seek" {
      guard let position = args["position"] as? Int else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Null position received on seek", details: nil))
        return
      }
      let time = toCMTime(millis: position)
      player.seek(time: time) {
        result(1)
      }
      return
    } else if method == "setSourceUrl" {
      let url: String? = args["url"] as? String
      let mimeType: String? = args["mimeType"] as? String
      let isLocal: Bool = (args["isLocal"] as? Bool) ?? false

      if url == nil {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Null URL received on setSourceUrl", details: nil))
        return
      }

      player.setSourceUrl(
        url: url!, isLocal: isLocal,
        mimeType: mimeType,
        completer: {
          player.eventHandler.onPrepared(isPrepared: true)
        },
        completerError: { error in
          let errorStr: String = error != nil ? "\(error!)" : "Unknown error"
          player.eventHandler.onError(
            code: "DarwinAudioError",
            message: "Failed to set source. For troubleshooting, see "
              + "https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md",
            details: "AVPlayerItem.Status.failed on setSourceUrl: \(errorStr)")
        })
      result(1)
      return
    } else if method == "setSourceBytes" {
      result(
        FlutterError(
          code: "DarwinAudioError", message: "setSourceBytes is not currently implemented on iOS",
          details: nil))
      return
    } else if method == "getDuration" {
      let duration = player.getDuration()
      result(duration)
    } else if method == "setVolume" {
      guard let volume = args["volume"] as? Double else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error calling setVolume, volume cannot be null",
            details: nil))
        return
      }

      player.setVolume(volume: volume)
    } else if method == "setBalance" {
      player.eventHandler.onLog(message: "setBalance is not currently implemented on iOS")
      result(0)
      return
    } else if method == "getCurrentPosition" {
      let currentPosition = player.getCurrentPosition()
      result(currentPosition)
      return
    } else if method == "setPlaybackRate" {
      guard let playbackRate = args["playbackRate"] as? Double else {
        result(
          FlutterError(
            code: "DarwinAudioError",
            message: "Error calling setPlaybackRate, playbackRate cannot be null", details: nil))
        return
      }
      player.setPlaybackRate(playbackRate: playbackRate)
    } else if method == "setReleaseMode" {
      guard let releaseMode = args["releaseMode"] as? String else {
        result(
          FlutterError(
            code: "DarwinAudioError",
            message: "Error calling setReleaseMode, releaseMode cannot be null", details: nil))
        return
      }
      // Note: there is no "release" on iOS; hence we only care if it's looping or not
      let looping = releaseMode.hasSuffix("loop")
      player.looping = looping
    } else if method == "setPlayerMode" {
      // no-op for darwin; only one player mode
    } else if method == "setAudioContext" {
      player.eventHandler.onLog(
        message:
          "iOS does not allow for player-specific audio contexts; `setAudioContext` will set the global audio context instead (like `global.setAudioContext`)."
      )
      do {
        guard let context = try AudioContext.parse(args: args) else {
          result(
            FlutterError(
              code: "DarwinAudioError",
              message: "Error calling setAudioContext, context could not be parsed", details: nil))
          return
        }
        globalContext = context

        try globalContext.apply()
      } catch AudioPlayerError.warning(let warnMsg) {
        globalEvents.onLog(message: warnMsg)
      } catch {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error configuring audio session: \(error)",
            details: nil))
      }
    } else if method == "emitLog" {
      guard let message = args["message"] as? String else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error calling emitLog, message cannot be null",
            details: nil))
        return
      }
      player.eventHandler.onLog(message: message)
    } else if method == "emitError" {
      guard let code = args["code"] as? String else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error calling emitError, code cannot be null",
            details: nil))
        return
      }
      guard let message = args["message"] as? String else {
        result(
          FlutterError(
            code: "DarwinAudioError", message: "Error calling emitError, message cannot be null",
            details: nil))
        return
      }
      player.eventHandler.onError(code: code, message: message, details: nil)
    } else if method == "dispose" {
      player.dispose {
        self.players[playerId] = nil
        result(1)
      }
      return
    } else {
      result(FlutterMethodNotImplemented)
      return
    }

    // default result (bypass by adding `return` to your branch)
    result(1)
  }

  func createPlayer(playerId: String) {
    let eventChannel = FlutterEventChannel(
      name: channelName + "/events/" + playerId, binaryMessenger: self.binaryMessenger)

    let eventHandler = AudioPlayersStreamHandler()

    eventChannel.setStreamHandler(eventHandler)

    let newPlayer = WrappedMediaPlayer(
      reference: self,
      eventHandler: eventHandler
    )
    players[playerId] = newPlayer
  }

  func getPlayer(playerId: String) -> WrappedMediaPlayer? {
    return players[playerId]
  }

  func controlAudioSession() {
    let anyIsPlaying = players.values.contains { player in
      player.isPlaying
    }

    do {
      try globalContext.activateAudioSession(active: anyIsPlaying)
    } catch {
      self.globalEvents.onError(
        code: "DarwinAudioError", message: "Error configuring audio session: \(error)", details: nil
      )
    }
  }
}

class AudioPlayersStreamHandler: NSObject, FlutterStreamHandler {
  var sink: FlutterEventSink?

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.sink = events
    // events(FlutterEndOfEventStream) // when stream is over
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }

  func onSeekComplete() {
    if let eventSink = self.sink {
      eventSink(["event": "audio.onSeekComplete"])
    }
  }

  func onComplete() {
    if let eventSink = self.sink {
      eventSink(["event": "audio.onComplete"])
    }
  }

  func onDuration(millis: Int) {
    if let eventSink = self.sink {
      eventSink(["event": "audio.onDuration", "value": millis] as [String: Any])
    }
  }

  func onPrepared(isPrepared: Bool) {
    if let eventSink = self.sink {
      eventSink(["event": "audio.onPrepared", "value": isPrepared] as [String: Any])
    }
  }

  func onLog(message: String) {
    if let eventSink = self.sink {
      eventSink(["event": "audio.onLog", "value": message])
    }
  }

  func onError(code: String, message: String, details: Any?) {
    if let eventSink = self.sink {
      eventSink(FlutterError(code: code, message: message, details: details))
    }
  }
}

class GlobalAudioPlayersStreamHandler: NSObject, FlutterStreamHandler {
  var sink: FlutterEventSink?

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.sink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }

  func onLog(message: String) {
    if let eventSink = self.sink {
      eventSink(["event": "audio.onLog", "value": message])
    }
  }

  func onError(code: String, message: String, details: Any?) {
    if let eventSink = self.sink {
      eventSink(FlutterError(code: code, message: message, details: details))
    }
  }
}
