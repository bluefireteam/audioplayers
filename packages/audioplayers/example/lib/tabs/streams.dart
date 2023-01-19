import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/player_widget.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class StreamsTab extends StatefulWidget {
  final AudioPlayer player;

  const StreamsTab({super.key, required this.player});

  @override
  State<StreamsTab> createState() => _StreamsTabState();
}

class _StreamsTabState extends State<StreamsTab>
    with AutomaticKeepAliveClientMixin<StreamsTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabContent(
      children: [
        _PropertiesWidget(player: widget.player),
        const Divider(color: Colors.black),
        _StreamsWidget(player: widget.player),
        const Divider(color: Colors.black),
        PlayerWidget(player: widget.player),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _StreamsWidget extends StatefulWidget {
  final AudioPlayer player;

  const _StreamsWidget({required this.player});

  @override
  State<_StreamsWidget> createState() => _StreamsWidgetState();
}

class _StreamsWidgetState extends State<_StreamsWidget> {
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

class _PropertiesWidget extends StatefulWidget {
  final AudioPlayer player;

  const _PropertiesWidget({required this.player});

  @override
  State<_PropertiesWidget> createState() => _PropertiesWidgetState();
}

class _PropertiesWidgetState extends State<_PropertiesWidget> {
  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Properties'),
        ListTile(
          title: FutureBuilder<Duration?>(
            future: widget.player.getDuration(),
            builder: (context, snap) {
              return Text(
                snap.data?.toString() ?? '-',
                key: const Key('durationText'),
              );
            },
          ),
          subtitle: const Text('Duration'),
          leading: const Icon(Icons.timelapse),
        ),
        ListTile(
          title: FutureBuilder<Duration?>(
            future: widget.player.getCurrentPosition(),
            builder: (context, snap) {
              return Text(
                snap.data?.toString() ?? '-',
                key: const Key('positionText'),
              );
            },
          ),
          subtitle: const Text('Position'),
          leading: const Icon(Icons.timer),
        ),
        ListTile(
          title: Text(
            widget.player.state.toString(),
            key: const Key('playerStateText'),
          ),
          subtitle: const Text('State'),
          leading: Icon(widget.player.state.getIcon()),
        ),
        ListTile(
          title: Text(
            widget.player.source?.toString() ?? '-',
            key: const Key('sourceText'),
          ),
          subtitle: const Text('Source'),
          leading: const Icon(Icons.audio_file),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          key: const Key('refreshButton'),
          label: const Text('Refresh'),
          onPressed: refresh,
        ),
      ],
    );
  }
}
