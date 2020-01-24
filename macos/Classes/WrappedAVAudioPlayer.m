#import "WrappedAVAudioPlayer.h"

@implementation WrappedAVAudioPlayer

@synthesize player = _player;
@synthesize playerId = _playerId;
@synthesize url = _url;
@synthesize observers = _observers;
@synthesize looping = _looping;

- (id)init:(NSString*)playerId {
    self = [super init];
    if (self) {
        _observers = [[NSMutableSet alloc] init];
        _url = @"";
        _playerId = playerId;
        _looping = false;
    }
    return self;
}

- (void) play {
    NSLog(@"PLAY!!!");
    if (_player) [_player play];
}
- (void) pause {
    if (_player) [_player pause];
}
- (void) stop {
    if (_player) [_player stop];
}
- (void) resume {
    if (_player) [_player play];
}
- (void) seek: (NSTimeInterval) time {
    if (_player) [_player playAtTime:time];
}
- (int) getDuration {
    return _player ? (int)(_player.duration * 1000.0) : 0;
}

- (void) setNewURL: (NSString*) newUrl {
    NSLog(@"URL!!!  %@", newUrl);
    if (_player && [_url isEqualToString: newUrl]) {
        return;
    }
    else {
        _url = newUrl;
        NSData *data = [NSData dataWithContentsOfFile:_url];
        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        [_player prepareToPlay];
    }
}
- (void) setNewURL: (NSString*) newUrl onReady:(void(^)(NSObject<PlayerProtocol> *p))onReady {
    NSLog(@"URL with CALLBACK!!!  %@", newUrl);
    if (_player && [_url isEqualToString: newUrl]) {
        onReady(self);
    }
    else {
        _url = newUrl;
        NSData *data = [NSData dataWithContentsOfFile:_url];
        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        _player.delegate = self;
        BOOL ready = [_player prepareToPlay];
        [self setLooping:_looping];
        if (ready) onReady(self);
    }
}
- (void) setVolume: (double) newVol {
    NSLog(@"VOLUME!!!");
    if (_player) [_player setVolume:newVol fadeDuration:0.2];
}
- (void) setLooping: (bool) newLoop {
    _looping = newLoop;
    if (_player) _player.numberOfLoops = newLoop ? -1 : 0;
}
- (bool) isPlaying {
    if (_player) return _player.isPlaying;
    return false;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player 
                       successfully:(BOOL)flag
                       {

                       }
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player 
                                 error:(NSError *)error;
                                 {

                                 }
@end
