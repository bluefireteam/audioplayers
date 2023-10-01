import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

extension LibWidgetTester on WidgetTester {
  Future<void> pumpLinux() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      // FIXME(gustl22): Linux needs additional pump (#1556)
      await pump();
    }
  }
}
