import 'package:flutter/material.dart';

class LabeledDropDown<T> extends StatelessWidget {
  final String label;
  final Map<T, String> options;
  final T selected;
  final void Function(T?) onChange;

  const LabeledDropDown({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: CustomDropDown<T>(
        options: options,
        selected: selected,
        onChange: onChange,
      ),
    );
  }
}

class CustomDropDown<T> extends StatelessWidget {
  final Map<T, String> options;
  final T selected;
  final void Function(T?) onChange;
  final bool isExpanded;

  const CustomDropDown({
    super.key,
    required this.options,
    required this.selected,
    required this.onChange,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      isExpanded: isExpanded,
      value: selected,
      onChanged: onChange,
      items: options.entries
          .map<DropdownMenuItem<T>>(
            (entry) => DropdownMenuItem<T>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
    );
  }
}
