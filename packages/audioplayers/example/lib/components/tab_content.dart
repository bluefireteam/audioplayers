import 'package:flutter/material.dart';

class TabContent extends StatelessWidget {
  final List<Widget> children;

  const TabContent({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
