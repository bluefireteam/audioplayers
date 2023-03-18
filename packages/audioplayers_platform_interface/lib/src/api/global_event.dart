import 'package:flutter/foundation.dart';

enum GlobalEventType {
  log,
}

/// Event emitted from the platform implementation.
@immutable
class GlobalEvent {
  /// Creates an instance of [GlobalEvent].
  ///
  /// The [eventType] argument is required.
  const GlobalEvent({
    required this.eventType,
    this.logMessage,
  });

  /// The type of the event.
  final GlobalEventType eventType;

  /// Position of the audio.
  final String? logMessage;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GlobalEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            logMessage == other.logMessage;
  }

  @override
  int get hashCode => Object.hash(
        eventType,
        logMessage,
      );

  @override
  String toString() {
    return 'GlobalEvent('
        'eventType: $eventType, '
        'logMessage: $logMessage'
        ')';
  }
}
