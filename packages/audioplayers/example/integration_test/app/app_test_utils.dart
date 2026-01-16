import 'package:audioplayers_example/components/tgl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

extension AppWidgetTester on WidgetTester {
  /// Wait until appearance and disappearance
  Future<void> waitOneshot(
    Key key, {
    Duration timeout = const Duration(seconds: 180),
    String? stackTrace,
  }) async {
    await waitFor(
      () async => expect(
        find.byKey(key),
        findsOneWidget,
      ),
      timeout: timeout,
      pollInterval: const Duration(milliseconds: 100),
      stackTrace: stackTrace,
    );
    await waitFor(
      () async => expect(
        find.byKey(key),
        findsNothing,
      ),
      stackTrace: stackTrace,
    );
  }

  Future<void> scrollToAndTap(Key widgetKey) async {
    await scrollTo(widgetKey);
    await tap(find.byKey(widgetKey));
  }

  Future<void> scrollTo(Key widgetKey) async {
    final finder = find.byKey(widgetKey);
    if (finder.hitTestable().evaluate().isEmpty) {
      await scrollUntilVisible(
        finder,
        100,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await pump();
  }
}

void expectWidgetHasText(
  Key key, {
  required Matcher matcher,
  bool skipOffstage = true,
}) {
  final widget =
      find.byKey(key, skipOffstage: skipOffstage).evaluate().single.widget;
  if (widget is Text) {
    expect(widget.data, matcher);
  } else {
    throw 'Widget with key $key is not a Widget of type "Text"';
  }
}

void expectWidgetHasDuration(
  Key key, {
  required dynamic matcher,
  bool skipOffstage = true,
}) {
  final widget =
      find.byKey(key, skipOffstage: skipOffstage).evaluate().single.widget;
  if (widget is Text) {
    final regexp = RegExp(r'\d+:\d{2}:\d{2}.\d{6}');
    final match = regexp.firstMatch(widget.data ?? '');
    final duration = _parseDuration(match?.group(0));
    expect(duration, matcher);
  } else {
    throw 'Widget with key $key is not a Widget of type "Text"';
  }
}

/// Parse Duration string to Duration
Duration? _parseDuration(String? s) {
  if (s == null || s.isEmpty) {
    return null;
  }
  var hours = 0;
  var minutes = 0;
  var micros = 0;
  final parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

void expectEnumToggleHasSelected(
  Key key, {
  required Matcher matcher,
  bool skipOffstage = true,
}) {
  final widget =
      find.byKey(key, skipOffstage: skipOffstage).evaluate().single.widget;
  if (widget is EnumTgl) {
    expect(widget.selected, matcher);
  } else {
    throw 'Widget with key $key is not a Widget of type "EnumTgl"';
  }
}

void expectToggleHasSelected(
  Key key, {
  required Matcher matcher,
  bool skipOffstage = true,
}) {
  final widget =
      find.byKey(key, skipOffstage: skipOffstage).evaluate().single.widget;
  if (widget is Tgl) {
    expect(widget.selected, matcher);
  } else {
    throw 'Widget with key $key is not a Widget of type "Tgl"';
  }
}
