import AVKit
import AVFoundation

#if os(iOS)
import Flutter
import UIKit
import MediaPlayer
#else
import FlutterMacOS
import AVFAudio
#endif

let CHANNEL_NAME = "xyz.luan/audioplayers"
let GLOBAL_CHANNEL_NAME = "xyz.luan/audioplayers.global"

public class SwiftAudioplayersDarwinPlugin: NSObject, FlutterPlugin {
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    var globalChannel: FlutterMethodChannel
    
    var globalContext: AudioContext = AudioContext()
    var players = [String : WrappedMediaPlayer]()
    
    init(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel, globalChannel: FlutterMethodChannel) {
        self.registrar = registrar
        self.channel = channel
        self.globalChannel = globalChannel
        
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // apparently there is a bug in Flutter causing some inconsistency between Flutter and FlutterMacOS
        #if os(iOS)
        let binaryMessenger = registrar.messenger()
        #else
        let binaryMessenger = registrar.messenger
        #endif
        
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: binaryMessenger)
        let globalChannel = FlutterMethodChannel(name: GLOBAL_CHANNEL_NAME, binaryMessenger: binaryMessenger)

        let instance = SwiftAudioplayersDarwinPlugin(registrar: registrar, channel: channel, globalChannel: globalChannel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addMethodCallDelegate(instance, channel: globalChannel)
    }
    
    @objc func needStop() {
        destroy()
    }
    
    func destroy() {
        for (_, player) in self.players {
            player.clearObservers()
        }
        self.players = [:]
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        
        guard let args = call.arguments as? [String: Any] else {
            Logger.error("Failed to parse call.arguments from Flutter.")
            result(0)
            return
        }

        Logger.info("method %s", method)
        // global handlers (no playerId)
        if method == "changeLogLevel" {
            guard let valueName = args["value"] as! String? else {
                Logger.error("Null value received on changeLogLevel")
                result(0)
                return
            }
            guard let value = LogLevel.parse(valueName) else {
                Logger.error("Invalid value received on changeLogLevel")
                result(0)
                return
            }

            Logger.logLevel = value
            result(1)
            return
        } else if method == "setGlobalAudioContext" {
            guard let context = parseAudioContext(args: args) else {
                result(0)
                return
            }
            globalContext = context
            // TODO(luan) check all existing players
        }

        // player specific handlers
        guard let playerId = args["playerId"] as? String else {
            Logger.error("Call missing mandatory parameter playerId.")
            result(0)
            return
        }
        Logger.info("Method call %@, playerId %@", method, playerId)
        
        let player = self.getOrCreatePlayer(playerId: playerId)
        
        if method == "pause" {
            player.pause()
        } else if method == "resume" {
            player.resume()
        } else if method == "stop" {
            player.stop()
        } else if method == "release" {
            player.release()
        } else if method == "seek" {
            let position = args["position"] as? Int
            if let position = position {
                let time = toCMTime(millis: position)
                player.seek(time: time)
            } else {
                Logger.error("Null position received on seek")
                result(0)
            }
        } else if method == "setSourceUrl" {
            let url: String? = args["url"] as? String
            let isLocal: Bool = (args["isLocal"] as? Bool) ?? false
            
            if url == nil {
                Logger.error("Null URL received on setSourceUrl")
                result(0)
                return
            }
            
            player.setSourceUrl(
                url: url!,
                isLocal: isLocal
            ) {
                player in
                result(1)
            }
            return
        } else if method == "getDuration" {
            let duration = player.getDuration()
            result(duration)
        } else if method == "setVolume" {
            guard let volume = args["volume"] as? Double else {
                Logger.error("Error calling setVolume, volume cannot be null")
                result(0)
                return
            }
            
            player.setVolume(volume: volume)
        } else if method == "getCurrentPosition" {
            let currentPosition = player.getCurrentPosition()
            result(currentPosition)
        } else if method == "setPlaybackRate" {
            guard let playbackRate = args["playbackRate"] as? Double else {
                Logger.error("Error calling setPlaybackRate, playbackRate cannot be null")
                result(0)
                return
            }
            player.setPlaybackRate(playbackRate: playbackRate)
        } else if method == "setReleaseMode" {
            guard let releaseMode = args["releaseMode"] as? String else {
                Logger.error("Error calling setReleaseMode, releaseMode cannot be null")
                result(0)
                return
            }
            let looping = releaseMode.hasSuffix("LOOP")
            player.looping = looping
        } else if method == "setAudioContext" {
            guard let context = parseAudioContext(args: args) else {
                result(0)
                return
            }
            // TODO(luan) implement this
            Logger.error("Not implemented yet; audio context = %@", context)
        } else {
            Logger.error("Called not implemented method: %@", method)
            result(FlutterMethodNotImplemented)
            return
        }
        
        // default result
        result(1)
    }
    
