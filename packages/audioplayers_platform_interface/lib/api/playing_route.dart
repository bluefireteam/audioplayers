/// Indicates which speakers use for playing
enum PlayingRoute {
  speakers,
  earpiece,
}

extension PlayingRouteExtensions on PlayingRoute {
  /// Returns this enum name to be used over the wire with the native side.
  /// TODO(luan) other enums use toString(), we should unify.
  String name() {
    switch (this) {
      case PlayingRoute.speakers:
        return 'speakers';
      case PlayingRoute.earpiece:
        return 'earpiece';
    }
  }

  /// Note: this only makes sense because we have exactly two playing routes.
  /// If that ever was to change, this method would need to be removed.
  PlayingRoute toggle() {
    switch (this) {
      case PlayingRoute.speakers:
        return PlayingRoute.earpiece;
      case PlayingRoute.earpiece:
        return PlayingRoute.speakers;
    }
  }
}
