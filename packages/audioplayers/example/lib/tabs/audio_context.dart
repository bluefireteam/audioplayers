import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/cbx.dart';
import 'package:audioplayers_example/components/drop_down.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:audioplayers_example/components/tabs.dart';
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

  AudioPlayer get player => widget.player;

  /// Set config for all platforms
  AudioContextConfig audioContextConfig = AudioContextConfig();

  /// Set config for each platform individually
  AudioContext audioContext = const AudioContext();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const ListTile(title: Text('Audio Context')),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.undo),
              label: const Text('Reset'),
              onPressed: () => updateConfig(AudioContextConfig()),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.public),
              label: const Text('Global'),
              onPressed: () => _global.setGlobalAudioContext(audioContext),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.looks_one),
              label: const Text('Local'),
              onPressed: () => player.setAudioContext(audioContext),
            )
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
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
      audioContextConfig = newConfig;
      audioContext = audioContextConfig.build();
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
    return TabContent(
      children: [
        Cbx(
          'Force Speaker',
          audioContextConfig.forceSpeaker,
          (v) => updateConfig(audioContextConfig.copy(forceSpeaker: v)),
        ),
        Cbx(
          'Duck Audio',
          audioContextConfig.duckAudio,
          (v) => updateConfig(audioContextConfig.copy(duckAudio: v)),
        ),
        Cbx(
          'Respect Silence',
          audioContextConfig.respectSilence,
          (v) => updateConfig(audioContextConfig.copy(respectSilence: v)),
        ),
        Cbx(
          'Stay Awake',
          audioContextConfig.stayAwake,
          (v) => updateConfig(audioContextConfig.copy(stayAwake: v)),
        ),
      ],
    );
  }

  Widget _androidTab() {
    return TabContent(
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
        LabeledDropDown<AndroidContentType>(
          label: 'contentType',
          key: const Key('contentType'),
          options: {for (var e in AndroidContentType.values) e: e.name},
          selected: audioContext.android.contentType,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(contentType: v),
          ),
        ),
        LabeledDropDown<AndroidUsageType>(
          label: 'usageType',
          key: const Key('usageType'),
          options: {for (var e in AndroidUsageType.values) e: e.name},
          selected: audioContext.android.usageType,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(usageType: v),
          ),
        ),
        LabeledDropDown<AndroidAudioFocus?>(
          key: const Key('audioFocus'),
          label: 'audioFocus',
          options: {for (var e in AndroidAudioFocus.values) e: e.name},
          selected: audioContext.android.audioFocus,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(audioFocus: v),
          ),
        ),
        LabeledDropDown<AndroidAudioMode>(
          key: const Key('audioMode'),
          label: 'audioMode',
          options: {for (var e in AndroidAudioMode.values) e: e.name},
          selected: audioContext.android.audioMode,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(audioMode: v),
          ),
        ),
      ],
    );
  }

  Widget _iosTab() {
    final iosOptions = AVAudioSessionOptions.values
        .map(
          (option) => Cbx(
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
          ),
        )
        .toList();
    return TabContent(
      children: <Widget>[
        LabeledDropDown<AVAudioSessionCategory>(
          key: const Key('category'),
          label: 'category',
          options: {for (var e in AVAudioSessionCategory.values) e: e.name},
          selected: audioContext.iOS.category,
          onChange: (v) => updateAudioContextIOS(
            audioContext.iOS.copy(category: v),
          ),
        ),
        ...iosOptions
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