    func getOrCreatePlayer(playerId: String) -> WrappedMediaPlayer {
        if let player = players[playerId] {
            return player
        }
        let newPlayer = WrappedMediaPlayer(
            reference: self,
            playerId: playerId
        )
        players[playerId] = newPlayer
        return newPlayer
    }
    
    func onSeekComplete(playerId: String, finished: Bool) {
        channel.invokeMethod("audio.onSeekComplete", arguments: ["playerId": playerId, "value": finished])
    }
    
    func onComplete(playerId: String) {
        channel.invokeMethod("audio.onComplete", arguments: ["playerId": playerId])
    }
    
    func onCurrentPosition(playerId: String, millis: Int) {
        channel.invokeMethod("audio.onCurrentPosition", arguments: ["playerId": playerId, "value": millis])
    }
    
    func onError(playerId: String) {
        channel.invokeMethod("audio.onError", arguments: ["playerId": playerId, "value": "AVPlayerItem.Status.failed"])
    }
    
    func onDuration(playerId: String, millis: Int) {
        channel.invokeMethod("audio.onDuration", arguments: ["playerId": playerId, "value": millis])
    }
    
    func maybeDeactivateAudioSession() {
        let hasPlaying = players.values.contains { player in player.isPlaying }
        if !hasPlaying {
            configureAudioSession(active: false)
        }
    }
    
    
    private func configureAudioSession(
        audioContext: AudioContext? = nil,
        active: Bool? = nil
    ) {
        #if os(iOS)
        do {           
            let session = AVAudioSession.sharedInstance()
            if let audioContext = audioContext {
                let combinedOptions = audioContext.options.reduce(AVAudioSession.CategoryOptions()) { [$0, $1] }
                try session.setCategory(audioContext.category, options: combinedOptions)
            }
            if let active = active {
                try session.setActive(active)
            }
        } catch {
            Logger.error("Error configuring audio session: %@", error)
        }
        #endif
    }
    
    func parseAudioContext(args: [String: Any]) -> AudioContext? {
        guard let category = args["category"] as! String? else {
            Logger.error("Null value received for category")
            return nil
        }
        guard let optionStrings = args["options"] as! [String]? else {
            Logger.error("Null value received for options")
            return nil
        }
        let options = optionStrings.compactMap { parseCategoryOption(option: $0) }
        if (optionStrings.count != options.count) {
            return nil
        }
        guard let defaultToSpeaker = args["defaultToSpeaker"] as! Bool? else {
            Logger.error("Null value received for defaultToSpeaker")
            return nil
        }
        
        return AudioContext(
            category: AVAudioSession.Category.init(rawValue: category),
            options: options,
            defaultToSpeaker: defaultToSpeaker
        )
    }
    
    func parseCategoryOption(option: String) -> AVAudioSession.CategoryOptions? {
        switch option {
        case "mixWithOthers":
            return .mixWithOthers
        case "duckOthers":
            return .duckOthers
        case "allowBluetooth":
            return .allowBluetooth
        case "defaultToSpeaker":
            return .defaultToSpeaker
        case "interruptSpokenAudioAndMixWithOthers":
            return .interruptSpokenAudioAndMixWithOthers
        case "allowBluetoothA2DP":
            if #available(iOS 10.0, *) {
                return .allowBluetoothA2DP
            } else {
                Logger.error("Category Option allowBluetoothA2DP is only available on iOS 10+")
                return nil
            }
        case "allowAirPlay":
            if #available(iOS 10.0, *) {
                return .allowAirPlay
            } else {
                Logger.error("Category Option allowAirPlay is only available on iOS 10+")
                return nil
            }
        case "overrideMutedMicrophoneInterruption":
            if #available(iOS 14.5, *) {
                return .overrideMutedMicrophoneInterruption
            } else {
                Logger.error("Category Option overrideMutedMicrophoneInterruption is only available on iOS 14.5+")
                return nil
            }
        default:
            Logger.error("Invalid Category Option %@", option)
            return nil
        }
    }
}
