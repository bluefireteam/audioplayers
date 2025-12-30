import 'package:audioplayers_android/audioplayers_android.dart';
import 'package:audioplayers_android/audioplayers_android_method_channel.dart';
import 'package:audioplayers_android/audioplayers_android_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioplayersAndroidPlatform
    with MockPlatformInterfaceMixin
    implements AudioplayersAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AudioplayersAndroidPlatform initialPlatform = AudioplayersAndroidPlatform.instance;

  test('$MethodChannelAudioplayersAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioplayersAndroid>());
  });

  test('getPlatformVersion', () async {
    AudioplayersAndroid audioplayersAndroidPlugin = AudioplayersAndroid();
    MockAudioplayersAndroidPlatform fakePlatform = MockAudioplayersAndroidPlatform();
    AudioplayersAndroidPlatform.instance = fakePlatform;

    expect(await audioplayersAndroidPlugin.getPlatformVersion(), '42');
  });
}
