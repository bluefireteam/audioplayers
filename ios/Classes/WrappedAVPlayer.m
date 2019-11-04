#import "WrappedAVPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation WrappedAVPlayer

@synthesize player = _player;
@synthesize playerId = _playerId;
@synthesize url = _url;
@synthesize looping = _looping;
@synthesize observers = _observers;

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
    if (_player) [_player play];
}
- (void) pause {
    if (_player) [_player pause];
}
- (void) stop {
    if (_player) [_player pause];
    [self seek:0];
}
- (void) resume {
    if (_player) [_player play];
}
- (void) seek: (NSTimeInterval) time {
    if (_player) [[_player currentItem] seekToTime:CMTimeMakeWithSeconds(time, 1)];
}
- (int) getDuration {
    int mseconds = 0;
    if (_player) {
        CMTime duration = [[[_player currentItem] asset] duration];
        mseconds = CMTimeGetSeconds(duration)*1000;
    }
    return mseconds;
}
- (void) setNewURL: (NSString*) newUrl {
    if (_player && [newUrl isEqualToString:_url]) {
        return;
    }
    else {
        _url = newUrl;
        AVPlayerItem *playerItem;
        //if (isLocal) {
            playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:_url]];
        //}
        //else {
        //    playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:_url]];
        //}
        if (_player) {
            [_player replaceCurrentItemWithPlayerItem:playerItem];
        } else {
            _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        }
    }
}
- (void) setNewURL: (NSString*) newUrl onReady:(void(^)(NSObject<PlayerProtocol> *p))onReady {
    if (_player && [newUrl isEqualToString:_url]) {
        onReady(self);
    }
    else {
        _url = newUrl;
        AVPlayerItem *playerItem;
        //if (isLocal) {
            playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:_url]];
        //}
        //else {
        //    playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:_url]];
        //}
        if (_player) {
            [_player replaceCurrentItemWithPlayerItem:playerItem];
        } else {
            _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        }
        onReady(self);
    }
}
- (void) setVolume: (double) newVol {
    if (_player) [_player setVolume:newVol];
}
- (void) setLooping: (bool) newLoop {
    _looping = newLoop;
}
- (bool) isPlaying {
    if (_player && _player.timeControlStatus == AVPlayerTimeControlStatusPlaying) return YES;
    return NO;
}

@end
