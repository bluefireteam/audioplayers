import 'package:flutter/foundation.dart';

enum AudioEventType {
  log,
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
    this.logMessage,
    this.isPrepared,
  });

  /// The type of the event.
  final AudioEventType eventType;

  /// Duration of the audio.
  final Duration? duration;

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
            logMessage == other.logMessage &&
            isPrepared == other.isPrepared;
  }

  @override
  int get hashCode => Object.hash(
        eventType,
        duration,
        logMessage,
        isPrepared,
      );

  @override
  String toString() {
    return 'AudioEvent('
        'eventType: $eventType, '
        'duration: $duration, '
        'logMessage: $logMessage, '
        'isPrepared: $isPrepared'
        ')';
  }
}
