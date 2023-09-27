import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:audioplayers_example/components/drop_down.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const useLocalServer = bool.fromEnvironment('USE_LOCAL_SERVER');

final localhost = kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2';
final host = useLocalServer ? 'http://$localhost:8080' : 'https://luan.xyz';

final wavUrl1 = '$host/files/audio/coins.wav';
final wavUrl2 = '$host/files/audio/laser.wav';
final wavUrl3 = '$host/files/audio/coins_non_ascii_и.wav';
final mp3Url1 = '$host/files/audio/ambient_c_motion.mp3';
final mp3Url2 = '$host/files/audio/nasa_on_a_mission.mp3';
final m3u8StreamUrl = useLocalServer
    ? '$host/files/live_streams/nasa_power_of_the_rovers.m3u8'
    : 'https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_one.m3u8';
final mpgaStreamUrl = useLocalServer
    ? '$host/stream/mpeg'
    : 'https://timesradio.wireless.radio/stream';

const wavAsset = 'laser.wav';
const mp3Asset = 'nasa_on_a_mission.mp3';
const invalidAsset = 'invalid.txt';
const specialCharAsset = 'coins_non_ascii_и.wav';

class SourcesTab extends StatefulWidget {
  final AudioPlayer player;

  const SourcesTab({
    required this.player,
    super.key,
  });

  @override
  State<SourcesTab> createState() => _SourcesTabState();
}

