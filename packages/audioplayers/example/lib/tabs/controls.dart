import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:audioplayers_example/components/list_tile.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:audioplayers_example/components/tgl.dart';
import 'package:audioplayers_example/components/txt.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class ControlsTab extends StatefulWidget {
  final AudioPlayer player;

  const ControlsTab({
    required this.player,
    super.key,
  });

  @override
  State<ControlsTab> createState() => _ControlsTabState();
}

class _ControlsTabState extends State<ControlsTab>
    with AutomaticKeepAliveClientMixin<ControlsTab> {
  String modalInputSeek = '';

  Future<void> _update(Future<void> Function() fn) async {
    await fn();
    // update everyone who listens to "player"
    setState(() {});
  }

  Future<void> _seekPercent(double percent) async {
    final duration = await widget.player.getDuration();
    if (duration == null) {
      toast(
        'Failed to get duration for proportional seek.',
        textKey: const Key('toast-proportional-seek-duration-null'),
      );
      return;
    }
    final position = duration * percent;
    _seekDuration(position);
  }

  Future<void> _seekDuration(Duration position) async {
    await _update(
      () => widget.player.seek(position),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabContent(
      children: [
        WrappedListTile(
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
        WrappedListTile(
          leading: const Text('Volume'),
          children: [0.0, 0.5, 1.0, 2.0].map((it) {
            final formattedVal = it.toStringAsFixed(1);
            return Btn(
              key: Key('control-volume-$formattedVal'),
              txt: formattedVal,
              onPressed: () => widget.player.setVolume(it),
            );
          }).toList(),
        ),
        WrappedListTile(
          leading: const Text('Balance'),
          children: [-1.0, -0.5, 0.0, 1.0].map((it) {
            final formattedVal = it.toStringAsFixed(1);
            return Btn(
              key: Key('control-balance-$formattedVal'),
              txt: formattedVal,
              onPressed: () => widget.player.setBalance(it),
            );
          }).toList(),
        ),
        WrappedListTile(
          leading: const Text('Rate'),
          children: [0.0, 0.5, 1.0, 2.0].map((it) {
            final formattedVal = it.toStringAsFixed(1);
            return Btn(
              key: Key('control-rate-$formattedVal'),
              txt: formattedVal,
              onPressed: () => widget.player.setPlaybackRate(it),
            );
          }).toList(),
        ),
        WrappedListTile(
          leading: const Text('Player Mode'),
          children: [
            EnumTgl<PlayerMode>(
              key: const Key('control-player-mode'),
              options: {
                for (final e in PlayerMode.values)
                  'control-player-mode-${e.name}': e,
              },
              selected: widget.player.mode,
              onChange: (playerMode) async {
                await _update(() => widget.player.setPlayerMode(playerMode));
              },
            ),
          ],
        ),
        WrappedListTile(
          leading: const Text('Release Mode'),
          children: [
            EnumTgl<ReleaseMode>(
              key: const Key('control-release-mode'),
              options: {
                for (final e in ReleaseMode.values)
                  'control-release-mode-${e.name}': e,
              },
              selected: widget.player.releaseMode,
              onChange: (releaseMode) async {
                await _update(
                  () => widget.player.setReleaseMode(releaseMode),
                );
              },
            ),
          ],
        ),
        WrappedListTile(
          leading: const Text('Seek'),
          children: [
            ...[0.0, 0.5, 1.0].map((it) {
              final formattedVal = it.toStringAsFixed(1);
              return Btn(
                key: Key('control-seek-$formattedVal'),
                txt: formattedVal,
                onPressed: () => _seekPercent(it),
              );
            }),
            Btn(
              txt: 'Custom',
              onPressed: () async {
                dialog(
                  _SeekDialog(
                    value: modalInputSeek,
                    setValue: (it) => setState(() => modalInputSeek = it),
                    seekDuration: () => _seekDuration(
                      Duration(
                        milliseconds: int.parse(modalInputSeek),
                      ),
                    ),
                    seekPercent: () => _seekPercent(
                      double.parse(modalInputSeek),
                    ),
                  ),
                );
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

class _SeekDialog extends StatelessWidget {
  final VoidCallback seekDuration;
  final VoidCallback seekPercent;
  final void Function(String val) setValue;
  final String value;

  const _SeekDialog({
    required this.seekDuration,
    required this.seekPercent,
    required this.value,
    required this.setValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Pick a duration and unit to seek'),
        TxtBox(
          value: value,
          onChange: setValue,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Btn(
              txt: 'millis',
              onPressed: () {
                Navigator.of(context).pop();
                seekDuration();
              },
            ),
            Btn(
              txt: 'seconds',
              onPressed: () {
                Navigator.of(context).pop();
                seekDuration();
              },
            ),
            Btn(
              txt: '%',
              onPressed: () {
                Navigator.of(context).pop();
                seekPercent();
              },
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
