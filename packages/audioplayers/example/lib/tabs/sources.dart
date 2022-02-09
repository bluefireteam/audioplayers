import 'package:flutter/material.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';

const _url1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
const _url2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';
const _url3 = 'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p';

const _asset1 = 'audio.mp3';

class SourcesTab extends StatelessWidget {
  final void Function(String, {bool isLocal}) setSourceUrl;

  const SourcesTab({Key? key, required this.setSourceUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabWrapper(
      children: [
        Btn(
          txt: 'Remote URL 1 - ambient_c_motion.mp3',
          onPressed: () => setSourceUrl(_url1, isLocal: false),
        ),
        Btn(
          txt: 'Remote URL 2 - nasa_on_a_mission.mp3',
          onPressed: () => setSourceUrl(_url2, isLocal: false),
        ),
        Btn(
          txt: 'Remote URL 3 - BBC stream',
          onPressed: () => setSourceUrl(_url3, isLocal: false),
        ),
        Btn(
          txt: 'Local File 1 - audio.mp3',
          onPressed: () => setSourceUrl(_asset1, isLocal: true),
        ),
        // local files, bytes, audio cache, etc
      ],
    );
  }
}
