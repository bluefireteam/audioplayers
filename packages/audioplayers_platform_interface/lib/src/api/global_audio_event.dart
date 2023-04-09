import 'package:flutter/foundation.dart';

enum GlobalAudioEventType {
  log,
}

/// Event emitted from the platform implementation.
@immutable
class GlobalAudioEvent {
  /// Creates an instance of [GlobalAudioEvent].
  ///
  /// The [eventType] argument is required.
  const GlobalAudioEvent({
    required this.eventType,
    this.logMessage,
  });

  /// The type of the event.
  final GlobalAudioEventType eventType;

  /// Log message in the global scope.
  final String? logMessage;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GlobalAudioEvent &&
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
    return 'GlobalAudioEvent('
        'eventType: $eventType, '
        'logMessage: $logMessage'
        ')';
  }
}
