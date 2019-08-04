#import "AudioplayersPlugin.h"
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

static NSString *const CHANNEL_NAME = @"xyz.luan/audioplayers";

static NSMutableDictionary * players;

@interface AudioplayersPlugin()
-(void) pause: (NSString *) playerId;
-(void) stop: (NSString *) playerId;
-(void) seek: (NSString *) playerId time: (CMTime) time;
-(void) onSoundComplete: (NSString *) playerId;
-(void) setRate: (double)rate :(NSString *) playerId;
-(void) updateDuration: (NSString *) playerId;
-(void) onTimeInterval: (NSString *) playerId time: (CMTime) time;
@property double rate;
@property NSString * playerId ;
@end

@implementation AudioplayersPlugin {
  FlutterResult _result;
}

typedef void (^VoidCallback)(NSString * playerId);

NSMutableSet *timeobservers;
FlutterMethodChannel *_channel_audioplayer;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:CHANNEL_NAME
                                   binaryMessenger:[registrar messenger]];
  AudioplayersPlugin* instance = [[AudioplayersPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  _channel_audioplayer = channel;
}

- (id)init {
  self = [super init];
  if (self) {
      players = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  self.playerId = call.arguments[@"playerId"];
  NSLog(@"iOS => call %@, playerId %@", call.method, self.playerId);

  typedef void (^CaseBlock)(void);

  // Squint and this looks like a proper switch!
  NSDictionary *methods = @{
                @"play":
                  ^{
                    NSLog(@"play!");
                    NSString *url = call.arguments[@"url"];
                    if (url == nil)
                        result(0);
                    if (call.arguments[@"isLocal"] == nil)
                        result(0);
                    if (call.arguments[@"volume"] == nil)
                        result(0);
                    if (call.arguments[@"position"] == nil)
                        result(0);
                    if (call.arguments[@"respectSilence"] == nil)
                        result(0);
                    int isLocal = [call.arguments[@"isLocal"]intValue] ;
                    float volume = (float)[call.arguments[@"volume"] doubleValue] ;
                    int milliseconds = call.arguments[@"position"] == [NSNull null] ? 0.0 : [call.arguments[@"position"] intValue] ;
                    bool respectSilence = [call.arguments[@"respectSilence"]boolValue] ;
                    CMTime time = CMTimeMakeWithSeconds(milliseconds / 1000,NSEC_PER_SEC);
                    NSLog(@"isLocal: %d %@", isLocal, call.arguments[@"isLocal"] );
                    NSLog(@"volume: %f %@", volume, call.arguments[@"volume"] );
                    NSLog(@"position: %d %@", milliseconds, call.arguments[@"positions"] );
                    [self play:self.playerId url:url isLocal:isLocal volume:volume time:time isNotification:respectSilence];
                  },
                @"pause":
                  ^{
                    NSLog(@"pause");
                    [self pause:self.playerId];
                  },
                @"resume":
                  ^{
                    NSLog(@"resume");
                    [self resume:self.playerId];
                  },
                @"stop":
                  ^{
                    NSLog(@"stop");
                    [self stop:self.playerId];
                  },
                @"release":
                    ^{
                        NSLog(@"release");
                        [self stop:self.playerId];
                    },
                @"setRate":
                    ^{
                        NSNumber* rateNumber = call.arguments[@"rate"];
                        double rate = [rateNumber doubleValue];
                        [self setRate: rate:self.playerId];
                    },
                @"seek":
                  ^{
                    NSLog(@"seek");
                    if (!call.arguments[@"position"]) {
                      result(0);
                    } else {
                      int milliseconds = [call.arguments[@"position"] intValue];
                      NSLog(@"Seeking to: %d milliseconds", milliseconds);
                      [self seek:self.playerId time:CMTimeMakeWithSeconds(milliseconds / 1000,NSEC_PER_SEC)];
                    }
                  },
                @"setUrl":
                  ^{
                    NSLog(@"setUrl");
                    NSString *url = call.arguments[@"url"];
                    int isLocal = [call.arguments[@"isLocal"]intValue];
                    [ self setUrl:url
                          isLocal:isLocal
                          playerId:self.playerId
                          onReady:^(NSString * playerId) {
                            result(@(1));
                          }
                    ];
                  },
                @"getDuration":
                    ^{
                        
                        int duration = [self getDuration:self.playerId];
                        NSLog(@"getDuration: %i ", duration);
                        result(@(duration));
                    },
				@"getCurrentPosition":
                    ^{
                        int currentPosition = [self getCurrentPosition:self.playerId];
                        NSLog(@"getCurrentPosition: %i ", currentPosition);
                        result(@(currentPosition));
                    },
                @"setVolume":
                  ^{
                    NSLog(@"setVolume");
                    float volume = (float)[call.arguments[@"volume"] doubleValue];
                    [self setVolume:volume playerId:self.playerId];
                  },
                @"setReleaseMode":
                  ^{
                    NSLog(@"setReleaseMode");
                    NSString *releaseMode = call.arguments[@"releaseMode"];
                    bool looping = [releaseMode hasSuffix:@"LOOP"];
                    [self setLooping:looping playerId:self.playerId];
                  }
                };

  [ self initPlayerInfo:self.playerId ];
  CaseBlock c = methods[call.method];
  if (c) c(); else {
    NSLog(@"not implemented");
    result(FlutterMethodNotImplemented);
  }
  if(![call.method isEqualToString:@"setUrl"]) {
    result(@(1));
  }
}

-(void) initPlayerInfo: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];
  if (!playerInfo) {
    players[playerId] = [@{@"isPlaying": @false, @"volume": @(1.0), @"looping": @(false)} mutableCopy];
  }
}

