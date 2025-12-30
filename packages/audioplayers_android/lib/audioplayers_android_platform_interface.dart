import 'package:audioplayers_android/audioplayers_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AudioplayersAndroidPlatform extends PlatformInterface {
  /// Constructs a AudioplayersAndroidPlatform.
  AudioplayersAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioplayersAndroidPlatform _instance = MethodChannelAudioplayersAndroid();

  /// The default instance of [AudioplayersAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioplayersAndroid].
  static AudioplayersAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioplayersAndroidPlatform] when
  /// they register themselves.
  static set instance(AudioplayersAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
