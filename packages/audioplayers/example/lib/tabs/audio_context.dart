import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/cbx.dart';
import 'package:audioplayers_example/components/drop_down.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:audioplayers_example/components/tabs.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class AudioContextTab extends StatefulWidget {
  final AudioPlayer player;

  const AudioContextTab({
    required this.player,
    super.key,
  });

  @override
  AudioContextTabState createState() => AudioContextTabState();
}

class AudioContextTabState extends State<AudioContextTab>
    with AutomaticKeepAliveClientMixin<AudioContextTab> {
  static GlobalAudioScope get _global => AudioPlayer.global;

  AudioPlayer get player => widget.player;

  /// Set config for all platforms
  AudioContextConfig audioContextConfig = AudioContextConfig();

  /// Set config for each platform individually
  AudioContext audioContext = AudioContext();

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
              onPressed: () => _global.setAudioContext(audioContext),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.looks_one),
              label: const Text('Local'),
              onPressed: () => player.setAudioContext(audioContext),
            ),
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
    try {
      final context = newConfig.build();
      setState(() {
        audioContextConfig = newConfig;
        audioContext = context;
      });
    } on AssertionError catch (e) {
      toast(e.message.toString());
    }
  }

  void updateAudioContextAndroid(AudioContextAndroid contextAndroid) {
    setState(() {
      audioContext = audioContext.copy(android: contextAndroid);
    });
  }

  void updateAudioContextIOS(AudioContextIOS Function() buildContextIOS) {
    try {
      final context = buildContextIOS();
      setState(() {
        audioContext = audioContext.copy(iOS: context);
      });
    } on AssertionError catch (e) {
      toast(e.message.toString());
    }
  }

  Widget _genericTab() {
    return TabContent(
      children: [
        LabeledDropDown<AudioContextConfigRoute>(
          label: 'Audio Route',
          key: const Key('audioRoute'),
          options: {for (final e in AudioContextConfigRoute.values) e: e.name},
          selected: audioContextConfig.route,
          onChange: (v) => updateConfig(
            audioContextConfig.copy(route: v),
          ),
        ),
        LabeledDropDown<AudioContextConfigFocus>(
          label: 'Audio Focus',
          key: const Key('audioFocus'),
          options: {for (final e in AudioContextConfigFocus.values) e: e.name},
          selected: audioContextConfig.focus,
          onChange: (v) => updateConfig(
            audioContextConfig.copy(focus: v),
          ),
        ),
        Cbx(
          'Respect Silence',
          value: audioContextConfig.respectSilence,
          ({value}) =>
              updateConfig(audioContextConfig.copy(respectSilence: value)),
        ),
        Cbx(
          'Stay Awake',
          value: audioContextConfig.stayAwake,
          ({value}) => updateConfig(audioContextConfig.copy(stayAwake: value)),
        ),
      ],
    );
  }

  Widget _androidTab() {
    return TabContent(
      children: [
        Cbx(
          'isSpeakerphoneOn',
          value: audioContext.android.isSpeakerphoneOn,
          ({value}) => updateAudioContextAndroid(
            audioContext.android.copy(isSpeakerphoneOn: value),
          ),
        ),
        Cbx(
          'stayAwake',
          value: audioContext.android.stayAwake,
          ({value}) => updateAudioContextAndroid(
            audioContext.android.copy(stayAwake: value),
          ),
        ),
        LabeledDropDown<AndroidContentType>(
          label: 'contentType',
          key: const Key('contentType'),
          options: {for (final e in AndroidContentType.values) e: e.name},
          selected: audioContext.android.contentType,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(contentType: v),
          ),
        ),
        LabeledDropDown<AndroidUsageType>(
          label: 'usageType',
          key: const Key('usageType'),
          options: {for (final e in AndroidUsageType.values) e: e.name},
          selected: audioContext.android.usageType,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(usageType: v),
          ),
        ),
        LabeledDropDown<AndroidAudioFocus?>(
          key: const Key('audioFocus'),
          label: 'audioFocus',
          options: {for (final e in AndroidAudioFocus.values) e: e.name},
          selected: audioContext.android.audioFocus,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(audioFocus: v),
          ),
        ),
        LabeledDropDown<AndroidAudioMode>(
          key: const Key('audioMode'),
          label: 'audioMode',
          options: {for (final e in AndroidAudioMode.values) e: e.name},
          selected: audioContext.android.audioMode,
          onChange: (v) => updateAudioContextAndroid(
            audioContext.android.copy(audioMode: v),
          ),
        ),
      ],
    );
  }

  Widget _iosTab() {
    final iosOptions = AVAudioSessionOptions.values.map(
      (option) {
        final options = {...audioContext.iOS.options};
        return Cbx(
          option.name,
          value: options.contains(option),
          ({value}) {
            updateAudioContextIOS(() {
              final iosContext = audioContext.iOS.copy(options: options);
              if (value ?? false) {
                options.add(option);
              } else {
                options.remove(option);
              }
              return iosContext;
            });
          },
        );
      },
    ).toList();
    return TabContent(
      children: <Widget>[
        LabeledDropDown<AVAudioSessionCategory>(
          key: const Key('category'),
          label: 'category',
          options: {for (final e in AVAudioSessionCategory.values) e: e.name},
          selected: audioContext.iOS.category,
          onChange: (v) => updateAudioContextIOS(
            () => audioContext.iOS.copy(category: v),
          ),
        ),
        ...iosOptions,
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
