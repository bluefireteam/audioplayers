import Flutter
import UIKit
import AVKit
import AVFoundation
    
public class SwiftAudioplayerPlugin: NSObject, FlutterPlugin {
    
    var _channel: FlutterMethodChannel
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    var duration: CMTime = CMTimeMake(0, 1)
    var position: CMTime = CMTimeMake(0, 1)
    
    var lastUrl: String?
    
    fileprivate var isPlaying: Bool = false
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bz.rxla.flutter/audio", binaryMessenger: registrar.messenger());
    let instance = SwiftAudioplayerPlugin(channel: channel);
    registrar.addMethodCallDelegate(instance, channel: channel);
  }

    init(channel:FlutterMethodChannel){
        _channel = channel
        super.init()
    }
    
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("iOS => call \(call.method)")
    
    switch (call.method) {
    case "play":
        guard let info:Dictionary = call.arguments as? Dictionary<String, Any> else {
            result(0)
            return
        }
        guard let url:String = info["url"] as? String, let isLocal:Bool = info["isLocal"] as? Bool else{
            result(0)
            return
        }
        
        togglePlay(url, isLocal: isLocal)
    case "pause":
        pause()
    case "stop":
        stop()
    case "seek":
        guard let sec:Double = call.arguments as? Double else {
            result(0)
            return
        }
        seek(sec)
    default:
        result(FlutterMethodNotImplemented)
    }
    result(1)
  }
    
    fileprivate func togglePlay(_ url: String, isLocal:Bool) {
        print( "togglePlay \(url)" )
        if url != lastUrl {
            playerItem?.removeObserver(self, forKeyPath: #keyPath(player.currentItem.status))
            NotificationCenter.default.removeObserver(onSoundComplete)

            playerItem = AVPlayerItem(url: isLocal ? URL(fileURLWithPath:url): URL(string: url)!)
            lastUrl = url

            // soundComplete handler
            NotificationCenter.default.addObserver(
                forName: Notification.Name.AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: nil, using: onSoundComplete)

            if let p = player{
                p.replaceCurrentItem(with: playerItem)
            } else {
                player = AVPlayer(playerItem: playerItem)

                // stream player position
                player!.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil, using: onTimeInterval)
            }

            // is sound ready
            player!.currentItem?.addObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: nil)
        }
        
        if isPlaying == true {
            pause()
        } else {
            updateDuration()
            player!.play()
            isPlaying = true
        }
        
    }
    
    func updateDuration(){
        print("ios -> updateDuration...")
        if let d = player?.currentItem!.duration{
            
            duration = d
            print("ios -> updateDuration... \(d)")
            if duration.seconds > 0{
                let mseconds = duration.seconds * 1000
                _channel.invokeMethod("audio.onDuration", arguments: Int(mseconds))
            }
        }
    }
    
    func onTimeInterval(time:CMTime){
        print("ios -> onTimeInterval...")
        let mseconds = time.seconds * 1000
        _channel.invokeMethod("audio.onCurrentPosition", arguments: Int(mseconds))
    }
    
    func pause() {
        player!.pause()
        isPlaying = false
    }
    
    func stop() {
        if (isPlaying) {
            player!.pause()
            player!.seek(to: CMTimeMake(0, 1))
            isPlaying = false
            print("stop")
        }
    }

    func seek(_ seconds: Double) {
        let time = CMTime.init(seconds: seconds, preferredTimescale: 1);
        playerItem?.seek(to: time);
    }
    
    func onSoundComplete(note: Notification) {
        print("ios -> onSoundComplete...")
        self.isPlaying = false
        self.player!.pause()
        self.player!.seek(to: CMTimeMake(0, 1))
        _channel.invokeMethod("audio.onComplete", arguments: nil)
    }
    
    /// player ready observer
    override open func observeValue(
        forKeyPath keyPath: String?, of object: Any?,
        change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        print("observeValue \(String(describing: keyPath))")
        if keyPath! == "player.currentItem.status" {
            if (player!.currentItem!.status == AVPlayerItemStatus.readyToPlay) {
                updateDuration()
            } else if (player!.currentItem!.status == AVPlayerItemStatus.failed) {
                _channel.invokeMethod("audio.onError", arguments: "AVPlayerItemStatus.failed")
            }
        }
    }
    
    deinit{
        if let p = player{
            p.removeTimeObserver(onTimeInterval)
            p.currentItem?.removeObserver(self, forKeyPath: #keyPath(player.currentItem.status))
            NotificationCenter.default.removeObserver(onSoundComplete)
        }
    }
}
