#include "audio_player.h"
#include <flutter_linux/flutter_linux.h>
#define STR_LINK_TROUBLESHOOTING \
  "https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md"

AudioPlayer::AudioPlayer(std::string playerId,
                         FlMethodChannel* methodChannel,
                         FlEventChannel* eventChannel)
    : _playerId(playerId), _eventChannel(eventChannel) {
  // GStreamer lib only needs to be initialized once, but doing it while
  // registering the plugin can be problematic as it likely needs a GUI to be
  // present. Calling it multiple times is fine.
  gst_init(NULL, NULL);

  playbin = gst_element_factory_make("playbin", NULL);
  if (!playbin) {
    throw "Not all elements could be created.";
  }

  // Setup stereo balance controller
  panorama = gst_element_factory_make("audiopanorama", NULL);
  if (panorama) {
    audiobin = gst_bin_new(NULL);
    audiosink = gst_element_factory_make("autoaudiosink", NULL);

    gst_bin_add_many(GST_BIN(audiobin), panorama, audiosink, NULL);
    gst_element_link(panorama, audiosink);

    GstPad* sinkpad = gst_element_get_static_pad(panorama, "sink");
    panoramaSinkPad = gst_ghost_pad_new("sink", sinkpad);
    gst_element_add_pad(audiobin, panoramaSinkPad);
    gst_object_unref(GST_OBJECT(sinkpad));

    g_object_set(G_OBJECT(playbin), "audio-sink", audiobin, NULL);
    g_object_set(G_OBJECT(panorama), "method", 1, NULL);
  }

  // Setup source options
  g_signal_connect(playbin, "source-setup",
                   G_CALLBACK(AudioPlayer::SourceSetup), &source);

  bus = gst_element_get_bus(playbin);

  // Watch bus messages for one time events
  gst_bus_add_watch(bus, (GstBusFunc)AudioPlayer::OnBusMessage, this);
}

AudioPlayer::~AudioPlayer() {}

void AudioPlayer::SourceSetup(GstElement* playbin,
                              GstElement* source,
                              GstElement** p_src) {
  // Allow sources from unencrypted / misconfigured connections
  if (g_object_class_find_property(G_OBJECT_GET_CLASS(source), "ssl-strict") !=
      0) {
    g_object_set(G_OBJECT(source), "ssl-strict", FALSE, NULL);
  }
};

void AudioPlayer::SetSourceUrl(std::string url) {
  if (_url != url) {
    _url = url;
    gst_element_set_state(playbin, GST_STATE_NULL);
    _isInitialized = false;
    _isPlaying = false;
    if (!_url.empty()) {
      g_object_set(GST_OBJECT(playbin), "uri", _url.c_str(), NULL);
      if (playbin->current_state != GST_STATE_READY) {
        GstStateChangeReturn ret =
            gst_element_set_state(playbin, GST_STATE_READY);
        if (ret == GST_STATE_CHANGE_FAILURE) {
          throw "Unable to set the pipeline to GST_STATE_READY.";
        }
      }
    }
  } else {
    this->OnPrepared(true);
  }
}

void AudioPlayer::ReleaseMediaSource() {
  if (_isPlaying)
    _isPlaying = false;
  if (_isInitialized)
    _isInitialized = false;
  _url.clear();

  GstState playbinState;
  gst_element_get_state(playbin, &playbinState, NULL, GST_CLOCK_TIME_NONE);
  if (playbinState > GST_STATE_NULL) {
    gst_element_set_state(playbin, GST_STATE_NULL);
  }
}

