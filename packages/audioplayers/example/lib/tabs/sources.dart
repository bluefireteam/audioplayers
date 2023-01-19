import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:audioplayers_example/components/tgl.dart';
import 'package:audioplayers_example/main.dart';
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

enum InitMode {
  setSource,
  play,
}

class SourcesTab extends StatefulWidget {
  final PlayerUiState playerUiState;

  const SourcesTab({super.key, required this.playerUiState});

  @override
  State<SourcesTab> createState() => _SourcesTabState();
}

class _SourcesTabState extends State<SourcesTab>
    with AutomaticKeepAliveClientMixin<SourcesTab> {
  PlayerUiState get playerUiState => widget.playerUiState;

  AudioPlayer get player => widget.playerUiState.player;

  Future<void> setSource(Source source) async {
    if (playerUiState.initMode == InitMode.setSource) {
      await player.setSource(source);
      toast(
        'Completed setting source.',
        textKey: const Key('toast-source-set'),
      );
    } else {
      await player.stop();
      await player.play(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabContent(
      children: [
        EnumTgl(
          options: {for (var e in InitMode.values) 'initMode-${e.name}': e},
          selected: playerUiState.initMode,
          onChange: (InitMode m) => setState(() {
            playerUiState.initMode = m;
          }),
        ),
        Btn(
          key: const Key('setSource-url-remote-wav-1'),
          txt: 'Remote URL WAV 1 - coins.wav',
          onPressed: () => setSource(UrlSource(wavUrl1)),
        ),
        Btn(
          key: const Key('setSource-url-remote-wav-2'),
          txt: 'Remote URL WAV 2 - laser.wav',
          onPressed: () => setSource(UrlSource(wavUrl2)),
        ),
        Btn(
          key: const Key('setSource-url-remote-mp3-1'),
          txt: 'Remote URL MP3 1 - ambient_c_motion.mp3',
          onPressed: () => setSource(UrlSource(mp3Url1)),
        ),
        Btn(
          key: const Key('setSource-url-remote-mp3-2'),
          txt: 'Remote URL MP3 2 - nasa_on_a_mission.mp3',
          onPressed: () => setSource(UrlSource(mp3Url2)),
        ),
        Btn(
          key: const Key('setSource-url-remote-m3u8'),
          txt: 'Remote URL M3U8 3 - BBC stream',
          onPressed: () => setSource(UrlSource(m3u8StreamUrl)),
        ),
        Btn(
          key: const Key('setSource-url-remote-mpga'),
          txt: 'Remote URL MPGA 4 - Times stream',
          onPressed: () => setSource(UrlSource(mpgaStreamUrl)),
        ),
        Btn(
          key: const Key('setSource-asset-wav'),
          txt: 'Asset 1 - laser.wav',
          onPressed: () => setSource(AssetSource(asset1)),
        ),
        Btn(
          key: const Key('setSource-asset-mp3'),
          txt: 'Asset 2 - nasa.mp3',
          onPressed: () => setSource(AssetSource(asset2)),
        ),
        Btn(
          key: const Key('setSource-bytes-local'),
          txt: 'Bytes - Local - laser.wav',
          onPressed: () async {
            final bytes = await AudioCache.instance.loadAsBytes(asset1);
            setSource(BytesSource(bytes));
          },
        ),
        Btn(
          key: const Key('setSource-bytes-remote'),
          txt: 'Bytes - Remote - ambient.mp3',
          onPressed: () async {
            final bytes = await readBytes(Uri.parse(mp3Url1));
            setSource(BytesSource(bytes));
          },
        ),
        Btn(
          key: const Key('setSource-url-local'),
          txt: 'Pick local file',
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles();
            final path = result?.files.single.path;
            if (path != null) {
              setSource(DeviceFileSource(path));
            }
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
