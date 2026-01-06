import 'package:audioplayers_android/audioplayers_android_platform_interface.dart';

class AudioplayersAndroid {
  Future<String?> getPlatformVersion() {
    return AudioplayersAndroidPlatform.instance.getPlatformVersion();
  }
}
