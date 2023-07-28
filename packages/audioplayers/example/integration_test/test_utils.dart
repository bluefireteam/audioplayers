import 'package:flutter_test/flutter_test.dart';

void printWithTimeOnFailure(String message) {
  printOnFailure('${DateTime.now()}: $message');
}