gboolean AudioPlayer::OnBusMessage(GstBus* bus,
                                   GstMessage* message,
                                   AudioPlayer* data) {
  switch (GST_MESSAGE_TYPE(message)) {
    case GST_MESSAGE_ERROR: {
      GError* err;
      gchar* debug;

      gst_message_parse_error(message, &err, &debug);
      data->OnMediaError(err, debug);
      g_error_free(err);
      g_free(debug);
      break;
    }
    case GST_MESSAGE_STATE_CHANGED:
      GstState old_state, new_state;

      gst_message_parse_state_changed(message, &old_state, &new_state, NULL);
      data->OnMediaStateChange(GST_MESSAGE_SRC(message), &old_state,
                               &new_state);
      break;
    case GST_MESSAGE_EOS:
      data->OnPlaybackEnded();
      break;
    case GST_MESSAGE_DURATION_CHANGED:
      data->OnDurationUpdate();
      break;
    case GST_MESSAGE_ASYNC_DONE:
      if (!data->_isSeekCompleted) {
        data->OnSeekCompleted();
        data->_isSeekCompleted = true;
      }
      break;
    default:
      // For more GstMessage types see:
      // https://gstreamer.freedesktop.org/documentation/gstreamer/gstmessage.html?gi-language=c#enumerations
      break;
  }

  // Continue watching for messages
  return TRUE;
};

void AudioPlayer::OnMediaError(GError* error, gchar* debug) {
  if (this->_eventChannel) {
    gchar const* code = "LinuxAudioError";
    gchar const* message;
    auto detailsStr = std::string(error->message) + " (Domain: " +
                      std::string(g_quark_to_string(error->domain)) +
                      ", Code: " + std::to_string(error->code) + ")";
    FlValue* details = fl_value_new_string(detailsStr.c_str());
    // https://gstreamer.freedesktop.org/documentation/gstreamer/gsterror.html#enumerations
    if (error->domain == GST_STREAM_ERROR ||
        error->domain == GST_RESOURCE_ERROR) {
      message =
          "Failed to set source. For troubleshooting, "
          "see: " STR_LINK_TROUBLESHOOTING;
    } else {
      message = "Unknown GstGError. See details.";
    }
    this->OnError(code, message, details, &error);
  }
}

void AudioPlayer::OnError(const gchar* code,
                          const gchar* message,
                          FlValue* details,
                          GError** error) {
  if (this->_eventChannel) {
    fl_event_channel_send_error(this->_eventChannel, code, message, details,
                                nullptr, error);
  } else {
    std::ostringstream oss;
    oss << "Error: " << code << "; message=" << message;
    g_print("%s\n", oss.str().c_str());
  }
}

void AudioPlayer::OnMediaStateChange(GstObject* src,
                                     GstState* old_state,
                                     GstState* new_state) {
  if (!playbin) {
    this->OnError("LinuxAudioError",
                  "Player was already disposed (OnMediaStateChange).", nullptr,
                  nullptr);
    return;
  }

  if (src == GST_OBJECT(playbin)) {
    if (*new_state == GST_STATE_READY) {
      // Need to set to pause state, in order to make player functional
      GstStateChangeReturn ret =
          gst_element_set_state(playbin, GST_STATE_PAUSED);
      if (ret == GST_STATE_CHANGE_FAILURE) {
        // Only use [OnLog] as error is handled via [OnMediaError].
        gchar const* errorDescription =
            "OnMediaStateChange -> GST_STATE_CHANGE_FAILURE:"
            "Unable to set the pipeline from GST_STATE_READY to "
            "GST_STATE_PAUSED.";
        this->OnLog(errorDescription);
      }
      if (this->_isInitialized) {
        this->_isInitialized = false;
      }
    } else if (*old_state == GST_STATE_PAUSED &&
               *new_state == GST_STATE_PLAYING) {
      OnDurationUpdate();
    } else if (*new_state >= GST_STATE_PAUSED) {
      if (!this->_isInitialized) {
        this->_isInitialized = true;
        this->OnPrepared(true);
        if (this->_isPlaying) {
          Resume();
        }
      }
    } else if (this->_isInitialized) {
      this->_isInitialized = false;
    }
  }
}

void AudioPlayer::OnPrepared(bool isPrepared) {
  if (this->_eventChannel) {
    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string(map, "event", fl_value_new_string("audio.onPrepared"));
    fl_value_set_string(map, "value", fl_value_new_bool(isPrepared));
    fl_event_channel_send(this->_eventChannel, map, nullptr, nullptr);
  }
}

