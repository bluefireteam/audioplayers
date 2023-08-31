import 'package:flutter_test/flutter_test.dart';

import '../../platform_features.dart';
import '../../test_utils.dart';
import '../app_source_test_data.dart';

Future<void> testLogsTab(
  WidgetTester tester,
  AppSourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  printWithTimeOnFailure('Test Logs Tab');
  // TODO(Gustl22): may test logs
  // await tester.tap(find.byKey(const Key('loggerTab')));
  // await tester.pumpAndSettle();
}
