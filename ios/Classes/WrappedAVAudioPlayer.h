#import <Foundation/Foundation.h>
#import "PlayerProtocol.h"
#import <AVFoundation/AVFoundation.h>

@interface WrappedAVAudioPlayer : NSObject <AVAudioPlayerDelegate, PlayerProtocol>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSString* playerId;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSMutableSet* observers;
@property (nonatomic) bool looping;

@end