void AudioPlayer::OnDurationUpdate() {
  if (this->_eventChannel) {
    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string(map, "event", fl_value_new_string("audio.onDuration"));
    fl_value_set_string(map, "value",
                        fl_value_new_int(GetDuration().value_or(0)));
    fl_event_channel_send(this->_eventChannel, map, nullptr, nullptr);
  }
}

void AudioPlayer::OnSeekCompleted() {
  if (this->_eventChannel) {
    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string(map, "event",
                        fl_value_new_string("audio.onSeekComplete"));
    fl_value_set_string(map, "value", fl_value_new_bool(true));
    fl_event_channel_send(this->_eventChannel, map, nullptr, nullptr);
  }
}

void AudioPlayer::OnPlaybackEnded() {
  if (this->_eventChannel) {
    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string(map, "event", fl_value_new_string("audio.onComplete"));
    fl_value_set_string(map, "value", fl_value_new_bool(true));
    fl_event_channel_send(this->_eventChannel, map, nullptr, nullptr);
  }
  if (GetReleaseMode() == ReleaseMode::loop) {
    Play();
  } else {
    Stop();
  }
}

void AudioPlayer::OnLog(const gchar* message) {
  if (this->_eventChannel) {
    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string(map, "event", fl_value_new_string("audio.onLog"));
    fl_value_set_string(map, "value", fl_value_new_string(message));

    fl_event_channel_send(this->_eventChannel, map, nullptr, nullptr);
  }
}

void AudioPlayer::SetBalance(float balance) {
  if (!panorama) {
    this->OnLog("Audiopanorama was not initialized");
    return;
  }

  if (balance > 1.0f) {
    balance = 1.0f;
  } else if (balance < -1.0f) {
    balance = -1.0f;
  }
  g_object_set(G_OBJECT(panorama), "panorama", balance, NULL);
}

void AudioPlayer::SetReleaseMode(ReleaseMode releaseMode) {
  _releaseMode = releaseMode;
}

ReleaseMode AudioPlayer::GetReleaseMode() {
  return _releaseMode;
}

void AudioPlayer::SetVolume(double volume) {
  if (volume > 1) {
    volume = 1;
  } else if (volume < 0) {
    volume = 0;
  }
  g_object_set(G_OBJECT(playbin), "volume", volume, NULL);
}

/**
 * A rate of 1.0 means normal playback rate, 2.0 means double speed.
 * Negatives values means backwards playback.
 * A value of 0.0 will pause the player.
 *
 * @param position the position in milliseconds
 * @param rate the playback rate (speed)
 */
void AudioPlayer::SetPlayback(int64_t position, double rate) {
  if (rate != 0 && _playbackRate != rate) {
    _playbackRate = rate;
  }

  if (!_isInitialized) {
    return;
  }
  // See:
  // https://gstreamer.freedesktop.org/documentation/tutorials/basic/playback-speed.html?gi-language=c
  if (!_isSeekCompleted) {
    return;
  }
  if (rate == 0) {
    // Do not set rate if it's 0, rather pause.
    Pause();
    return;
  }

  _isSeekCompleted = false;

  GstEvent* seek_event;
  if (rate > 0) {
    seek_event = gst_event_new_seek(
        rate, GST_FORMAT_TIME,
        GstSeekFlags(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_ACCURATE),
        GST_SEEK_TYPE_SET, position * GST_MSECOND, GST_SEEK_TYPE_NONE, -1);
  } else {
    seek_event = gst_event_new_seek(
        rate, GST_FORMAT_TIME,
        GstSeekFlags(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_ACCURATE),
        GST_SEEK_TYPE_SET, 0, GST_SEEK_TYPE_SET, position * GST_MSECOND);
  }

  if (!gst_element_send_event(playbin, seek_event)) {
    this->OnLog((std::string("Could not set playback to position ") +
                 std::to_string(position) + std::string(" and rate ") +
                 std::to_string(rate) + std::string("."))
                    .c_str());
    _isSeekCompleted = true;
  }
}

