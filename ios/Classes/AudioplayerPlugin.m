#import "AudioplayerPlugin.h"
#import <audioplayer/audioplayer-Swift.h>

@implementation AudioplayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioplayerPlugin registerWithRegistrar:registrar];
}
@end
