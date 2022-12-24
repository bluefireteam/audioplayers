import 'package:flutter/material.dart';

class TabWrapper extends StatelessWidget {
  final List<Widget> children;

  const TabWrapper({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: children
                .map(
                  (w) => Container(
                    padding: const EdgeInsets.all(6.0),
                    child: w,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