void AudioPlayer::SetPlaybackRate(double rate) {
  SetPlayback(GetPosition().value_or(0), rate);
}

/**
 * @param position the position in milliseconds
 */
void AudioPlayer::SetPosition(int64_t position) {
  if (!_isInitialized) {
    return;
  }
  SetPlayback(position, _playbackRate);
}

/**
 * @return int64_t the position in milliseconds
 */
std::optional<int64_t> AudioPlayer::GetPosition() {
  gint64 current = 0;
  if (!gst_element_query_position(playbin, GST_FORMAT_TIME, &current)) {
    this->OnLog("Could not query current position.");
    return std::nullopt;
  }
  return std::make_optional(current / 1000000);
}

/**
 * @return int64_t the duration in milliseconds
 */
std::optional<int64_t> AudioPlayer::GetDuration() {
  gint64 duration = 0;
  if (!gst_element_query_duration(playbin, GST_FORMAT_TIME, &duration)) {
    // FIXME: Get duration for MP3 with variable bit rate with gst-discoverer:
    // https://gstreamer.freedesktop.org/documentation/pbutils/gstdiscoverer.html?gi-language=c#gst_discoverer_info_get_duration
    this->OnLog("Could not query current duration.");
    return std::nullopt;
  }
  return std::make_optional(duration / 1000000);
}

void AudioPlayer::Play() {
  SetPosition(0);
  Resume();
}

void AudioPlayer::Pause() {
  if (_isPlaying) {
    _isPlaying = false;
  }
  if (!_isInitialized) {
    return;
  }
  GstStateChangeReturn ret = gst_element_set_state(playbin, GST_STATE_PAUSED);
  if (ret == GST_STATE_CHANGE_SUCCESS) {
  } else if (ret == GST_STATE_CHANGE_FAILURE) {
    throw "Unable to set the pipeline to GST_STATE_PAUSED.";
  }
}

void AudioPlayer::Stop() {
  Pause();
  if (!_isInitialized) {
    return;
  }

  if (GetReleaseMode() == ReleaseMode::release) {
    ReleaseMediaSource();
  } else {
    SetPosition(0);
    // Block thread to wait for state, as it is not expected to be waited to
    // "seek complete" event on the dart side.
    GstStateChangeReturn ret =
        gst_element_get_state(playbin, NULL, NULL, GST_CLOCK_TIME_NONE);
    if (ret == GST_STATE_CHANGE_FAILURE) {
      throw "Unable to seek playback to '0' while stopping the player.";
    }
  }
}

void AudioPlayer::Resume() {
  if (!_isPlaying) {
    _isPlaying = true;
  }
  if (!_isInitialized) {
    return;
  }
  GstStateChangeReturn ret = gst_element_set_state(playbin, GST_STATE_PLAYING);
  if (ret == GST_STATE_CHANGE_SUCCESS) {
    // Update duration when start playing, as no event is emitted elsewhere
    OnDurationUpdate();
  } else if (ret == GST_STATE_CHANGE_FAILURE) {
    throw "Unable to set the pipeline to GST_STATE_PLAYING.";
  }
}

void AudioPlayer::Dispose() {
  if (!playbin)
    throw "Player was already disposed (Dispose)";
  ReleaseMediaSource();

  if (bus) {
    gst_bus_remove_watch(bus);
    gst_object_unref(GST_OBJECT(bus));
    bus = nullptr;
  }

  if (source) {
    gst_object_unref(GST_OBJECT(source));
    source = nullptr;
  }

  if (panorama) {
    gst_element_set_state(audiobin, GST_STATE_NULL);

    gst_element_remove_pad(audiobin, panoramaSinkPad);
    gst_bin_remove(GST_BIN(audiobin), audiosink);
    gst_bin_remove(GST_BIN(audiobin), panorama);

    // audiobin gets unreferenced (2x) via playbin
    panorama = nullptr;
  }

  gst_object_unref(GST_OBJECT(playbin));
  // Do not dispose method channel as it is used by multiple players!
  g_clear_object(&_eventChannel);
  _eventChannel = nullptr;
  playbin = nullptr;
}
