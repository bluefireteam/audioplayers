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

#if os(iOS)
let OS_NAME = "iOS"
#else
let OS_NAME = "macOS"
#endif

let CHANNEL_NAME = "xyz.luan/audioplayers"
let LOGGER_CHANNEL_NAME = "xyz.luan/audioplayers.logger"

public class SwiftAudioplayersDarwinPlugin: NSObject, FlutterPlugin {
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    var loggerChannel: FlutterMethodChannel
    
    var players = [String : WrappedMediaPlayer]()
    
    var timeObservers = [TimeObserver]()
    
    var isDealloc = false
    
    init(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel, loggerChannel: FlutterMethodChannel) {
        self.registrar = registrar
        self.channel = channel
        self.loggerChannel = loggerChannel
        
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // TODO(luan) apparently there is a bug in Flutter causing some inconsistency between Flutter and FlutterMacOS
        #if os(iOS)
        let binaryMessenger = registrar.messenger()
        #else
        let binaryMessenger = registrar.messenger
        #endif
        
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: binaryMessenger)
        let loggerChannel = FlutterMethodChannel(name: LOGGER_CHANNEL_NAME, binaryMessenger: binaryMessenger)

        let instance = SwiftAudioplayersDarwinPlugin(registrar: registrar, channel: channel, loggerChannel: loggerChannel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addMethodCallDelegate(instance, channel: loggerChannel)
    }
    
    @objc func needStop() {
        isDealloc = true
        destroy()
    }
    
    func destroy() {
        for observer in self.timeObservers {
            observer.player.removeTimeObserver(observer.observer)
        }
        self.timeObservers = []
        
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
        }

        guard let playerId = args["playerId"] as? String else {
            Logger.error("Call missing mandatory parameter playerId.")
            result(0)
            return
        }
        Logger.info("%@ => call %@, playerId %@", OS_NAME, method, playerId)
        
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
        } else {
            Logger.error("Called not implemented method: %@", method)
            result(FlutterMethodNotImplemented)
            return
        }
        
        // shortcut to avoid requiring explicit call of result(1) everywhere
        if method != "setSourceUrl" {
            result(1)
        }
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
    
    // TODO: figure out the audio session stuff

    func updateCategory(
        recordingActive: Bool,
        isNotification: Bool,
        playingRoute: String,
        duckAudio: Bool
    ) {
        #if os(iOS)
        // When using AVAudioSessionCategoryPlayback, by default, this implies that your app’s audio is nonmixable—activating your session
        // will interrupt any other audio sessions which are also nonmixable. AVAudioSessionCategoryPlayback should not be used with
        // AVAudioSessionCategoryOptionMixWithOthers option. If so, it prevents infoCenter from working correctly.
        let category = (playingRoute == "earpiece" || recordingActive) ? AVAudioSession.Category.playAndRecord : (
            isNotification ? AVAudioSession.Category.ambient : AVAudioSession.Category.playback
        )
        let options = isNotification || duckAudio ? AVAudioSession.CategoryOptions.mixWithOthers : []
        
        configureAudioSession(category: category, options: options)
        if isNotification {
            UIApplication.shared.beginReceivingRemoteControlEvents()
        }
        #endif
    }
    
    func maybeDeactivateAudioSession() {
        let hasPlaying = players.values.contains { player in player.isPlaying }
        if !hasPlaying {
            #if os(iOS)
            configureAudioSession(active: false)
            #endif
        }
    }
    
    // TODO(luan) this should not be here. is playingRoute player-specific or global?
    func setPlayingRoute(playerId: String, playingRoute: String) {
        let wrappedPlayer = players[playerId]!
        wrappedPlayer.playingRoute = playingRoute
        
        #if os(iOS)
        let category = playingRoute == "earpiece" ? AVAudioSession.Category.playAndRecord : AVAudioSession.Category.playback
        configureAudioSession(category: category)
        #endif
    }
    
    #if os(iOS)
    private func configureAudioSession(
        category: AVAudioSession.Category? = nil,
        options: AVAudioSession.CategoryOptions = [],
        active: Bool? = nil
    ) {
        do {           
            let session = AVAudioSession.sharedInstance()
            if let category = category {
                try session.setCategory(category, options: options)
            }
            if let active = active {
                try session.setActive(active)
            }
        } catch {
            Logger.error("Error configuring audio session: %@", error)
        }
    }
    #endif
}
