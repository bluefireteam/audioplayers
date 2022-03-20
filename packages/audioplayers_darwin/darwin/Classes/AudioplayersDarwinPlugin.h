
#if TARGET_OS_IPHONE
    #import <Flutter/Flutter.h>

    @interface AudioplayersDarwinPlugin : NSObject<FlutterPlugin>
    @end

#elseif TARGET_OS_MAC
    #import <FlutterMacOS/FlutterMacOS.h>

    @interface AudioplayersDarwinPlugin : NSObject<FlutterPlugin>
    @end

#endif


