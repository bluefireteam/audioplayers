import AVKit
import AVFoundation

#if os(iOS)
import UIKit
import MediaPlayer
#endif

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

#if os(iOS)
let osName = "iOS"
#else
let osName = "macOS"
#endif

let CHANNEL_NAME = "xyz.luan/audioplayers"
let AudioplayersPluginStop = NSNotification.Name("AudioplayersPluginStop")

typealias VoidCallback = (String) -> Void

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

class PlayerInfo {
    var playerId: String
    var player: AVPlayer?
    var observers: [TimeObserver]
    
    var isPlaying: Bool
    var playbackRate: Float
    var volume: Float
    var playingRoute: String
    var looping: Bool
    var url: String?
    var onReady: VoidCallback?
    
    init(
        playerId: String,
        player: AVPlayer?,
        observers: [TimeObserver],
        
        isPlaying: Bool,
        playbackRate: Float,
        volume: Float,
        playingRoute: String,
        looping: Bool,
        url: String?,
        onReady: VoidCallback?
    ) {
        self.playerId = playerId
        self.player = player
        self.observers = observers
        
        self.isPlaying = isPlaying
        self.playbackRate = playbackRate
        self.volume = volume
        self.playingRoute = playingRoute
        self.looping = looping
        self.url = url
        self.onReady = onReady
    }
}

public class SwiftAudioplayersPlugin: NSObject, FlutterPlugin {
    
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    
    var players = [String : PlayerInfo]()
    var timeObservers = [TimeObserver]()
    var keyValueObservations = [String : NSKeyValueObservation]()
    
