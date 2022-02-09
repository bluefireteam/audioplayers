import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';
import '../components/tgl.dart';

class ControlsTab extends StatefulWidget {
  final AudioPlayer player;

  const ControlsTab({Key? key, required this.player}) : super(key: key);

  @override
  State<ControlsTab> createState() => _ControlsTabState();
}

class _ControlsTabState extends State<ControlsTab> {
  void update(Future<void> Function() fn) async {
    await fn();
    // update everyone who listens to "player"
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TabWrapper(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Btn(txt: 'Pause', onPressed: widget.player.pause),
            Btn(txt: 'Stop', onPressed: widget.player.stop),
            Btn(txt: 'Resume', onPressed: widget.player.resume),
            Btn(txt: 'Release', onPressed: widget.player.release),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Volume'),
            ...[0.0, 0.5, 1.0, 2.0].map((it) {
              return Btn(
                txt: it.toString(),
                onPressed: () => widget.player.setVolume(it),
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
                onPressed: () => widget.player.setPlaybackRate(it),
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
              selected: widget.player.mode,
              onChange: (playerMode) {
                update(() => widget.player.setPlayerMode(playerMode));
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Release Mode'),
            EnumTgl<ReleaseMode>(
              options: ReleaseMode.values,
              selected: widget.player.releaseMode,
              onChange: (releaseMode) {
                update(() => widget.player.setReleaseMode(releaseMode));
              },
            ),
          ],
        ),
        // TODO(luan): add seek
      ],
    );
  }
}
