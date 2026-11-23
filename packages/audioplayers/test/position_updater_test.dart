import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FramePositionUpdater', () {
    testWidgets(
      'start() is idempotent and does not stack frame-callback chains',
      (tester) async {
        var positionCalls = 0;
        final updater = FramePositionUpdater(
          getPosition: () async {
            positionCalls++;
            return Duration.zero;
          },
        );

        // Simulate AudioPlayer.resume() being called repeatedly on a player
        // that is already playing: each call invokes start().
        updater.start();
        updater.start();
        updater.start();

        // Let the initial scheduling settle, then count calls per frame.
        await tester.pump(const Duration(milliseconds: 16));
        positionCalls = 0;

        const frames = 5;
        for (var i = 0; i < frames; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        updater.stop();
        await updater.dispose();

        // A single running chain calls getPosition exactly once per frame.
        // Without an idempotency guard, every extra start() adds another
        // chain, multiplying the per-frame platform calls.
        expect(positionCalls, frames);
      },
    );
  });
}