class _SourcesTabState extends State<SourcesTab>
    with AutomaticKeepAliveClientMixin<SourcesTab> {
  AudioPlayer get player => widget.player;

  final List<Widget> sourceWidgets = [];

  Future<void> _setSource(Source source) async {
    await player.setSource(source);
    toast(
      'Completed setting source.',
      textKey: const Key('toast-set-source'),
    );
  }

  Future<void> _play(Source source) async {
    await player.stop();
    await player.play(source);
    toast(
      'Set and playing source.',
      textKey: const Key('toast-set-play'),
    );
  }

  Future<void> _removeSourceWidget(Widget sourceWidget) async {
    setState(() {
      sourceWidgets.remove(sourceWidget);
    });
    toast('Source removed.');
  }

  Widget _createSourceTile({
    required String title,
    required String subtitle,
    required Source source,
    Key? setSourceKey,
    Color? buttonColor,
    Key? playKey,
  }) =>
      _SourceTile(
        setSource: () => _setSource(source),
        play: () => _play(source),
        removeSource: _removeSourceWidget,
        title: title,
        subtitle: subtitle,
        setSourceKey: setSourceKey,
        playKey: playKey,
        buttonColor: buttonColor,
      );

  Future<void> _setSourceBytesAsset(
    Future<void> Function(Source) fun, {
    required String asset,
  }) async {
    final bytes = await AudioCache.instance.loadAsBytes(asset);
    await fun(BytesSource(bytes));
  }

  Future<void> _setSourceBytesRemote(
    Future<void> Function(Source) fun, {
    required String url,
  }) async {
    final bytes = await http.readBytes(Uri.parse(url));
    await fun(BytesSource(bytes));
  }

  @override
  void initState() {
    super.initState();
    sourceWidgets.addAll(
      [
        _createSourceTile(
          setSourceKey: const Key('setSource-url-remote-wav-1'),
          title: 'Remote URL WAV 1',
          subtitle: 'coins.wav',
          source: UrlSource(wavUrl1),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-url-remote-wav-2'),
          title: 'Remote URL WAV 2',
          subtitle: 'laser.wav',
          source: UrlSource(wavUrl2),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-url-remote-mp3-1'),
          title: 'Remote URL MP3 1 (VBR)',
          subtitle: 'ambient_c_motion.mp3',
          source: UrlSource(mp3Url1),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-url-remote-mp3-2'),
          title: 'Remote URL MP3 2',
          subtitle: 'nasa_on_a_mission.mp3',
          source: UrlSource(mp3Url2),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-url-remote-m3u8'),
          title: 'Remote URL M3U8',
          subtitle: 'BBC stream',
          source: UrlSource(m3u8StreamUrl),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-url-remote-mpga'),
          title: 'Remote URL MPGA',
          subtitle: 'Times stream',
          source: UrlSource(mpgaStreamUrl),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-asset-wav'),
          title: 'Asset 1',
          subtitle: 'laser.wav',
          source: AssetSource(wavAsset),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-asset-mp3'),
          title: 'Asset 2',
          subtitle: 'nasa.mp3',
          source: AssetSource(mp3Asset),
        ),
        _SourceTile(
          setSource: () => _setSourceBytesAsset(_setSource, asset: wavAsset),
          setSourceKey: const Key('setSource-bytes-local'),
          play: () => _setSourceBytesAsset(_play, asset: wavAsset),
          removeSource: _removeSourceWidget,
          title: 'Bytes - Local',
          subtitle: 'laser.wav',
        ),
        _SourceTile(
          setSource: () => _setSourceBytesRemote(_setSource, url: mp3Url1),
          setSourceKey: const Key('setSource-bytes-remote'),
          play: () => _setSourceBytesRemote(_play, url: mp3Url1),
          removeSource: _removeSourceWidget,
          title: 'Bytes - Remote',
          subtitle: 'ambient.mp3',
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-asset-invalid'),
          title: 'Invalid Asset',
          subtitle: 'invalid.txt',
          source: AssetSource(invalidAsset),
          buttonColor: Colors.red,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        TabContent(
          children: sourceWidgets
              .expand((element) => [element, const Divider()])
              .toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              dialog(
                _SourceDialog(
                  onAdd: (Source source, String path) {
                    setState(() {
                      sourceWidgets.add(
                        _createSourceTile(
                          title: source.runtimeType.toString(),
                          subtitle: path,
                          source: source,
                        ),
                      );
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SourceTile extends StatelessWidget {
  final void Function() setSource;
  final void Function() play;
  final void Function(Widget sourceWidget) removeSource;
  final String title;
  final String? subtitle;
  final Key? setSourceKey;
  final Key? playKey;
  final Color? buttonColor;

  const _SourceTile({
    required this.setSource,
    required this.play,
    required this.removeSource,
    required this.title,
    this.subtitle,
    this.setSourceKey,
    this.playKey,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Set Source',
            key: setSourceKey,
            onPressed: setSource,
            icon: const Icon(Icons.upload_file),
            color: buttonColor ?? Theme.of(context).primaryColor,
          ),
          IconButton(
            key: playKey,
            tooltip: 'Play',
            onPressed: play,
            icon: const Icon(Icons.play_arrow),
            color: buttonColor ?? Theme.of(context).primaryColor,
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => removeSource(this),
            icon: const Icon(Icons.delete),
            color: buttonColor ?? Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

class _SourceDialog extends StatefulWidget {
  final void Function(Source source, String path) onAdd;

  const _SourceDialog({required this.onAdd});

  @override
  State<_SourceDialog> createState() => _SourceDialogState();
}

class _SourceDialogState extends State<_SourceDialog> {
  Type sourceType = UrlSource;
  String path = '';

  final Map<String, String> assetsList = {'': 'Nothing selected'};

  @override
  void initState() {
    super.initState();

    AssetManifest.loadFromAssetBundle(rootBundle).then((assetManifest) {
      setState(() {
        assetsList.addAll(
          assetManifest
              .listAssets()
              .map((e) => e.replaceFirst('assets/', ''))
              .toList()
              .asMap()
              .map((key, value) => MapEntry(value, value)),
        );
      });
    });
  }

  Widget _buildSourceValue() {
    switch (sourceType) {
      case AssetSource:
        return Row(
          children: [
            const Text('Asset path'),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropDown<String>(
                options: assetsList,
                selected: path,
                onChange: (value) => setState(() {
                  path = value ?? '';
                }),
              ),
            ),
          ],
        );
      case BytesSource:
      case DeviceFileSource:
        return Row(
          children: [
            const Text('Device File path'),
            const SizedBox(width: 16),
            Expanded(child: Text(path)),
            TextButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                final path = result?.files.single.path;
                if (path != null) {
                  setState(() {
                    this.path = path;
                  });
                }
              },
              icon: const Icon(Icons.file_open),
              label: const Text('Browse'),
            ),
          ],
        );
      default:
        return Row(
          children: [
            const Text('URL'),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'https://example.com/myFile.wav',
                ),
                onChanged: (String? url) => path = url ?? '',
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabeledDropDown<Type>(
          label: 'Source type',
          options: const {
            AssetSource: 'Asset',
            DeviceFileSource: 'Device File',
            UrlSource: 'Url',
            BytesSource: 'Byte array',
          },
          selected: sourceType,
          onChange: (Type? value) {
            setState(() {
              if (value != null) {
                sourceType = value;
              }
            });
          },
        ),
        ListTile(title: _buildSourceValue()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Btn(
              onPressed: () async {
                switch (sourceType) {
                  case BytesSource:
                    widget.onAdd(
                      BytesSource(await File(path).readAsBytes()),
                      path,
                    );
                  case AssetSource:
                    widget.onAdd(AssetSource(path), path);
                  case DeviceFileSource:
                    widget.onAdd(DeviceFileSource(path), path);
                  default:
                    widget.onAdd(UrlSource(path), path);
                }
                Navigator.of(context).pop();
              },
              txt: 'Add',
            ),
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