-(void) setUrl: (NSString*) url
       isLocal: (bool) isLocal
      playerId: (NSString*) playerId
       onReady:(VoidCallback)onReady
{
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];
    NSMutableSet *observers = playerInfo[@"observers"];
    AVPlayerItem *playerItem;
    
    NSLog(@"setUrl %@", url);
    
    if (!playerInfo || ![url isEqualToString:playerInfo[@"url"]]) {
        if (isLocal) {
            playerItem = [ [ AVPlayerItem alloc ] initWithURL:[ NSURL fileURLWithPath:url ]];
        } else {
            playerItem = [ [ AVPlayerItem alloc ] initWithURL:[ NSURL URLWithString:url ]];
        }
        
        if (playerInfo[@"url"]) {
            [[player currentItem] removeObserver:self forKeyPath:@"player.currentItem.status" ];
            
            [ playerInfo setObject:url forKey:@"url" ];
            
            for (id ob in observers) {
                [ [ NSNotificationCenter defaultCenter ] removeObserver:ob ];
            }
            [ observers removeAllObjects ];
            [ player replaceCurrentItemWithPlayerItem: playerItem ];
        } else {
            player = [[ AVPlayer alloc ] initWithPlayerItem: playerItem ];
            observers = [[NSMutableSet alloc] init];
            
            [ playerInfo setObject:player forKey:@"player" ];
            [ playerInfo setObject:url forKey:@"url" ];
            [ playerInfo setObject:observers forKey:@"observers" ];
            
            // playerInfo = [@{@"player": player, @"url": url, @"isPlaying": @false, @"observers": observers, @"volume": @(1.0), @"looping": @(false)} mutableCopy];
            // players[playerId] = playerInfo;
            
            // stream player position
            CMTime interval = CMTimeMakeWithSeconds(0.2, NSEC_PER_SEC);
            id timeObserver = [ player  addPeriodicTimeObserverForInterval: interval queue: nil usingBlock:^(CMTime time){
                [self onTimeInterval:playerId time:time];
            }];
            [timeobservers addObject:@{@"player":player, @"observer":timeObserver}];
            
            
            
            
            
            // 直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
            MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
            // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
            commandCenter.playCommand.enabled = YES;
            // 为播放命令添加响应事件, 在点击后触发
            [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                [self resume:playerId];
                return MPRemoteCommandHandlerStatusSuccess;
            }];
            // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
            [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                //点击了暂停
                [self pause:playerId];
                return MPRemoteCommandHandlerStatusSuccess;
            }];
            [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                //点击了上一首
                
                return MPRemoteCommandHandlerStatusSuccess;
            }];
            [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                //点击了下一首
                
                return MPRemoteCommandHandlerStatusSuccess;
            }];
            // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
            commandCenter.togglePlayPauseCommand.enabled = YES;
            // 为耳机的按钮操作添加相关的响应事件
            [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                // 进行播放/暂停的相关操作 (耳机的播放/暂停按钮)
                
                return MPRemoteCommandHandlerStatusSuccess;
            }];
        }
      
    id anobserver = [[ NSNotificationCenter defaultCenter ] addObserverForName: AVPlayerItemDidPlayToEndTimeNotification
                                                                        object: playerItem
                                                                         queue: nil
                                                                    usingBlock:^(NSNotification* note){
                                                                        [self onSoundComplete:playerId];
                                                                    }];
    [observers addObject:anobserver];
      
    // is sound ready
    [playerInfo setObject:onReady forKey:@"onReady"];
    [playerItem addObserver:self
                          forKeyPath:@"player.currentItem.status"
                          options:0
                          context:(void*)playerId];
      
  } else {
    if ([[player currentItem] status ] == AVPlayerItemStatusReadyToPlay) {
      onReady(playerId);
    }
  }
}

-(void) play: (NSString*) playerId
         url: (NSString*) url
     isLocal: (int) isLocal
      volume: (float) volume
        time: (CMTime) time
      isNotification: (bool) respectSilence
{
    NSError *error = nil;
    AVAudioSessionCategory category;
    if (respectSilence) {
        category = AVAudioSessionCategoryAmbient;
    } else {
        category = AVAudioSessionCategoryPlayback;
    }
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: category
                    error:&error];
  if (!success) {
    NSLog(@"Error setting speaker: %@", error);
  }
  [[AVAudioSession sharedInstance] setActive:YES error:&error];
  __weak AudioplayersPlugin *self_ = self;
  [ self setUrl:url 
         isLocal:isLocal 
         playerId:playerId 
         onReady:^(NSString * playerId) {
           NSMutableDictionary * playerInfo = players[playerId];
           AVPlayer *player = playerInfo[@"player"];
           [ player setVolume:volume ];
           [ player seekToTime:time ];
           [ player play];
           [ playerInfo setObject:@true forKey:@"isPlaying" ];
           
           [ self_ setRate: self_.rate:playerId];

         }    
  ];
}

