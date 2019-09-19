#import "AudioplayersPlugin.h"
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerProtocol.h"
#import "WrappedAVAudioPlayer.h"
#import "WrappedAVPlayer.h"

static NSString *const CHANNEL_NAME = @"xyz.luan/audioplayers";
NSString *const AudioplayersPluginStop = @"AudioplayersPluginStop";

static NSMutableDictionary * players;

@interface AudioplayersPlugin()
-(NSObject<PlayerProtocol> *) initPlayer: (NSString*)playerId mode:(NSString*)mode local:(bool)local;
-(void) onSoundComplete: (NSString *) playerId;
-(void) updateDuration: (NSString *) playerId;
-(void) onTimeInterval: (NSString *) playerId time: (CMTime) time;
@end

@implementation AudioplayersPlugin {
  FlutterResult _result;
}

typedef void (^VoidCallback)(NSString * playerId);

NSMutableSet *timeobservers;
FlutterMethodChannel *_channel_audioplayer;
bool _isDealloc = false;

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
      _isDealloc = false;
      players = [[NSMutableDictionary alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needStop) name:AudioplayersPluginStop object:nil];
  }
  return self;
}
    
- (void)needStop {
    _isDealloc = true;
    [self destory];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString * playerId = call.arguments[@"playerId"];
  NSLog(@"iOS => call %@, playerId %@", call.method, playerId);
  NSString *mode = call.arguments[@"mode"];
  int isLocal = [call.arguments[@"isLocal"] intValue];
  NSLog(@"Player local value: %d", isLocal);
  typedef void (^CaseBlock)(void);
  NSObject<PlayerProtocol> *player = [self initPlayer:playerId mode:mode local:isLocal];
  NSLog(@"Player created!");

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
        double volume = (float)[call.arguments[@"volume"] doubleValue];
        int milliseconds = call.arguments[@"position"] == [NSNull null] ? 0 : [call.arguments[@"position"] intValue];
        bool respectSilence = [call.arguments[@"respectSilence"] boolValue];
        CMTime time = CMTimeMakeWithSeconds(milliseconds / 1000,NSEC_PER_SEC);
        [self setSessionCategory: [call.arguments[@"respectSilence"] boolValue]];
        NSLog(@"going to setNewURL");
        [player setNewURL: url onReady:^(){
          NSLog(@"going to setVolume");
          [player setVolume: volume];
          NSLog(@"going to play");
          [player play];
        }];
      },
    @"pause":
      ^{
        NSLog(@"pause");
        [player pause];
      },
    @"resume":
      ^{
        NSLog(@"resume");
        [player resume];
      },
    @"stop":
      ^{
        NSLog(@"stop");
        [player stop];
      },
    @"release":
      ^{
        NSLog(@"release");
        [player stop];
      },
    @"seek":
      ^{
        NSLog(@"seek");
        if (!call.arguments[@"position"]) {
          result(0);
        } else {
          int milliseconds = [call.arguments[@"position"] intValue];
          NSLog(@"Seeking to: %d milliseconds", milliseconds);
          [player seek:((double)milliseconds)/1000];
        }
      },
    @"setUrl":
      ^{
        NSLog(@"setUrl");
        NSString *url = call.arguments[@"url"];
        [player setNewURL:url];
      },
    @"getDuration":
      ^{
        int duration = [player getDuration];
        NSLog(@"getDuration: %i ", duration);
        result(@(duration));
      },
    @"setVolume":
      ^{
        NSLog(@"setVolume");
        double volume = (float)[call.arguments[@"volume"] doubleValue];
        [player setVolume:volume];
      },
    @"setReleaseMode":
      ^{
        NSLog(@"setReleaseMode");
        NSString *releaseMode = call.arguments[@"releaseMode"];
        bool looping = [releaseMode hasSuffix:@"LOOP"];
        [player setLooping:looping];
      }
    };

  CaseBlock c = methods[call.method];
  if (c) c(); else {
    NSLog(@"not implemented");
    result(FlutterMethodNotImplemented);
  }
  if(![call.method isEqualToString:@"setUrl"]) {
    result(@(1));
  }
}

- (NSObject<PlayerProtocol> *) initPlayer: (NSString*)playerId mode:(NSString*)mode local:(bool)local {
  NSObject<PlayerProtocol> *player = players[playerId];
  if (player == nil) {
    if ([mode caseInsensitiveCompare:@"PlayerMode.MEDIA_PLAYER"] == NSOrderedSame || !local) {
      NSLog(@"AVPlayer mode: %@, local: %d", mode, local);
      player = [[WrappedAVPlayer alloc] init];
    } else {
      NSLog(@"AVAudioPlayer mode: %@, local: %d", mode, local);
      player = [[WrappedAVAudioPlayer alloc] init];
    }
    players[playerId] = player;
  }
  return player;
}

- (void) setSessionCategory: (bool)respectSilence {
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
}


-(void) updateDuration: (NSString *) playerId
{
  NSMutableDictionary * playerInfo = players[playerId];
  AVAudioPlayer *player = playerInfo[@"player"];

  NSTimeInterval duration = player.duration;
  NSLog(@"ios -> updateDuration...%f", duration);
  if(duration>0){
    NSLog(@"ios -> invokechannel");
   //int mseconds= duration*1000;
    //[_channel_audioplayer invokeMethod:@"audio.onDuration" arguments:@{@"playerId": playerId, @"value": @(mseconds)}];
  }
}

// No need to spam the logs with every time interval update
-(void) onTimeInterval: (NSString *) playerId
                  time: (CMTime) time {
    // NSLog(@"ios -> onTimeInterval...");
    if (_isDealloc) {
        return;
    }
    int mseconds =  CMTimeGetSeconds(time)*1000;
    // NSLog(@"asdff %@ - %d", playerId, mseconds);
    
    [_channel_audioplayer invokeMethod:@"audio.onCurrentPosition" arguments:@{@"playerId": playerId, @"value": @(mseconds)}];
    
    //    NSLog(@"asdff end");
}

-(void) onSoundComplete: (NSString *) playerId {
  NSLog(@"ios -> onSoundComplete...");
  NSMutableDictionary * playerInfo = players[playerId];

  if (![playerInfo[@"isPlaying"] boolValue]) {
    return;
  }

  //[ self pause:playerId ];
  //[ self seek:playerId time:0 ];

  //if ([ playerInfo[@"looping"] boolValue]) {
  //  [ self resume:playerId ];
  //}

  [ _channel_audioplayer invokeMethod:@"audio.onComplete" arguments:@{@"playerId": playerId}];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
  if ([keyPath isEqualToString: @"player.currentItem.status"]) {
    NSString *playerId = (__bridge NSString*)context;
    NSMutableDictionary * playerInfo = players[playerId];
    AVAudioPlayer *player = playerInfo[@"player"];

    //NSLog(@"player status: %ld",(long)[[player currentItem] status ]);

    // Do something with the status...
    if (player.data != NULL) {
      [self updateDuration:playerId];

      VoidCallback onReady = playerInfo[@"onReady"];
      if (onReady != nil) {
        [playerInfo removeObjectForKey:@"onReady"];  
        onReady(playerId);
      }
    } else if (player.data == NULL) {
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

- (void)destory {
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
    
- (void)dealloc {
    [self destory];
}


@end

