extension UriCoder on Uri {
  static String encodeOnce(String uri) {
    try {
      // If decoded differs, the uri was already encoded.
      final decodedUri = Uri.decodeFull(uri);
      if (decodedUri != uri) {
        return uri;
      }
    } on ArgumentError catch (_) {}
    return Uri.encodeFull(uri);
  }
}
