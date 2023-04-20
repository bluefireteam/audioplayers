import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Tgl extends StatelessWidget {
  final Map<String, String> options;
  final int selected;
  final void Function(int) onChange;

  const Tgl({
    required this.options,
    required this.selected,
    required this.onChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: options.entries
          .mapIndexed((index, element) => index == selected)
          .toList(),
      onPressed: onChange,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Theme.of(context).primaryColor,
      children: options.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                entry.value,
                key: Key(entry.key),
              ),
            ),
          )
          .toList(),
    );
  }
}

class EnumTgl<T extends Enum> extends StatelessWidget {
  final Map<String, T> options;
  final T selected;
  final void Function(T) onChange;

  const EnumTgl({
    required this.options,
    required this.selected,
    required this.onChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final optionValues = options.values.toList();
    return Tgl(
      options: options.map((key, value) => MapEntry(key, value.name)),
      selected: optionValues.indexOf(selected),
      onChange: (it) => onChange(optionValues[it]),
    );
  }
}
