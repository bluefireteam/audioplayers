extension MapParser on Map<dynamic, dynamic> {
  bool containsKey(String key) => this.containsKey(key);

  String? getString(String key) {
    return this[key] as String?;
  }

  int? getInt(String key) {
    return this[key] as int?;
  }

  bool? getBool(String key) {
    return this[key] as bool?;
  }
}
