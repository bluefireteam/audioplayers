import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../platform_features.dart';
import '../source_test_data.dart';

Future<void> testControlsTab(
    WidgetTester tester,
    SourceTestData audioSourceTestData,
    PlatformFeatures features,
    ) async {
  // TODO(Gustl22): test volume, rate, player mode, release mode, seek
  await tester.tap(find.byKey(const Key('controlsTab')));
  await tester.pumpAndSettle();

  // await tester.tap(find.byKey(const Key('control-resume')));
  // await Future<void>.delayed(const Duration(seconds: 1));
}
//
// extension ControlsWidgetTester on WidgetTester {
//   Future<void> testDuration(SourceTestData sourceTestData) async {
//     await tap(find.byKey(const Key('getDuration')));
//     await waitFor(
//       () => expectWidgetHasText(
//         const Key('durationText'),
//         // Precision for duration:
//         // Android: hundredth of a second
//         // Windows: second
//         matcher: contains(
//           sourceTestData.duration.toString().substring(0, 8),
//         ),
//       ),
//       timeout: const Duration(seconds: 2),
//     );
//   }
//
//   Future<void> testPosition(String positionStr) async {
//     await tap(find.byKey(const Key('getPosition')));
//     await waitFor(
//       () => expectWidgetHasText(
//         const Key('positionText'),
//         matcher: contains(positionStr),
//       ),
//       timeout: const Duration(seconds: 2),
//     );
//   }
//
//   Future<void> testOnDuration(SourceTestData sourceTestData) async {
//     final durationStr = sourceTestData.duration.toString().substring(0, 8);
//     await waitFor(
//       () => expectWidgetHasText(
//         const Key('onDurationText'),
//         matcher: contains(
//           'Stream Duration: $durationStr',
//         ),
//       ),
//       stackTrace: StackTrace.current.toString(),
//     );
//   }
//
//   Future<void> testOnPosition(String positionStr) async {
//     await waitFor(
//       () => expectWidgetHasText(
//         const Key('onPositionText'),
//         matcher: contains('Stream Position: $positionStr'),
//       ),
//       stackTrace: StackTrace.current.toString(),
//     );
//   }
// }
