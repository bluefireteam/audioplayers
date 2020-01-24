#ifndef PlayerProtocol_h
#define PlayerProtocol_h

@protocol PlayerProtocol <NSObject>
@required
@property (nonatomic, strong) NSString* playerId;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSMutableSet* observers;

- (id)init:(NSString*)playerId;
- (void) play;
- (void) pause;
- (void) stop;
- (void) resume;
- (void) seek: (NSTimeInterval) time;
- (int) getDuration;
- (void) setNewURL: (NSString*) newUrl;
- (void) setNewURL: (NSString*) newUrl onReady:(void(^)(NSObject<PlayerProtocol> *p))onReady;
- (void) setVolume: (double) newVol;
- (void) setLooping: (bool) newLoop;
- (bool) isPlaying;
@end

#endif /* PlayerProtocol_h */
