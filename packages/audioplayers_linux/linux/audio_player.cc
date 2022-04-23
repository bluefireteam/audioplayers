#include "audio_player.h"

#include <flutter_linux/flutter_linux.h>

#include "Logger.h"

AudioPlayer::AudioPlayer(std::string playerId, FlMethodChannel *channel)
    : _playerId(playerId), _channel(channel) {
    gst_init(NULL, NULL);
    playbin = gst_element_factory_make("playbin", "playbin");
    if (!playbin) {
        Logger::Error(std::string("Not all elements could be created."));
        return;
    }

    g_signal_connect(playbin, "source-setup",
                     G_CALLBACK(AudioPlayer::SourceSetup), &source);

    // TODO not working with main_loop running, also message events work without
    // it, but proposed: See:
    // https://gstreamer.freedesktop.org/documentation/tutorials/playback/playbin-usage.html?gi-language=c#the-multilingual-player
    // main_loop = g_main_loop_new(NULL, FALSE);
    // g_main_loop_run(main_loop);

    bus = gst_element_get_bus(playbin);
    // TODO use gst_bus_add_signal_watch for more granular messages, see
    // https://gstreamer.freedesktop.org/documentation/tutorials/basic/toolkit-integration.html?gi-language=c#walkthrough
    gst_bus_add_watch(bus, (GstBusFunc)AudioPlayer::OnBusMessage, this);

    // Refresh continuously
    g_timeout_add(1000, (GSourceFunc)AudioPlayer::OnRefresh, this);
}

void AudioPlayer::SourceSetup(GstElement *playbin, GstElement *source,
                              GstElement **p_src) {
    if (g_object_class_find_property(G_OBJECT_GET_CLASS(source),
                                     "ssl-strict") != 0) {
        g_object_set(G_OBJECT(source), "ssl-strict", FALSE, NULL);
    }
};

void AudioPlayer::SetSourceUrl(std::string url) {
    if (_url != url) {
        _url = url;
        if (playbin->current_state >= GST_STATE_READY)
            gst_element_set_state(playbin, GST_STATE_READY);
        g_object_set(playbin, "uri", _url.c_str(), NULL);
        _isInitialized = false;
    }
}

AudioPlayer::~AudioPlayer() {}

// See:
// https://gstreamer.freedesktop.org/documentation/gstreamer/gstevent.html?gi-language=c#GstEventType
gboolean AudioPlayer::OnBusMessage(GstBus *bus, GstMessage *message,
                                   AudioPlayer *data) {
    switch (GST_MESSAGE_TYPE(message)) {
        case GST_MESSAGE_ERROR: {
            GError *err;
            gchar *debug;

            gst_message_parse_error(message, &err, &debug);
            data->OnMediaError(err, debug);
            g_error_free(err);
            g_free(debug);
            break;
        }
        case GST_MESSAGE_STATE_CHANGED:
            GstState old_state, new_state;

            gst_message_parse_state_changed(message, &old_state, &new_state,
                                            NULL);
            data->OnMediaStateChange(message->src, &old_state, &new_state);
            break;
        case GST_MESSAGE_EOS:
            gst_element_set_state(data->playbin, GST_STATE_READY);
            data->OnPlaybackEnded();
            break;
        case GST_MESSAGE_DURATION_CHANGED:
            data->OnDurationUpdate();
            break;
        case GST_MESSAGE_STREAM_STATUS:
        case GST_MESSAGE_NEED_CONTEXT:
        case GST_MESSAGE_ELEMENT:
        default:
            /* unhandled message */
            break;
    }

    // Continue watching for messages
    return TRUE;
};

// Compare with refresh_ui in
// https://gstreamer.freedesktop.org/documentation/tutorials/basic/toolkit-integration.html?gi-language=c#walkthrough
gboolean AudioPlayer::OnRefresh(AudioPlayer *data) {
    /* We do not want to update anything unless we are in the PAUSED or PLAYING
     * states */
    if (data->playbin->current_state == GST_STATE_PLAYING) {
        data->OnPositionUpdate();
    }
    return TRUE;
}

void AudioPlayer::OnMediaError(GError *error, gchar *debug) {
    std::ostringstream oss;
    oss << "Error: " << error->code << "; message=" << error->message;
    g_print("%s\n", oss.str().c_str());
    if (this->_channel) {
        g_autoptr(FlValue) map = fl_value_new_map();
        fl_value_set_string(map, "playerId",
                            fl_value_new_string(_playerId.c_str()));
        fl_value_set_string(map, "value",
                            fl_value_new_string(oss.str().c_str()));

        fl_method_channel_invoke_method(this->_channel, "audio.onError", map,
                                        nullptr, nullptr, nullptr);
    }
}

void AudioPlayer::OnMediaStateChange(GstObject *src, GstState *old_state,
                                     GstState *new_state) {
    if (strcmp(GST_OBJECT_NAME(src), "playbin") == 0) {
        g_print("Element %s changed state from %s to %s.\n",
                GST_OBJECT_NAME(src), gst_element_state_get_name(*old_state),
                gst_element_state_get_name(*new_state));
        // TODO may need to filter further
        if (!this->_isInitialized) {
            this->_isInitialized = true;
            g_print("Initialized media");
        }
    }
}