    init(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        self.registrar = registrar
        self.channel = channel
        
        #if os(iOS)
        // this method is used to listen to audio playpause event
        // from the notification area in the background.
        self.headlessEngine = FlutterEngine.init(name: "AudioPlayerIsolate")
        // This is the method channel used to communicate with
        // `_backgroundCallbackDispatcher` defined in the Dart portion of our plugin.
        // Note: we don't add a MethodCallDelegate for this channel now since our
        // BinaryMessenger needs to be initialized first, which is done in
        // `startHeadlessService` below.
        self.callbackChannel = FlutterMethodChannel(name: "xyz.luan/audioplayers_callback", binaryMessenger: headlessEngine.binaryMessenger)
        #endif
        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.needStop), name: AudioplayersPluginStop, object: nil)
    }
    
    var result: FlutterResult? = nil
    
    var isDealloc = false
    var updateHandleMonitorKey: Int64? = nil
    
    #if os(iOS)
    var headlessEngine: FlutterEngine
    var callbackChannel: FlutterMethodChannel
    var headlessServiceInitialized = false
    
    var currentPlayerId: String? = nil // to be used for notifications command center
    var infoCenter: MPNowPlayingInfoCenter? = nil
    var remoteCommandCenter: MPRemoteCommandCenter? = nil
    #endif
    
    var title: String? = nil
    var albumTitle: String? = nil
    var artist: String? = nil
    var imageUrl: String? = nil
    
    var duration: Int? = nil
    
    let defaultPlaybackRate: Float = 1.0
    let defaultPlayingRoute: String = "speakers"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // TODO(luan) apparently there is a bug in Flutter causing some inconsistency between Flutter and FlutterMacOS
        #if os(iOS)
        let binaryMessenger = registrar.messenger()
        #else
        let binaryMessenger = registrar.messenger
        #endif

        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: binaryMessenger)
        let instance = SwiftAudioplayersPlugin(registrar: registrar, channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    @objc func needStop() {
        isDealloc = true
        destroy()
    }
    
    func destroy() {
        for osberver in self.timeObservers {
            osberver.player.removeTimeObserver(osberver.observer)
        }
        self.timeObservers = []
        
        for (_, playerInfo) in self.players {
            let observers = playerInfo.observers
            for observer in observers {
                NotificationCenter.default.removeObserver(observer.observer)
            }
        }
        self.players = [:]
    }
    
    #if os(iOS)
    // Initializes and starts the background isolate which will process audio
    // events. `handle` is the handle to the callback dispatcher which we specified
    // in the Dart portion of the plugin.
    func startHeadlessService(handle: Int64) {
        // Lookup the information for our callback dispatcher from the callback cache.
        // This cache is populated when `PluginUtilities.getCallbackHandle` is called
        // and the resulting handle maps to a `FlutterCallbackInformation` object.
        // This object contains information needed by the engine to start a headless
        // runner, which includes the callback name as well as the path to the file
        // containing the callback.
        let info = FlutterCallbackCache.lookupCallbackInformation(handle)
        assert(info != nil, "failed to find callback")
        if info != nil {
            let entrypoint = info!.callbackName
            let uri = info!.callbackLibraryPath
            
            // Here we actually launch the background isolate to start executing our
            // callback dispatcher, `_backgroundCallbackDispatcher`, in Dart.
            self.headlessServiceInitialized = headlessEngine.run(withEntrypoint: entrypoint, libraryURI: uri)
            if self.headlessServiceInitialized {
                // The headless runner needs to be initialized before we can register it as a
                // MethodCallDelegate or else we get an illegal memory access. If we don't
                // want to make calls from `_backgroundCallDispatcher` back to native code,
                // we don't need to add a MethodCallDelegate for this channel.
                self.registrar.addMethodCallDelegate(self, channel: self.callbackChannel)
            }
        }
    }
    #endif
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        
        guard let rawArgs = call.arguments else {
            return
        }
        let args: [String: Any] = rawArgs as! [String: Any]
        
        let playerId: String = args["playerId"] as! String
        log("%@ => call %@, playerId %@", osName, method, playerId)
        
        self.initPlayerInfo(playerId: playerId)

        if method == "startHeadlessService" {
            #if os(iOS)
            if let handleKey = args["handleKey"] {
                log("calling start headless service %@", handleKey)
                let handle = (handleKey as! [Any])[0]
                self.startHeadlessService(handle: (handle as! Int64))
            } else {
                result(0)
            }
            #else
            result(FlutterMethodNotImplemented)
            #endif
        } else if method == "monitorNotificationStateChanges" {
            #if os(iOS)
            if let handleMonitorKey = args["handleMonitorKey"] {
                log("calling monitor notification %@", handleMonitorKey)
                let handle = (handleMonitorKey as! [Any])[0]
                self.updateHandleMonitorKey = (handle as! Int64)
            } else {
                result(0)
            }
            #else
            result(FlutterMethodNotImplemented)
            #endif
        } else if method == "play" {
            let url = args["url"] as! String?
            if url == nil {
                result(0)
            }
            
            let isLocal: Bool = (args["isLocal"] as? Bool) ?? true
            let volume: Float = (args["volume"] as? Float) ?? 1.0

            // we might or might not want to seek
            let seekTimeMillis: Int? = (args["position"] as? Int)
            let seekTime: CMTime? = seekTimeMillis.map { toCMTime(millis: $0) }

            let respectSilence: Bool = (args["respectSilence"] as? Bool) ?? false
            let recordingActive: Bool = (args["recordingActive"] as? Bool) ?? false
            let duckAudio: Bool = (args["duckAudio"] as? Bool) ?? false
            
            self.play(
                playerId: playerId,
                url: url!,
                isLocal: isLocal,
                volume: volume,
                time: seekTime,
                isNotification: respectSilence,
                duckAudio: duckAudio,
                recordingActive: recordingActive
            )
        } else if method == "pause" {
            self.pause(playerId: playerId)
        } else if method == "resume" {
            self.resume(playerId: playerId)
        } else if method == "stop" {
            self.stop(playerId: playerId)
        } else if method == "release" {
            self.stop(playerId: playerId)
        } else if method == "seek" {
            let position: Int? = args["position"] as? Int
            if position == nil {
                result(0)
            } else {
                log("Seeking to: %d milliseconds", position!)
                self.seek(playerId: playerId, time: toCMTime(millis: position!))
            }
        } else if method == "setUrl" {
            let url: String? = args["url"] as? String
            let isLocal: Bool = (args["isLocal"] as? Bool) ?? false
            let respectSilence: Bool = (args["respectSilence"] as? Bool) ?? false
            let recordingActive: Bool = (args["recordingActive"] as? Bool) ?? false
            
            if url == nil {
                log("Null URL received on setUrl")
                result(0)
                return
            }

            self.setUrl(
                playerId: playerId,
                url: url!,
                isLocal: isLocal,
                isNotification: respectSilence,
                recordingActive: recordingActive
            ) {
                playerId in
                result(1)
            }
        } else if method == "getDuration" {
            let duration: Int = self.getDuration(playerId: playerId)
            result(duration)
        } else if method == "setVolume" {
            let volume: Float? = args["volume"] as? Float
            if (volume == nil) {
                log("Error calling setVolume, volume cannot be null")
                result(0)
            } else {
                self.setVolume(playerId: playerId, volume: volume!)
            }
        } else if method == "getCurrentPosition" {
            let currentPosition: Int = self.getCurrentPosition(playerId: playerId)
            result(currentPosition)
        } else if method == "setPlaybackRate" {
            let playbackRate: Float? = args["playbackRate"] as? Float
            if (playbackRate == nil) {
                log("Error calling setPlaybackRate, playbackRate cannot be null")
                result(0)
            } else {
                self.setPlaybackRate(playerId: playerId, playbackRate: playbackRate!)
            }
        } else if method == "setReleaseMode" {
            let releaseMode: String = args["releaseMode"] as! String
            let looping: Bool = releaseMode.hasSuffix("LOOP")
            self.setLooping(playerId: playerId, looping: looping)
        } else if method == "earpieceOrSpeakersToggle" {
            let playingRoute: String = args["playingRoute"] as! String
            self.setPlayingRoute(playerId: playerId, playingRoute: playingRoute)
        } else if method == "setNotification" {
            #if os(iOS)
            log("setNotification called")
            let title: String? = args["title"] as? String
            let albumTitle: String? = args["albumTitle"] as? String
            let artist: String? = args["artist"] as? String
            let imageUrl: String? = args["imageUrl"] as? String
            
            let forwardSkipInterval: Int? = args["forwardSkipInterval"] as? Int
            let backwardSkipInterval: Int? = args["backwardSkipInterval"] as? Int
            let duration: Int? = args["duration"] as? Int
            let elapsedTime: Int? = args["elapsedTime"] as? Int
            
            let enablePreviousTrackButton: Bool? = args["enablePreviousTrackButton"] as? Bool
            let enableNextTrackButton: Bool? = args["enableNextTrackButton"] as? Bool

            // TODO(luan) reconsider whether these params are optional or not + default values/errors
            self.setNotification(
                playerId: playerId,
                title: title,
                albumTitle: albumTitle,
                artist: artist,
                imageUrl: imageUrl,
                forwardSkipInterval: forwardSkipInterval ?? 0,
                backwardSkipInterval: backwardSkipInterval ?? 0,
                duration: duration,
                elapsedTime: elapsedTime!,
                enablePreviousTrackButton: enablePreviousTrackButton,
                enableNextTrackButton: enableNextTrackButton
            )
            #else
            result(FlutterMethodNotImplemented)
            #endif
        } else {
            log("Called not implemented method: %@", method)
            result(FlutterMethodNotImplemented)
            return
        }

        // shortcut to avoid requiring explicit call of result(1) everywhere
        if method != "setUrl" {
            result(1)
        }
    }
    
    func initPlayerInfo(playerId: String) {
        let playerInfo = players[playerId]
        if playerInfo == nil {
            players[playerId] = PlayerInfo(
                playerId: playerId,
                player: nil,
                observers: [],
                isPlaying: false,
                playbackRate: defaultPlaybackRate,
                volume: 1.0,
                playingRoute: defaultPlayingRoute,
                looping: false,
                url: nil,
                onReady: nil
            )
        }
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
    
    func play(
        playerId: String,
        url: String,
        isLocal: Bool,
        volume: Float,
        time: CMTime?,
        isNotification: Bool,
        duckAudio: Bool,
        recordingActive: Bool
    ) {
        #if os(iOS)
        do {
            let category: AVAudioSession.Category = isNotification ? AVAudioSession.Category.ambient : AVAudioSession.Category.playback
            if duckAudio {
                try AVAudioSession.sharedInstance().setCategory(category, options: AVAudioSession.CategoryOptions.duckOthers)
            } else {
                try AVAudioSession.sharedInstance().setCategory(category)
            }
            
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            log("Error setting category %@", error)
        }
        #endif
        
        self.setUrl(
            playerId: playerId,
            url: url,
            isLocal: isLocal,
            isNotification: isNotification,
            recordingActive: recordingActive
        ) {
            playerId in
            let playerInfo = self.players[playerId]!
            let player = playerInfo.player!
            player.volume = volume
            if let time = time {
                player.seek(to: time)
            }
            
            if #available(iOS 10.0, macOS 10.12, *) {
                player.playImmediately(atRate: playerInfo.playbackRate)
            } else {
                player.play()
            }
            
            playerInfo.isPlaying = true
        }
        #if os(iOS)
        currentPlayerId = playerId // to be used for notifications command center
        #endif
    }
    
    func setUrl(
        playerId: String,
        url: String,
        isLocal: Bool,
        isNotification: Bool,
        recordingActive: Bool,
        onReady: @escaping VoidCallback
    ) {
        let playerInfo = players[playerId]!
        
        log("setUrl %@", url)
        
        #if os(iOS)
        
        let category = recordingActive ? AVAudioSession.Category.playAndRecord : (
            isNotification ? AVAudioSession.Category.ambient : AVAudioSession.Category.playback
        )
        
        do {
            // When using AVAudioSessionCategoryPlayback, by default, this implies that your app’s audio is nonmixable—activating your session
            // will interrupt any other audio sessions which are also nonmixable. AVAudioSessionCategoryPlayback should not be used with
            // AVAudioSessionCategoryOptionMixWithOthers option. If so, it prevents infoCenter from working correctly.
            if isNotification {
                try AVAudioSession.sharedInstance().setCategory(category, options: AVAudioSession.CategoryOptions.mixWithOthers)
            } else {
                try AVAudioSession.sharedInstance().setCategory(category)
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            
            if playerInfo.playingRoute == "earpiece" {
                // Use earpiece speaker to play audio.
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            }
            
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            log("Error setting category %@", error)
        }
        
        #endif
        
        let playbackStatus = playerInfo.player?.currentItem?.status
        
        if url != playerInfo.url || playbackStatus == .failed {
            let parsedUrl = isLocal ? URL.init(fileURLWithPath: url) : URL.init(string: url)!
            let playerItem = AVPlayerItem.init(url: parsedUrl)
            
            let player: AVPlayer
            if let existingPlayer = playerInfo.player {
                keyValueObservations[playerId]?.invalidate()
                playerInfo.url = url
                
                for observer in playerInfo.observers {
                    NotificationCenter.default.removeObserver(observer.observer)
                }
                playerInfo.observers = []
                existingPlayer.replaceCurrentItem(with: playerItem)
                player = existingPlayer
            } else {
                player = AVPlayer.init(playerItem: playerItem)
                
                playerInfo.player = player
                playerInfo.observers = []
                playerInfo.url = url
                
                // stream player position
                let interval: CMTime = toCMTime(millis: 0.2)
                let timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) {
                    [weak self] time in
                    self!.onTimeInterval(playerId: playerId, time: time)
                }
                self.timeObservers.append(TimeObserver(player: player, observer: timeObserver))
            }
            
            let anObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) {
                [weak self] (notification) in
                self!.onSoundComplete(playerId: playerId)
            }
            playerInfo.observers.append(TimeObserver(player: player, observer: anObserver))
            
            // is sound ready
            playerInfo.onReady = onReady
            let newKeyValueObservation: NSKeyValueObservation = playerItem.observe(\AVPlayerItem.status) { (playerItem, change) in
                let status = playerItem.status
                log("player status: %@ change: %@", status, change)
                
                // Do something with the status...
                if status == .readyToPlay {
                    self.updateDuration(playerId: playerId)
                    
                    let onReady: VoidCallback? = playerInfo.onReady
                    if onReady != nil {
                        playerInfo.onReady = nil
                        onReady!(playerId)
                    }
                } else if status == .failed {
                    self.channel.invokeMethod("audio.onError", arguments: ["playerId": playerId, "value": "AVPlayerItem.Status.failed"])
                }
            }
            
            if let observation = keyValueObservations[playerId] {
                observation.invalidate()
            }
            keyValueObservations[playerId] = newKeyValueObservation
        } else {
            if playbackStatus == .readyToPlay {
                onReady(playerId)
            }
        }
    }
    
    func updateDuration(playerId: String) {
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player!
        
        let duration = player.currentItem!.asset.duration
        log("%@ -> updateDuration...%f", osName, CMTimeGetSeconds(duration))
        if CMTimeGetSeconds(duration) > 0 {
            log("%@ -> invokechannel", osName)
            let mseconds: Int = self.fromCMTime(time: duration)
            channel.invokeMethod("audio.onDuration", arguments: ["playerId": playerId, "value": mseconds])
        }
    }
    
    func getDuration(playerId: String) -> Int {
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player!
        
        let duration: CMTime = player.currentItem!.asset.duration
        let mseconds: Int = self.fromCMTime(time: duration)
        
        return mseconds
    }
    
    func getCurrentPosition(playerId: String) -> Int {
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player!
        
        let duration: CMTime = player.currentTime()
        let mseconds: Int = self.fromCMTime(time: duration)
        
        return mseconds
    }
    
    func onTimeInterval(playerId: String, time: CMTime) {
        if isDealloc {
            return
        }
        let mseconds: Int = self.fromCMTime(time: time)
        channel.invokeMethod("audio.onCurrentPosition", arguments: ["playerId": playerId, "value": mseconds])
    }
    
    func pause(playerId: String) {
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player!
        
        player.pause()
        playerInfo.isPlaying = false
    }
    
    func resume(playerId: String) {
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player!
        
        let playbackRate: Float = playerInfo.playbackRate
        
        #if os(iOS)
        currentPlayerId = playerId // to be used for notifications command center
        #endif
        
        if #available(iOS 10.0, macOS 10.12, *) {
            player.playImmediately(atRate: playbackRate)
        } else {
            player.play()
        }
        playerInfo.isPlaying = true
    }
    
    func setVolume(playerId: String, volume: Float) {
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player!
        
        player.volume = volume
        playerInfo.volume = volume
    }
    
    func setPlaybackRate(playerId: String, playbackRate: Float) {
        log("%@ -> calling setPlaybackRate", osName)
        
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player!
        
        playerInfo.playbackRate = playbackRate
        player.rate = playbackRate
        #if os(iOS)
        if infoCenter != nil {
            let currentItem = player.currentItem!
            let currentTime: CMTime = currentItem.currentTime()
            self.updateNotification(time: currentTime)
        }
        #endif
    }
    
    func setPlayingRoute(playerId: String, playingRoute: String) {
        log("%@ -> calling setPlayingRoute", osName)
        
        let playerInfo: PlayerInfo = players[playerId]!
        playerInfo.playingRoute = playingRoute
        
        #if os(iOS)
        let category = playingRoute == "earpiece" ? AVAudioSession.Category.playAndRecord : AVAudioSession.Category.playback
        do {
            try AVAudioSession.sharedInstance().setCategory(category)
        } catch {
            log("Error setting category %@", error)
        }
        #endif
    }
    
    func setLooping(playerId: String, looping: Bool) {
        let playerInfo: PlayerInfo = players[playerId]!
        playerInfo.looping = looping
    }
    
    func stop(playerId: String) {
        let playerInfo: PlayerInfo = players[playerId]!
        if playerInfo.isPlaying {
            self.pause(playerId: playerId)
            playerInfo.isPlaying = false
        }
        self.seek(playerId: playerId, time: toCMTime(millis: 0))
    }
    
    func seek(playerId: String, time: CMTime) {
        let playerInfo: PlayerInfo = players[playerId]!
        let player = playerInfo.player
        
        #if os(iOS)
        player?.currentItem?.seek(to: time) {
            finished in
            if finished {
                log("ios -> seekComplete...")
                if self.infoCenter != nil {
                    self.updateNotification(time: time)
                }
                
            }
            self.channel.invokeMethod("audio.onSeekComplete", arguments: ["playerId": playerId, "value": finished])
        }
        #else
        player?.currentItem?.seek(to: time)
        #endif
    }
    
    func onSoundComplete(playerId: String) {
        log("%@ -> onSoundComplete...", osName)
        let playerInfo: PlayerInfo = players[playerId]!
        
        if !playerInfo.isPlaying {
            return
        }
        
        self.pause(playerId: playerId)
        
        if playerInfo.looping {
            self.seek(playerId: playerId, time: toCMTime(millis: 0))
            self.resume(playerId: playerId)
        }
        
        
        channel.invokeMethod("audio.onComplete", arguments: ["playerId": playerId])
        
        #if os(iOS)
        let hasPlaying: Bool = players.values.contains { player in player.isPlaying }
        if !hasPlaying {
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                log("Error inactivating audio session %@", error)
            }
        }
        #endif
        
        #if os(iOS)
        if headlessServiceInitialized {
            callbackChannel.invokeMethod("audio.onNotificationBackgroundPlayerStateChanged", arguments: ["playerId": playerId, "updateHandleMonitorKey": updateHandleMonitorKey as Any, "value": "completed"])
        }
        #endif
    }
    
    // notifications

    #if os(iOS)
    static func geneateImageFromUrl(urlString: String) -> UIImage? {
        if urlString.hasPrefix("http") {
            guard let url: URL = URL.init(string: urlString) else {
                log("Error download image url, invalid url %@", urlString)
                return nil
            }
            do {
                let data = try Data(contentsOf: url)
                return UIImage.init(data: data)
            } catch {
                log("Error download image url %@", error)
                return nil
            }
        } else {
            return UIImage.init(contentsOfFile: urlString)
        }
    }
    
    func updateNotification(time: CMTime) {
        // From `MPNowPlayingInfoPropertyElapsedPlaybackTime` docs -- it is not recommended to update this value frequently.
        // Thus it should represent integer seconds and not an accurate `CMTime` value with fractions of a second
        let elapsedTime = Int(time.seconds)
        
        var playingInfo: [String: Any?] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyAlbumTitle: albumTitle,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
            MPNowPlayingInfoPropertyPlaybackRate: defaultPlaybackRate
        ]
        
        log("Updating playing info...")

        // fetch notification image in async fashion to avoid freezing UI
        DispatchQueue.global().async() { [weak self] in
            if let imageUrl = self?.imageUrl {
                let artworkImage: UIImage? = SwiftAudioplayersPlugin.geneateImageFromUrl(urlString: imageUrl)
                if let artworkImage = artworkImage {
                    let albumArt: MPMediaItemArtwork = MPMediaItemArtwork.init(image: artworkImage)
                    log("Will add custom album art")
                    playingInfo[MPMediaItemPropertyArtwork] = albumArt
                }
            }

            if let infoCenter = self?.infoCenter {
                let filteredMap = playingInfo.filter { $0.value != nil }.mapValues { $0! }
                log("Setting playing info: %@", filteredMap)
                infoCenter.nowPlayingInfo = filteredMap
            }
        }
    }
    
    func setNotification(
        playerId: String,
        title: String?,
        albumTitle: String?,
        artist: String?,
        imageUrl: String?,
        forwardSkipInterval: Int,
        backwardSkipInterval: Int,
        duration: Int?,
        elapsedTime: Int,
        enablePreviousTrackButton: Bool?,
        enableNextTrackButton: Bool?
    ) {
        self.title = title
        self.albumTitle = albumTitle
        self.artist = artist
        self.imageUrl = imageUrl
        self.duration = duration

        self.infoCenter = MPNowPlayingInfoCenter.default()
        self.updateNotification(time: self.toCMTime(millis: elapsedTime))

        if (remoteCommandCenter == nil) {
            remoteCommandCenter = MPRemoteCommandCenter.shared()

          if (forwardSkipInterval > 0 || backwardSkipInterval > 0) {
            let skipBackwardIntervalCommand = remoteCommandCenter!.skipBackwardCommand
            skipBackwardIntervalCommand.isEnabled = true
            skipBackwardIntervalCommand.addTarget(handler: self.skipBackwardEvent)
            skipBackwardIntervalCommand.preferredIntervals = [backwardSkipInterval as NSNumber]

            let skipForwardIntervalCommand = remoteCommandCenter!.skipForwardCommand
            skipForwardIntervalCommand.isEnabled = true
            skipForwardIntervalCommand.addTarget(handler: self.skipForwardEvent)
            skipForwardIntervalCommand.preferredIntervals = [forwardSkipInterval as NSNumber] // Max 99
          } else {  // if skip interval not set using next and previous
            let nextTrackCommand = remoteCommandCenter!.nextTrackCommand
            nextTrackCommand.isEnabled = enableNextTrackButton ?? false
            nextTrackCommand.addTarget(handler: self.nextTrackEvent)
            
            let previousTrackCommand = remoteCommandCenter!.previousTrackCommand
            previousTrackCommand.isEnabled = enablePreviousTrackButton ?? false
            previousTrackCommand.addTarget(handler: self.previousTrackEvent)
          }

            let pauseCommand = remoteCommandCenter!.pauseCommand
            pauseCommand.isEnabled = true
            pauseCommand.addTarget(handler: self.playOrPauseEvent)

            let playCommand = remoteCommandCenter!.playCommand
            playCommand.isEnabled = true
            playCommand.addTarget(handler: self.playOrPauseEvent)

            let togglePlayPauseCommand = remoteCommandCenter!.togglePlayPauseCommand
            togglePlayPauseCommand.isEnabled = true
            togglePlayPauseCommand.addTarget(handler: self.playOrPauseEvent)
            
            if #available(iOS 9.1, *) {
                let changePlaybackPositionCommand = remoteCommandCenter!.changePlaybackPositionCommand
                changePlaybackPositionCommand.isEnabled = true
                changePlaybackPositionCommand.addTarget(handler: self.onChangePlaybackPositionCommand)
            }
        }
    }
    
    func skipBackwardEvent(skipEvent: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        let interval = (skipEvent as! MPSkipIntervalCommandEvent).interval
        log("Skip backward by %f", interval)
        
        guard let playerId = currentPlayerId else {
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        let playerInfo = players[playerId]!
        let player = playerInfo.player!
        
        let currentItem = player.currentItem!
        let currentTime = currentItem.currentTime()
        let newTime = CMTimeSubtract(currentTime, toCMTime(millis: interval))
        // if CMTime is negative, set it to zero
        let clampedTime = CMTimeGetSeconds(newTime) < 0 ? toCMTime(millis: 0) : newTime
        
        self.seek(playerId: playerId, time: clampedTime)
        return MPRemoteCommandHandlerStatus.success
    }
    
    func skipForwardEvent(skipEvent: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        let interval = (skipEvent as! MPSkipIntervalCommandEvent).interval
        log("Skip backward by %f", interval)
        
        guard let playerId = currentPlayerId else {
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        let playerInfo = players[playerId]!
        let player = playerInfo.player!
        
        let currentItem = player.currentItem!
        let currentTime = currentItem.currentTime()
        let maxDuration = currentItem.duration
        let newTime = CMTimeAdd(currentTime, toCMTime(millis: interval))
        // if CMTime is more than max duration, limit it
        let clampedTime = CMTimeGetSeconds(newTime) > CMTimeGetSeconds(maxDuration) ? maxDuration : newTime
        
        self.seek(playerId: playerId, time: clampedTime)
        return MPRemoteCommandHandlerStatus.success
    }
    
    func nextTrackEvent(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let playerId = currentPlayerId else {
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        channel.invokeMethod("audio.onGotNextTrackCommand", arguments: ["playerId": playerId])
        return MPRemoteCommandHandlerStatus.success
    }
    
    func previousTrackEvent(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let playerId = currentPlayerId else {
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        channel.invokeMethod("audio.onGotPreviousTrackCommand", arguments: ["playerId": playerId])
        return MPRemoteCommandHandlerStatus.success
    }
    
    func playOrPauseEvent(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        log("playOrPauseEvent called")

        guard let playerId = currentPlayerId else {
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        let playerInfo = players[playerId]!
        let player = playerInfo.player!
        
        let isPlaying: Bool
        let playerState: String
        
        if #available(iOS 10.0, *) {
            let status = player.timeControlStatus
            if (status == .paused) {
                // player is paused and resume it
                self.resume(playerId: playerId)
                isPlaying = true
                playerState = "playing"
            } else {
                // player is playing and pause it
                self.pause(playerId: playerId)
                isPlaying = false
                playerState = "paused"
            }
        } else {
            // No fallback on earlier versions
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        
        channel.invokeMethod("audio.onNotificationPlayerStateChanged", arguments: ["playerId": playerId, "value": isPlaying])
        if (headlessServiceInitialized) {
            callbackChannel.invokeMethod("audio.onNotificationBackgroundPlayerStateChanged", arguments: ["playerId": playerId, "updateHandleMonitorKey": updateHandleMonitorKey as Any, "value": playerState])
        }
        
        return MPRemoteCommandHandlerStatus.success
        
    }
    
    func onChangePlaybackPositionCommand(changePositionEvent: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let playerId = currentPlayerId else {
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        
        let positionTime = (changePositionEvent as! MPChangePlaybackPositionCommandEvent).positionTime
        log("changePlaybackPosition to %f", positionTime)
        let newTime: CMTime = toCMTime(millis: positionTime)
        self.seek(playerId: playerId, time: newTime)
        return MPRemoteCommandHandlerStatus.success
    }
    
    #endif
}
