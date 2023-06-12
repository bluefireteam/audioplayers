import 'package:flutter/foundation.dart';

enum AudioEventType {
  log,
  position,
  duration,
  seekComplete,
  complete,
  prepared,
}

/// Event emitted from the platform implementation.
@immutable
class AudioEvent {
  /// Creates an instance of [AudioEvent].
  ///
  /// The [eventType] argument is required.
  const AudioEvent({
    required this.eventType,
    this.duration,
    this.position,
    this.logMessage,
    this.isPrepared,
  });

  /// The type of the event.
  final AudioEventType eventType;

  /// Duration of the audio.
  final Duration? duration;

  /// Position of the audio.
  final Duration? position;

  /// Log message in the player scope.
  final String? logMessage;

  /// Whether the source is prepared to be played.
  final bool? isPrepared;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AudioEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            duration == other.duration &&
            position == other.position &&
            logMessage == other.logMessage &&
            isPrepared == other.isPrepared;
  }

  @override
  int get hashCode => Object.hash(
        eventType,
        duration,
        position,
        logMessage,
        isPrepared,
      );

  @override
  String toString() {
    return 'AudioEvent('
        'eventType: $eventType, '
        'duration: $duration, '
        'position: $position, '
        'logMessage: $logMessage, '
        'isPrepared: $isPrepared'
        ')';
  }
}