-(void) updateDuration: (NSString *) playerId
{
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];

  CMTime duration = [[[player currentItem]  asset] duration];
  NSLog(@"ios -> updateDuration...%f", CMTimeGetSeconds(duration));
  if(CMTimeGetSeconds(duration)>0){
    NSLog(@"ios -> invokechannel");
   int mseconds= CMTimeGetSeconds(duration)*1000;
    [_channel_audioplayer invokeMethod:@"audio.onDuration" arguments:@{@"playerId": playerId, @"value": @(mseconds)}];
  }
}

-(int) getDuration: (NSString *) playerId {
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];
    
   CMTime duration = [[[player currentItem]  asset] duration];
    int mseconds= CMTimeGetSeconds(duration)*1000;
    return mseconds;
}

-(int) getCurrentPosition: (NSString *) playerId {
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];
    
    CMTime duration = [player currentTime];
    int mseconds= CMTimeGetSeconds(duration)*1000;
    return mseconds;
}

// No need to spam the logs with every time interval update
-(void) onTimeInterval: (NSString *) playerId
                  time: (CMTime) time {
    // NSLog(@"ios -> onTimeInterval...");
    int mseconds =  CMTimeGetSeconds(time)*1000;
    // NSLog(@"asdff %@ - %d", playerId, mseconds);
    [_channel_audioplayer invokeMethod:@"audio.onCurrentPosition" arguments:@{@"playerId": playerId, @"value": @(mseconds)}];
    //    NSLog(@"asdff end");
}

-(void) pause: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];

  [ player pause ];
  [playerInfo setObject:@false forKey:@"isPlaying"];
}

-(void) resume: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  [player play];
  [self setRate: self.rate:playerId];
  [playerInfo setObject:@true forKey:@"isPlaying"];
}

-(void) setVolume: (float) volume 
        playerId:  (NSString *) playerId {
  NSMutableDictionary *playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  playerInfo[@"volume"] = @(volume);
  [ player setVolume:volume ];
}

-(void) setLooping: (bool) looping
        playerId:  (NSString *) playerId {
  NSMutableDictionary *playerInfo = players[playerId];
  [playerInfo setObject:@(looping) forKey:@"looping"];
}

-(void) stop: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];

  if ([playerInfo[@"isPlaying"] boolValue]) {
    [ self pause:playerId ];
    [ self seek:playerId time:CMTimeMake(0, 1) ];
    [playerInfo setObject:@false forKey:@"isPlaying"];
  }
}

-(void) seek: (NSString *) playerId
        time: (CMTime) time {
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  [[player currentItem] seekToTime:time];
}

-(void) onSoundComplete: (NSString *) playerId {
  NSLog(@"ios -> onSoundComplete...");
  NSMutableDictionary * playerInfo = players[playerId];

  if (![playerInfo[@"isPlaying"] boolValue]) {
    return;
  }

  [ self pause:playerId ];
  [ self seek:playerId time:CMTimeMakeWithSeconds(0,1) ];

  if ([ playerInfo[@"looping"] boolValue]) {
    [ self resume:playerId ];
  }

  [ _channel_audioplayer invokeMethod:@"audio.onComplete" arguments:@{@"playerId": playerId}];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
  if ([keyPath isEqualToString: @"player.currentItem.status"]) {
    NSString *playerId = (__bridge NSString*)context;
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];

    NSLog(@"player status: %ld",(long)[[player currentItem] status ]);

    // Do something with the status...
    if ([[player currentItem] status ] == AVPlayerItemStatusReadyToPlay) {
      [self updateDuration:playerId];

      VoidCallback onReady = playerInfo[@"onReady"];
      if (onReady != nil) {
        [playerInfo removeObjectForKey:@"onReady"];  
        onReady(playerId);
      }
    } else if ([[player currentItem] status ] == AVPlayerItemStatusFailed) {
      [_channel_audioplayer invokeMethod:@"audio.onError" arguments:@{@"playerId": playerId, @"value": @"AVPlayerItemStatus.failed"}];
    }
  } else {
    // Any unrecognized context must belong to super
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
  }
}


- (void)setRate:(double)rate :(NSString *) playerId  {
    if(rate==0)return;
    self.rate=rate;
    NSLog(@"setRate %f",self.rate);
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];
    if(player != nil){
        player.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain;
        player.rate = self.rate;
    }
}


- (void)dealloc {
  for (id value in timeobservers)
    [value[@"player"] removeTimeObserver:value[@"observer"]];
  timeobservers = nil;

  for (NSString* playerId in players) {
      NSMutableDictionary * playerInfo = players[playerId];
      NSMutableSet * observers = playerInfo[@"observers"];
      for (id ob in observers)
        [[NSNotificationCenter defaultCenter] removeObserver:ob];
  }
  players = nil;
}


@end

