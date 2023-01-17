import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:audioplayers_example/components/cbx.dart';
import 'package:audioplayers_example/components/tab_wrapper.dart';
import 'package:audioplayers_example/components/tabs.dart';
import 'package:audioplayers_example/components/tgl.dart';
import 'package:flutter/material.dart';

class AudioContextTab extends StatefulWidget {
  final AudioPlayer player;

  const AudioContextTab({super.key, required this.player});

  @override
  _AudioContextTabState createState() => _AudioContextTabState();
}

class _AudioContextTabState extends State<AudioContextTab>
    with AutomaticKeepAliveClientMixin<AudioContextTab> {
  static GlobalPlatformInterface get _global => AudioPlayer.global;

  /// Set config for all platforms
  AudioContextConfig config = AudioContextConfig();

  /// Set config for each platform individually
  AudioContext audioContext = const AudioContext();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabWrapper(
      children: [
        const Text('Audio Context'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Btn(
              txt: 'Reset',
              onPressed: () => updateConfig(AudioContextConfig()),
            ),
            Btn(
              txt: 'Global',
              onPressed: () => _global.setGlobalAudioContext(audioContext),
            ),
            Btn(
              txt: 'Local',
              onPressed: () => widget.player.setAudioContext(audioContext),
            )
          ],
        ),
        Container(
          height: 500,
          child: Tabs(
            tabs: [
              TabData(
                key: 'contextTab-genericFlags',
                label: 'Generic Flags',
                content: _genericTab(),
              ),
              TabData(
                key: 'contextTab-android',
                label: 'Android',
                content: _androidTab(),
              ),
              TabData(
                key: 'contextTab-ios',
                label: 'iOS',
                content: _iosTab(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateConfig(AudioContextConfig newConfig) {
    setState(() {
      config = newConfig;
      audioContext = config.build();
    });
  }

  void updateAudioContextAndroid(AudioContextAndroid contextAndroid) {
    setState(() {
      audioContext = audioContext.copy(android: contextAndroid);
    });
  }

  void updateAudioContextIOS(AudioContextIOS contextIOS) {
    setState(() {
      audioContext = audioContext.copy(iOS: contextIOS);
    });
  }

  Widget _genericTab() {
    return Column(
      children: [
        Cbx(
          'Force Speaker',
          config.forceSpeaker,
          (v) => updateConfig(config.copy(forceSpeaker: v)),
        ),
        Cbx(
          'Duck Audio',
          config.duckAudio,
          (v) => updateConfig(config.copy(duckAudio: v)),
        ),
        Cbx(
          'Respect Silence',
          config.respectSilence,
          (v) => updateConfig(config.copy(respectSilence: v)),
        ),
        Cbx(
          'Stay Awake',
          config.stayAwake,
          (v) => updateConfig(config.copy(stayAwake: v)),
        ),
      ],
    );
  }

  Widget _androidTab() {
    return Column(
      children: [
        Cbx(
          'isSpeakerphoneOn',
          audioContext.android.isSpeakerphoneOn,
          (v) => updateAudioContextAndroid(
            audioContext.android.copy(isSpeakerphoneOn: v),
          ),
        ),
        Cbx(
          'stayAwake',
          audioContext.android.stayAwake,
          (v) => updateAudioContextAndroid(
            audioContext.android.copy(stayAwake: v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('contentType'),
            CustomDropDown<AndroidContentType>(
              key: const Key('contentType'),
              options: {for (var e in AndroidContentType.values) e: e.name},
              selected: audioContext.android.contentType,
              onChange: (v) => updateAudioContextAndroid(
                audioContext.android.copy(contentType: v),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('usageType'),
            CustomDropDown<AndroidUsageType>(
              key: const Key('usageType'),
              options: {
                for (var e in AndroidUsageType.values) e: e.name
              },
              selected: audioContext.android.usageType,
              onChange: (v) => updateAudioContextAndroid(
                audioContext.android.copy(usageType: v),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('audioFocus'),
            CustomDropDown<AndroidAudioFocus?>(
              key: const Key('audioFocus'),
              options: {
                for (var e in AndroidAudioFocus.values)
                  e: e.name
              },
              selected: audioContext.android.audioFocus,
              onChange: (v) => updateAudioContextAndroid(
                audioContext.android.copy(audioFocus: v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iosTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('category'),
            CustomDropDown<AVAudioSessionCategory>(
              key: const Key('category'),
              options: {
                for (var e in AVAudioSessionCategory.values)
                  e: e.name
              },
              selected: audioContext.iOS.category,
              onChange: (v) => updateAudioContextIOS(
                audioContext.iOS.copy(category: v),
              ),
            ),
          ],
        ),
        getIosOptionsCbx(AVAudioSessionOptions.defaultToSpeaker),
        getIosOptionsCbx(AVAudioSessionOptions.allowAirPlay),
        getIosOptionsCbx(AVAudioSessionOptions.allowBluetooth),
        getIosOptionsCbx(AVAudioSessionOptions.allowBluetoothA2DP),
        getIosOptionsCbx(AVAudioSessionOptions.duckOthers),
        getIosOptionsCbx(
          AVAudioSessionOptions.interruptSpokenAudioAndMixWithOthers,
        ),
        getIosOptionsCbx(AVAudioSessionOptions.mixWithOthers),
        getIosOptionsCbx(
          AVAudioSessionOptions.overrideMutedMicrophoneInterruption,
        ),
      ],
    );
  }

  Widget getIosOptionsCbx(AVAudioSessionOptions option) {
    return Cbx(
      option.name,
      audioContext.iOS.options.contains(option),
      (v) {
        if (v) {
          audioContext.iOS.options.add(option);
        } else {
          audioContext.iOS.options.remove(option);
        }
        updateAudioContextIOS(
          audioContext.iOS.copy(options: audioContext.iOS.options),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
