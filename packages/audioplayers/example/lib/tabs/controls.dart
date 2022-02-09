import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';
import '../components/tgl.dart';

class ControlsTab extends StatelessWidget {
  final AudioPlayer player;

  const ControlsTab({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabWrapper(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Btn(txt: 'Pause', onPressed: player.pause),
            Btn(txt: 'Stop', onPressed: player.stop),
            Btn(txt: 'Resume', onPressed: player.resume),
            Btn(txt: 'Release', onPressed: player.release),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Volume'),
            ...[0.0, 0.5, 1.0, 2.0].map((it) {
              return Btn(
                txt: it.toString(),
                onPressed: () => player.setVolume(it),
              );
            }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Rate'),
            ...[0.0, 0.5, 1.0, 2.0].map((it) {
              return Btn(
                txt: it.toString(),
                onPressed: () => player.setPlaybackRate(it),
              );
            }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Player Mode'),
            EnumTgl<PlayerMode>(
              options: PlayerMode.values,
              selected: player.mode,
              onChange: player.setPlayerMode,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Release Mode'),
            EnumTgl<ReleaseMode>(
              options: ReleaseMode.values,
              selected: player.releaseMode,
              onChange: player.setReleaseMode,
            ),
          ],
        ),
        // TODO(luan): add seek
      ],
    );
  }
}
