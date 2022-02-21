import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';
import '../utils.dart';

const _wavUrl1 = 'https://luan.xyz/files/audio/coins.wav';
const _wavUrl2 = 'https://luan.xyz/files/audio/laser.wav';
const _mp3Url1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
const _mp3Url2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';
const _streamUrl =
    'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p';

const _asset1 = 'laser.wav';
const _asset2 = 'nasa_on_a_mission.mp3';

class SourcesTab extends StatefulWidget {
  final AudioPlayer player;

  const SourcesTab({Key? key, required this.player}) : super(key: key);

  @override
  State<SourcesTab> createState() => _SourcesTabState();
}

class _SourcesTabState extends State<SourcesTab> {
  void setSource(Source source) async {
    await widget.player.setSource(source);
    toast('Completed setting source.');
  }

  @override
  Widget build(BuildContext context) {
    return TabWrapper(
      children: [
        Btn(
          txt: 'Remote URL WAV 1 - coins.wav',
          onPressed: () => setSource(UrlSource(_wavUrl1)),
        ),
        Btn(
          txt: 'Remote URL WAV 2 - laser.wav',
          onPressed: () => setSource(UrlSource(_wavUrl2)),
        ),
        Btn(
          txt: 'Remote URL MP3 1 - ambient_c_motion.mp3',
          onPressed: () => setSource(UrlSource(_mp3Url1)),
        ),
        Btn(
          txt: 'Remote URL MP3 2 - nasa_on_a_mission.mp3',
          onPressed: () => setSource(UrlSource(_mp3Url2)),
        ),
        Btn(
          txt: 'Remote URL 3 - BBC stream',
          onPressed: () => setSource(UrlSource(_streamUrl)),
        ),
        Btn(
          txt: 'Asset 1 - laser.wav',
          onPressed: () => setSource(AssetSource(_asset1)),
        ),
        Btn(
          txt: 'Asset 2 - nasa.mp3',
          onPressed: () => setSource(AssetSource(_asset2)),
        ),
        Btn(
          txt: 'Bytes - Local - laser.wav',
          onPressed: () async {
            final bytes = await AudioCache.instance.loadAsBytes(_asset1);
            setSource(BytesSource(bytes));
          },
        ),
        Btn(
          txt: 'Bytes - Remote - ambient.mp3',
          onPressed: () async {
            final bytes = await readBytes(Uri.parse(_mp3Url1));
            setSource(BytesSource(bytes));
          },
        ),
        // TODO(luan) add local files
      ],
    );
  }
}
