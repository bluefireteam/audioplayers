import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';

const _wavUrl1 = 'https://luan.xyz/files/audio/coins.wav';
const _wavUrl2 = 'https://luan.xyz/files/audio/laser.wav';
const _mp3Url1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
const _mp3Url2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';
const _streamUrl =
    'https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_one.m3u8';

const _asset1 = 'laser.wav';
const _asset2 = 'nasa_on_a_mission.mp3';

class SourcesTab extends StatefulWidget {
  final AudioPlayer player;

  const SourcesTab({Key? key, required this.player}) : super(key: key);

  @override
  State<SourcesTab> createState() => _SourcesTabState();
}

class _SourcesTabState extends State<SourcesTab>
    with AutomaticKeepAliveClientMixin<SourcesTab> {
  bool isSourceSet = false;

  void setSource(Source source) async {
    setState(() => isSourceSet = false);
    await widget.player.setSource(source);
    setState(() => isSourceSet = true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabWrapper(
      children: [
        Text(
          isSourceSet ? 'Source is set' : 'Source is not set',
          key: const Key('isSourceSet'),
        ),
        Btn(
          key: const Key('setSource-url-remote-wav-1'),
          txt: 'Remote URL WAV 1 - coins.wav',
          onPressed: () => setSource(UrlSource(_wavUrl1)),
        ),
        Btn(
          key: const Key('setSource-url-remote-wav-2'),
          txt: 'Remote URL WAV 2 - laser.wav',
          onPressed: () => setSource(UrlSource(_wavUrl2)),
        ),
        Btn(
          key: const Key('setSource-url-remote-mp3-1'),
          txt: 'Remote URL MP3 1 - ambient_c_motion.mp3',
          onPressed: () => setSource(UrlSource(_mp3Url1)),
        ),
        Btn(
          key: const Key('setSource-url-remote-mp3-2'),
          txt: 'Remote URL MP3 2 - nasa_on_a_mission.mp3',
          onPressed: () => setSource(UrlSource(_mp3Url2)),
        ),
        Btn(
          key: const Key('setSource-url-remote-m3u8'),
          txt: 'Remote URL 3 - BBC stream',
          onPressed: () => setSource(UrlSource(_streamUrl)),
        ),
        Btn(
          key: const Key('setSource-asset-wav'),
          txt: 'Asset 1 - laser.wav',
          onPressed: () => setSource(AssetSource(_asset1)),
        ),
        Btn(
          key: const Key('setSource-asset-mp3'),
          txt: 'Asset 2 - nasa.mp3',
          onPressed: () => setSource(AssetSource(_asset2)),
        ),
        Btn(
          key: const Key('setSource-bytes-local'),
          txt: 'Bytes - Local - laser.wav',
          onPressed: () async {
            final bytes = await AudioCache.instance.loadAsBytes(_asset1);
            setSource(BytesSource(bytes));
          },
        ),
        Btn(
          key: const Key('setSource-bytes-remote'),
          txt: 'Bytes - Remote - ambient.mp3',
          onPressed: () async {
            final bytes = await readBytes(Uri.parse(_mp3Url1));
            setSource(BytesSource(bytes));
          },
        ),
        // TODO(luan) add local files via file picker
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
