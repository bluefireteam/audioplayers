extension UriCoder on Uri {
  static String encodeOnce(String uri) {
    var tmpUri = uri;
    try {
      // Try decoding first to avoid encoding twice:
      tmpUri = Uri.decodeFull(tmpUri);
    } on ArgumentError catch (_) {}
    return Uri.encodeFull(tmpUri);
  }
}
