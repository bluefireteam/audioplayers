import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/player_widget.dart';
import 'package:audioplayers_example/components/properties_widget.dart';
import 'package:audioplayers_example/components/stream_widget.dart';
import 'package:audioplayers_example/components/tab_content.dart';
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
        PropertiesWidget(player: widget.player),
        const Divider(color: Colors.black),
        StreamWidget(player: widget.player),
        const Divider(color: Colors.black),
        PlayerWidget(player: widget.player),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
