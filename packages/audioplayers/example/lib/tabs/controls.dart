import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:audioplayers_example/components/tab_wrapper.dart';
import 'package:audioplayers_example/components/tgl.dart';
import 'package:audioplayers_example/components/txt.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class ControlsTab extends StatefulWidget {
  final AudioPlayer player;

  const ControlsTab({Key? key, required this.player}) : super(key: key);

  @override
  State<ControlsTab> createState() => _ControlsTabState();
}

class _ControlsTabState extends State<ControlsTab>
    with AutomaticKeepAliveClientMixin<ControlsTab> {
  String modalInputSeek = '';

  Future<void> update(Future<void> Function() fn) async {
    await fn();
    // update everyone who listens to "player"
    setState(() {});
  }

  Future<void> seekPercent(double percent) async {
    final duration = await widget.player.getDuration();
    if (duration == null) {
      toast('Failed to get duration for proportional seek.');
      return;
    }
    final position = duration * percent;
    seekDuration(position);
  }

  Future<void> seekDuration(Duration duration) async {
    update(() => widget.player.seek(duration));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabWrapper(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Btn(
              key: const Key('control-pause'),
              txt: 'Pause',
              onPressed: widget.player.pause,
            ),
            Btn(
              key: const Key('control-stop'),
              txt: 'Stop',
              onPressed: widget.player.stop,
            ),
            Btn(
              key: const Key('control-resume'),
              txt: 'Resume',
              onPressed: widget.player.resume,
            ),
            Btn(
              key: const Key('control-release'),
              txt: 'Release',
              onPressed: widget.player.release,
            ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Seek'),
            ...[0.0, 0.5, 1.0].map((it) {
              return Btn(
                txt: it.toString(),
                onPressed: () => seekPercent(it),
              );
            }),
            Btn(
              txt: 'Custom',
              onPressed: () async {
                dialog([
                  const Text('Pick a duration and unit to seek'),
                  TxtBox(
                    value: modalInputSeek,
                    onChange: (it) => setState(() => modalInputSeek = it),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Btn(
                        txt: 'millis',
                        onPressed: () {
                          Navigator.of(context).pop();
                          seekDuration(
                            Duration(
                              milliseconds: int.parse(modalInputSeek),
                            ),
                          );
                        },
                      ),
                      Btn(
                        txt: 'seconds',
                        onPressed: () {
                          Navigator.of(context).pop();
                          seekDuration(
                            Duration(
                              seconds: int.parse(modalInputSeek),
                            ),
                          );
                        },
                      ),
                      Btn(
                        txt: '%',
                        onPressed: () {
                          Navigator.of(context).pop();
                          seekPercent(double.parse(modalInputSeek));
                        },
                      ),
                      Btn(
                        txt: 'Cancel',
                        onPressed: Navigator.of(context).pop,
                      ),
                    ],
                  ),
                ]);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
