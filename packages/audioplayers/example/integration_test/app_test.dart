import 'package:audioplayers_example/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app/app_source_test_data.dart';
import 'app/tabs/context_tab.dart';
import 'app/tabs/controls_tab.dart';
import 'app/tabs/logs_tab.dart';
import 'app/tabs/source_tab.dart';
import 'app/tabs/stream_tab.dart';
import 'platform_features.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final features = PlatformFeatures.instance();
  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  group('end-to-end test', () {
    testWidgets('verify app is launched', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(
        find.text('Remote URL WAV 1'),
        findsOneWidget,
      );
    });
  });

  group('test functionality of sources', () {
    for (final audioSourceTestData in audioTestDataList) {
      testWidgets(
        'test source $audioSourceTestData',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();

          await testSourcesTab(tester, audioSourceTestData, features);
          await testControlsTab(tester, audioSourceTestData, features);
          await testStreamsTab(tester, audioSourceTestData, features);
          await testContextTab(tester, audioSourceTestData, features);
          await testLogsTab(tester, audioSourceTestData, features);
        },
        // TODO(1526): Enable flaky test for m3u8 streams on Android
        //skip: isAndroid && audioSourceTestData.isLiveStream,
      );
    }
  });
}
