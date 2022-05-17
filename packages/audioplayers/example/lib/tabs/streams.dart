import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:audioplayers_example/components/pad.dart';
import 'package:audioplayers_example/components/player_widget.dart';
import 'package:audioplayers_example/components/tab_wrapper.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class StreamsTab extends StatefulWidget {
  final AudioPlayer player;

  const StreamsTab({Key? key, required this.player}) : super(key: key);

  @override
  State<StreamsTab> createState() => _StreamsTabState();
}

class _StreamsTabState extends State<StreamsTab> {
  Duration? position, duration;
  late List<StreamSubscription> streams;

  Duration? streamDuration, streamPosition;
  PlayerState? state;

  @override
  void initState() {
    super.initState();
    streams = <StreamSubscription>[
      widget.player.onDurationChanged
          .listen((it) => setState(() => streamDuration = it)),
      widget.player.onPlayerStateChanged
          .listen((it) => setState(() => state = it)),
      widget.player.onPositionChanged
          .listen((it) => setState(() => streamPosition = it)),
      widget.player.onPlayerComplete.listen((it) => toast('Player complete!')),
      widget.player.onSeekComplete.listen((it) => toast('Seek complete!')),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    streams.forEach((it) => it.cancel());
  }

  void getPosition() async {
    final position = await widget.player.getCurrentPosition();
    setState(() => this.position = position);
  }

  void getDuration() async {
    final duration = await widget.player.getDuration();
    setState(() => this.duration = duration);
  }

  @override
  Widget build(BuildContext context) {
    return TabWrapper(
      children: [
        Row(
          children: [
            Btn(
              txt: 'getPosition',
              onPressed: getPosition,
            ),
            const Pad(width: 8.0),
            Text(position?.toString() ?? '-'),
          ],
        ),
        Row(
          children: [
            Btn(
              txt: 'getDuration',
              onPressed: getDuration,
            ),
            const Pad(width: 8.0),
            Text(duration?.toString() ?? '-'),
          ],
        ),
        const Divider(color: Colors.black),
        const Text('Streams'),
        Text('Stream Duration: $streamDuration'),
        Text('Stream Position: $streamPosition'),
        Text('Stream State: $state'),
        const Divider(color: Colors.black),
        PlayerWidget(player: widget.player),
      ],
    );
  }
}
