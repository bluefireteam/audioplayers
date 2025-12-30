import 'package:audioplayers_example/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Test', () {
    testWidgets('verify app startup and title', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('AudioPlayers example'), findsOneWidget);
    });
  });
}