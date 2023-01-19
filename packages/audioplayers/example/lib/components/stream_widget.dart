import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class StreamWidget extends StatefulWidget {
  final AudioPlayer player;

  const StreamWidget({super.key, required this.player});

  @override
  State<StreamWidget> createState() => _StreamWidgetState();
}

class _StreamWidgetState extends State<StreamWidget> {
  Duration? streamDuration, streamPosition;
  PlayerState? streamState;
  late List<StreamSubscription> streams;

  @override
  void initState() {
    super.initState();
    streams = <StreamSubscription>[
      widget.player.onDurationChanged
          .listen((it) => setState(() => streamDuration = it)),
      widget.player.onPlayerStateChanged
          .listen((it) => setState(() => streamState = it)),
      widget.player.onPositionChanged
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
        const Text('Streams'),
        ListTile(
          title: Text(
            streamDuration?.toString() ?? '-',
            key: const Key('onDurationText'),
          ),
          subtitle: const Text('Stream Duration'),
          leading: const Icon(Icons.timelapse),
        ),
        ListTile(
          title: Text(
            streamPosition?.toString() ?? '-',
            key: const Key('onPositionText'),
          ),
          subtitle: const Text('Stream Position'),
          leading: const Icon(Icons.timer),
        ),
        ListTile(
          title: Text(
            streamState?.toString() ?? '-',
            key: const Key('onStateText'),
          ),
          subtitle: const Text('Stream State'),
          leading: Icon(streamState?.getIcon() ?? Icons.stop),
        ),
      ],
    );
  }
}
