import 'package:flutter/services.dart';

extension StandardMethodChannel on MethodChannel {
  Future<int> invoke(String method, Map<String, dynamic> args) async {
    final result = await invokeMethod<int>(method, args);
    return result ?? 0; // if null, we assume error
  }
}

extension StandardMethodCall on MethodCall {
  Map<dynamic, dynamic> get args => arguments as Map<dynamic, dynamic>;

  String getString(String key) {
    return args[key] as String;
  }

  int getInt(String key) {
    return args[key] as int;
  }

  bool getBool(String key) {
    return args[key] as bool;
  }
}
