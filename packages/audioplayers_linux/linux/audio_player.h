#pragma once

#include <flutter_linux/flutter_linux.h>

#include <future>
#include <map>
#include <memory>
#include <optional>
#include <sstream>
#include <string>

// STL headers
#include <functional>
#include <map>
#include <memory>
#include <sstream>
#include <string>

extern "C" {
#include <gst/gst.h>
}

enum ReleaseMode { stop, release, loop };

static std::unordered_map<std::string, ReleaseMode> const releaseModeMap = {
    {"ReleaseMode.stop", ReleaseMode::stop},
    {"ReleaseMode.release", ReleaseMode::release},
    {"ReleaseMode.loop", ReleaseMode::loop}};

class AudioPlayer {
 public:
  AudioPlayer(std::string playerId,
              FlMethodChannel* methodChannel,
              FlEventChannel* eventChannel);

  std::optional<int64_t> GetPosition();

  std::optional<int64_t> GetDuration();

  ReleaseMode GetReleaseMode();

  void Play();

  void Pause();

  void Stop();

  void Resume();

  void Dispose();

  void SetBalance(float balance);

  void SetReleaseMode(ReleaseMode releaseMode);

  void SetVolume(double volume);

  void SetPlaybackRate(double rate);

  void SetPosition(int64_t position);

  void SetSourceUrl(std::string url);

  void ReleaseMediaSource();

  void OnError(const gchar* code,
               const gchar* message,
               FlValue* details,
               GError** error);

  void OnLog(const gchar* message);

  virtual ~AudioPlayer();

 private:
  // Gst members
  GstElement* playbin = nullptr;
  GstElement* source = nullptr;
  GstElement* panorama = nullptr;
  GstElement* audiobin = nullptr;
  GstElement* audiosink = nullptr;
  GstPad* panoramaSinkPad = nullptr;
  GstBus* bus = nullptr;

  bool _isInitialized = false;
  bool _isPlaying = false;
  ReleaseMode _releaseMode = ReleaseMode::release;
  bool _isSeekCompleted = true;
  double _playbackRate = 1.0;

  std::string _url{};
  std::string _playerId;
  FlEventChannel* _eventChannel;

  static void SourceSetup(GstElement* playbin,
                          GstElement* source,
                          GstElement** p_src);

  static gboolean OnBusMessage(GstBus* bus,
                               GstMessage* message,
                               AudioPlayer* data);

  void SetPlayback(int64_t seekTo, double rate);

  void OnMediaError(GError* error, gchar* debug);

  void OnMediaStateChange(GstObject* src,
                          GstState* old_state,
                          GstState* new_state);

  void OnDurationUpdate();

  void OnSeekCompleted();

  void OnPlaybackEnded();

  void OnPrepared(bool isPrepared);
};