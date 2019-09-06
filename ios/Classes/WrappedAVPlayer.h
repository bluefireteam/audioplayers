#import <Foundation/Foundation.h>
#import "PlayerProtocol.h"
#import <AVFoundation/AVFoundation.h>

@interface WrappedAVPlayer : NSObject <PlayerProtocol>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSString* playerId;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSMutableSet* observers;
@property bool looping;

@end