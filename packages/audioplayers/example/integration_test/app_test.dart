import 'package:audioplayers_example/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app is launched', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      print('running test!');
      expect(
        find.text(
          'Sample 1 (https://luan.xyz/files/audio/ambient_c_motion.mp3)',
        ),
        findsOneWidget,
      );
    });
  });
}
