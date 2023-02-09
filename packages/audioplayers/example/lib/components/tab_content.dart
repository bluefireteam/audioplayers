import 'package:flutter/material.dart';

class TabContent extends StatelessWidget {
  final List<Widget> children;

  const TabContent({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}
