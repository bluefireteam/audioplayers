import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../platform_features.dart';
import '../source_test_data.dart';
import '../test_utils.dart';

Future<void> testSourcesTab(
  WidgetTester tester,
  SourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  printOnFailure('Test Sources Tab');
  await tester.tap(find.byKey(const Key('sourcesTab')));
  await tester.pumpAndSettle();

  final sourceWidgetKey = Key('setSource-${audioSourceTestData.sourceKey}');
  await tester.scrollTo(sourceWidgetKey);
  await tester.tap(find.byKey(sourceWidgetKey));

  const sourceSetKey = Key('isSourceSet');
  await tester.scrollTo(sourceSetKey);
  await tester.waitFor(
    () => expectWidgetHasText(
      sourceSetKey,
      matcher: equals('Source is set'),
    ),
    timeout: const Duration(seconds: 180),
    stackTrace: StackTrace.current.toString(),
  );
}
