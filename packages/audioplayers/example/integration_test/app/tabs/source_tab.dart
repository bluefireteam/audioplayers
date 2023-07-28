import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../platform_features.dart';
import '../../test_utils.dart';
import '../app_source_test_data.dart';
import '../app_test_utils.dart';

Future<void> testSourcesTab(
  WidgetTester tester,
  AppSourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  printWithTimeOnFailure('Test Sources Tab');
  await tester.tap(find.byKey(const Key('sourcesTab')));
  await tester.pumpAndSettle();

  await tester.testSource(audioSourceTestData.sourceKey);
}

extension ControlsWidgetTester on WidgetTester {
  Future<void> testSource(String sourceKey) async {
    printWithTimeOnFailure('Test setting source: $sourceKey');
    final st = StackTrace.current.toString();
    final sourceWidgetKey = Key('setSource-$sourceKey');
    await scrollToAndTap(sourceWidgetKey);

    await waitOneshot(const Key('toast-set-source'), stackTrace: st);
  }
}
