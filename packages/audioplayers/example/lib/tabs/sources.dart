import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

const useLocalServer = bool.fromEnvironment('USE_LOCAL_SERVER');

final localhost = kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2';
final host = useLocalServer ? 'http://$localhost:8080' : 'https://luan.xyz';

final wavUrl1 = '$host/files/audio/coins.wav';
final wavUrl2 = '$host/files/audio/laser.wav';
final mp3Url1 = '$host/files/audio/ambient_c_motion.mp3';
final mp3Url2 = '$host/files/audio/nasa_on_a_mission.mp3';
final m3u8StreamUrl = useLocalServer
    ? '$host/files/live_streams/nasa_power_of_the_rovers.m3u8'
    : 'https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_one.m3u8';
const mpgaStreamUrl = 'https://timesradio.wireless.radio/stream';

const asset1 = 'laser.wav';
const asset2 = 'nasa_on_a_mission.mp3';

class SourcesTab extends StatefulWidget {
  final AudioPlayer player;

  const SourcesTab({super.key, required this.player});

  @override
  State<SourcesTab> createState() => _SourcesTabState();
}

class _SourcesTabState extends State<SourcesTab>
    with AutomaticKeepAliveClientMixin<SourcesTab> {
  AudioPlayer get player => widget.player;

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

  Widget _createSourceTile({
    required String title,
    required String subtitle,
    required Source source,
    Key? setSourceKey,
    Key? playKey,
  }) =>
      _SourceTile(
        setSource: () => _setSource(source),
        play: () => _play(source),
        title: title,
        subtitle: subtitle,
        setSourceKey: setSourceKey,
        playKey: playKey,
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
    final bytes = await readBytes(Uri.parse(url));
    await fun(BytesSource(bytes));
  }

  Future<void> _setSourceFilePicker(Future<void> Function(Source) fun) async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path != null) {
      _setSource(DeviceFileSource(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabContent(
      children: [
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
          title: 'Remote URL MP3 1',
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
          source: AssetSource(asset1),
        ),
        _createSourceTile(
          setSourceKey: const Key('setSource-asset-mp3'),
          title: 'Asset 2',
          subtitle: 'nasa.mp3',
          source: AssetSource(asset2),
        ),
        _SourceTile(
          setSource: () => _setSourceBytesAsset(_setSource, asset: asset1),
          setSourceKey: const Key('setSource-bytes-local'),
          play: () => _setSourceBytesAsset(_play, asset: asset1),
          title: 'Bytes - Local',
          subtitle: 'laser.wav',
        ),
        _SourceTile(
          setSource: () => _setSourceBytesRemote(_setSource, url: mp3Url1),
          setSourceKey: const Key('setSource-bytes-remote'),
          play: () => _setSourceBytesRemote(_play, url: mp3Url1),
          title: 'Bytes - Remote',
          subtitle: 'ambient.mp3',
        ),
        _SourceTile(
          setSource: () => _setSourceFilePicker(_setSource),
          setSourceKey: const Key('setSource-url-local'),
          play: () => _setSourceFilePicker(_play),
          title: 'Device File',
          subtitle: 'Pick local file from device',
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
  final String title;
  final String? subtitle;
  final Key? setSourceKey;
  final Key? playKey;

  const _SourceTile({
    required this.setSource,
    required this.play,
    required this.title,
    this.subtitle,
    this.setSourceKey,
    this.playKey,
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
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            key: playKey,
            tooltip: 'Play',
            onPressed: play,
            icon: const Icon(Icons.play_arrow),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
