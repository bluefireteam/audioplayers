import 'package:flutter/foundation.dart';

enum PlayerEventType {
  log,
  position,
  duration,
  seekComplete,
  complete,
}

/// Event emitted from the platform implementation.
@immutable
class PlayerEvent {
  /// Creates an instance of [PlayerEvent].
  ///
  /// The [eventType] argument is required.
  const PlayerEvent({
    required this.eventType,
    this.duration,
    this.position,
    this.logMessage,
  });

  /// The type of the event.
  final PlayerEventType eventType;

  /// Duration of the audio.
  final Duration? duration;

  /// Position of the audio.
  final Duration? position;

  /// Log message in the player scope.
  final String? logMessage;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlayerEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            duration == other.duration &&
            position == other.position &&
            logMessage == other.logMessage;
  }

  @override
  int get hashCode => Object.hash(
        eventType,
        duration,
        position,
        logMessage,
      );

  @override
  String toString() {
    return 'PlayerEvent('
        'eventType: $eventType, '
        'duration: $duration, '
        'position: $position, '
        'logMessage: $logMessage'
        ')';
  }
}
