import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class StreamWidget extends StatefulWidget {
  final AudioPlayer player;

  const StreamWidget({
    required this.player,
    super.key,
  });

  @override
  State<StreamWidget> createState() => _StreamWidgetState();
}

class _StreamWidgetState extends State<StreamWidget> {
  Duration? streamDuration;
  Duration? streamPosition;
  PlayerState? streamState;
  late List<StreamSubscription> streams;

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    streamState = player.state;
    player.getDuration().then((it) => setState(() => streamDuration = it));
    player.getCurrentPosition().then(
          (it) => setState(() => streamPosition = it),
        );

    streams = <StreamSubscription>[
      player.onDurationChanged
          .listen((it) => setState(() => streamDuration = it)),
      player.onPlayerStateChanged
          .listen((it) => setState(() => streamState = it)),
      player.onPositionChanged
          .listen((it) => setState(() => streamPosition = it)),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    streams.forEach((it) => it.cancel());
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(title: Text('Streams')),
        ListTile(
          title: Text(
            streamDuration?.toString() ?? '-',
            key: const Key('onDurationText'),
          ),
          subtitle: const Text('Duration Stream'),
          leading: const Icon(Icons.timelapse),
        ),
        ListTile(
          title: Text(
            streamPosition?.toString() ?? '-',
            key: const Key('onPositionText'),
          ),
          subtitle: const Text('Position Stream'),
          leading: const Icon(Icons.timer),
        ),
        ListTile(
          title: Text(
            streamState?.toString() ?? '-',
            key: const Key('onStateText'),
          ),
          subtitle: const Text('State Stream'),
          leading: Icon(streamState?.getIcon() ?? Icons.stop),
        ),
      ],
    );
  }
}
