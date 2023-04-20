import 'package:flutter/material.dart';

class Pad extends StatelessWidget {
  final double width;
  final double height;

  const Pad({super.key, this.width = 0, this.height = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
    );
  }
}
