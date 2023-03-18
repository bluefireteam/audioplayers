import 'package:flutter/services.dart';

extension StandardMethodChannel on MethodChannel {
  Future<void> call(String method, Map<String, dynamic> args) async {
    return invokeMethod<void>(method, args);
  }

  Future<T?> compute<T>(String method, Map<String, dynamic> args) async {
    return invokeMethod<T>(method, args);
  }
}