void AudioPlayer::OnPlaybackEnded() {
    SeekTo(0);
    if (GetLooping()) {
        Play();
    }
    if (this->_channel) {
        g_autoptr(FlValue) map = fl_value_new_map();
        fl_value_set_string(map, "playerId",
                            fl_value_new_string(_playerId.c_str()));
        fl_value_set_string(map, "value", fl_value_new_bool(true));

        fl_method_channel_invoke_method(this->_channel, "audio.onComplete", map,
                                        nullptr, nullptr, nullptr);
    }
}

void AudioPlayer::OnPositionUpdate() {
    if (this->_channel) {
        g_autoptr(FlValue) map = fl_value_new_map();
        fl_value_set_string(map, "playerId",
                            fl_value_new_string(_playerId.c_str()));
        fl_value_set_string(map, "value", fl_value_new_int(GetPosition()));
        fl_method_channel_invoke_method(this->_channel,
                                        "audio.onCurrentPosition", map, nullptr,
                                        nullptr, nullptr);
    }
}

void AudioPlayer::OnDurationUpdate() {
    if (this->_channel) {
        g_autoptr(FlValue) map = fl_value_new_map();
        fl_value_set_string(map, "playerId",
                            fl_value_new_string(_playerId.c_str()));
        fl_value_set_string(map, "value", fl_value_new_int(GetDuration()));
        fl_method_channel_invoke_method(this->_channel, "audio.onDuration", map,
                                        nullptr, nullptr, nullptr);
    }
}

void AudioPlayer::OnSeekCompleted() {
    if (this->_channel) {
        g_autoptr(FlValue) map = fl_value_new_map();
        fl_value_set_string(map, "playerId",
                            fl_value_new_string(_playerId.c_str()));
        fl_value_set_string(map, "value", fl_value_new_bool(true));
        fl_method_channel_invoke_method(this->_channel, "audio.onSeekComplete",
                                        map, nullptr, nullptr, nullptr);
    }
}

void AudioPlayer::Dispose() {
    if (_isInitialized) {
        Pause();
    }
    g_main_loop_unref(main_loop);
    gst_object_unref(bus);
    gst_object_unref(source);
    gst_object_unref(playbin);
    gst_element_set_state(playbin, GST_STATE_NULL);
    _channel = nullptr;
    _isInitialized = false;
}

void AudioPlayer::SetLooping(bool isLooping) { _isLooping = isLooping; }

bool AudioPlayer::GetLooping() { return _isLooping; }

void AudioPlayer::SetVolume(double volume) {
    if (volume > 1) {
        volume = 1;
    } else if (volume < 0) {
        volume = 0;
    }
    g_object_set(G_OBJECT(playbin), "volume", volume, NULL);
}

// See:
// https://gstreamer.freedesktop.org/documentation/tutorials/basic/playback-speed.html?gi-language=c
void AudioPlayer::SetPlaybackSpeed(double playbackSpeed) {
    GstEvent *seek_event;
    gint64 position = GetPosition();
    if (playbackSpeed > 0) {
        seek_event = gst_event_new_seek(
            playbackSpeed, GST_FORMAT_TIME,
            GstSeekFlags(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_ACCURATE),
            GST_SEEK_TYPE_SET, position, GST_SEEK_TYPE_END, 0);
    } else {
        seek_event = gst_event_new_seek(
            playbackSpeed, GST_FORMAT_TIME,
            GstSeekFlags(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_ACCURATE),
            GST_SEEK_TYPE_SET, 0, GST_SEEK_TYPE_SET, position);
    }
    gst_element_send_event(playbin, seek_event);
    // TODO not working
}

void AudioPlayer::Play() {
    SeekTo(0);
    Resume();
}

void AudioPlayer::Pause() {
    GstStateChangeReturn ret = gst_element_set_state(playbin, GST_STATE_PAUSED);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        Logger::Error(
            std::string("Unable to set the pipeline to the paused state."));
        gst_object_unref(playbin);
        return;
    }
}

void AudioPlayer::Resume() {
    GstStateChangeReturn ret =
        gst_element_set_state(playbin, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        Logger::Error(
            std::string("Unable to set the pipeline to the playing state."));
        gst_object_unref(playbin);
        return;
    }
}

/**
 * @return int64_t the position in milliseconds
 */
int64_t AudioPlayer::GetPosition() {
    gint64 current = 0;
    if (!gst_element_query_position(playbin, GST_FORMAT_TIME, &current)) {
        Logger::Error(std::string("Could not query current position."));
        return 0;
    }
    return current / 1000000;
}

/**
 * @return int64_t the duration in milliseconds
 */
int64_t AudioPlayer::GetDuration() {
    gint64 duration = 0;
    if (!gst_element_query_duration(playbin, GST_FORMAT_TIME, &duration)) {
        Logger::Error(std::string("Could not query current duration."));
        return 0;
    }
    return duration / 1000000;
}

/**
 * @param seek the position in milliseconds
 */
void AudioPlayer::SeekTo(int64_t seek) {
    if (!gst_element_seek_simple(
            playbin, GST_FORMAT_TIME,
            GstSeekFlags(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT),
            seek * GST_MSECOND)) {
        Logger::Error(std::string("Could not seek to position ") +
                      std::to_string(seek) + std::string("."));
    }
}
