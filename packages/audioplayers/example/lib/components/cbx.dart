import 'package:flutter/material.dart';

class Cbx extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) update;

  const Cbx(
    this.label,
    this.value,
    this.update, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (v) => update(v!),
    );
  }
}
