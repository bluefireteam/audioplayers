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

    // GstBus *bus;
    // GstMessage *msg;
    // msg = gst_bus_timed_pop_filtered(
    //     bus, GST_CLOCK_TIME_NONE,
    //     (GstMessageType)(GST_MESSAGE_ERROR | GST_MESSAGE_EOS));

    // /* See next tutorial for proper error message handling/parsing */
    // if (GST_MESSAGE_TYPE(msg) == GST_MESSAGE_ERROR) {
    //     GError *err;
    //     gchar *d;
    //     gst_message_parse_error(msg, &err, &d);

    //     std::ostringstream oss;
    //     oss << "Error: " << err->code << "; message=" << err->message;
    //     Logger::Error(oss.str());
    //     return;
    // }
    // /* Free resources */
    // gst_message_unref(msg);
    // gst_object_unref(bus);
    // gst_element_set_state(pipeline, GST_STATE_NULL);
    // gst_object_unref(pipeline);

    //// WINDOWS:
    //    m_mfPlatform.Startup();
    //
    //    // Callbacks invoked by the media engine wrapper
    //    auto onError = std::bind(&AudioPlayer::OnMediaError, this,
    //    std::placeholders::_1, std::placeholders::_2); auto
    //    onBufferingStateChanged = std::bind(&AudioPlayer::OnMediaStateChange,
    //    this, std::placeholders::_1); auto onPlaybackEndedCB =
    //    std::bind(&AudioPlayer::OnPlaybackEnded, this); auto onTimeUpdateCB =
    //    std::bind(&AudioPlayer::OnTimeUpdate, this); auto onSeekCompletedCB =
    //    std::bind(&AudioPlayer::OnSeekCompleted, this);
    //
    //    // Create and initialize the MediaEngineWrapper which manages media
    //    playback m_mediaEngineWrapper =
    //    lnx::make_self<media::MediaEngineWrapper>(nullptr, onError,
    //    onBufferingStateChanged, onPlaybackEndedCB, onTimeUpdateCB,
    //    onSeekCompletedCB);
    //
    //    m_mediaEngineWrapper->Initialize();
}

void AudioPlayer::SetSourceUrl(std::string url) {
    if (_url != url) {
        _url = url;
        g_object_set(playbin, "uri", _url.c_str(), NULL);
    }
}

AudioPlayer::~AudioPlayer() {}

// void AudioPlayer::OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr) {
//     LOG_HR_MSG(hr, "MediaEngine error (%d)", error);
//     if(this->_channel) {
//         _com_error err(hr);
//
//         std::wstring wstr(err.ErrorMessage());
//
//         int size = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS,
//         &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL); std::string ret =
//         std::string(size, 0); WideCharToMultiByte(CP_UTF8,
//         WC_ERR_INVALID_CHARS, &wstr[0], (int)wstr.size(), &ret[0], size,
//         NULL, NULL);
//
//         this->_channel->InvokeMethod("audio.onError",
//             std::make_unique<FlValue>(
//                 flutter::EncodableMap({
//                     {FlValue("playerId"), FlValue(_playerId)},
//                     {FlValue("value"), FlValue(ret)}
//                 })));
//     }
// }

// void
// AudioPlayer::OnMediaStateChange(media::MediaEngineWrapper::BufferingState
// bufferingState) {
//     if(bufferingState !=
//     media::MediaEngineWrapper::BufferingState::HAVE_NOTHING) {
//         if (!this->_isInitialized) {
//             this->_isInitialized = true;
//             this->SendInitialized();
//         }
//     }
// }

// void AudioPlayer::OnPlaybackEnded() {
//     SeekTo(0);
//     if (GetLooping()) {
//         Play();
//     }
//     if(this->_channel) {
//         this->_channel->InvokeMethod("audio.onComplete",
//             std::make_unique<FlValue>(
//                 flutter::EncodableMap({
//                     {FlValue("playerId"), FlValue(_playerId)},
//                     {FlValue("value"), FlValue(true)}
//                 })));
//     }
// }
//
// void AudioPlayer::OnTimeUpdate() {
//     if(this->_channel) {
//         this->_channel->InvokeMethod("audio.onCurrentPosition",
//             std::make_unique<FlValue>(
//                 flutter::EncodableMap({
//                     {FlValue("playerId"), FlValue(_playerId)},
//                     {FlValue("value"),
//                     FlValue((int64_t)m_mediaEngineWrapper->GetMediaTime() /
//                     10000)}
//                 })));
//     }
// }
//
// void AudioPlayer::OnSeekCompleted() {
//     if(this->_channel) {
//         this->_channel->InvokeMethod("audio.onSeekComplete",
//             std::make_unique<FlValue>(
//                 flutter::EncodableMap({
//                     {FlValue("playerId"), FlValue(_playerId)},
//                     {FlValue("value"), FlValue(true)}
//                 })));
//     }
// }

// void AudioPlayer::SendInitialized() {
//     if(this->_channel) {
//         this->_channel->InvokeMethod("audio.onDuration",
//             std::make_unique<FlValue>(
//                 flutter::EncodableMap({
//                     {FlValue("playerId"), FlValue(_playerId)},
//                     {FlValue("value"),
//                     FlValue((int64_t)m_mediaEngineWrapper->GetDuration() /
//                     10000)}
//                 })));
//         this->_channel->InvokeMethod("audio.onCurrentPosition",
//             std::make_unique<FlValue>(
//                 flutter::EncodableMap({
//                     {FlValue("playerId"), FlValue(_playerId)},
//                     {FlValue("value"),
//                     FlValue((int64_t)m_mediaEngineWrapper->GetMediaTime() /
//                     10000)}
//                 })));
//     }
// }

void AudioPlayer::Dispose() {
    if (_isInitialized) {
        //        m_mediaEngineWrapper->Pause();
    }
    gst_element_set_state(playbin, GST_STATE_NULL);
    gst_object_unref(playbin);
    _channel = nullptr;
    _isInitialized = false;
}

void AudioPlayer::SetLooping(bool isLooping) {
    //    m_mediaEngineWrapper->SetLooping(isLooping);
}

bool AudioPlayer::GetLooping() {
    return false;
    //    return m_mediaEngineWrapper->GetLooping();
}

void AudioPlayer::SetVolume(double volume) {
    if (volume > 1) {
        volume = 1;
    } else if (volume < 0) {
        volume = 0;
    }
    //    m_mediaEngineWrapper->SetVolume((float)volume);
}

void AudioPlayer::SetPlaybackSpeed(double playbackSpeed) {
    //    m_mediaEngineWrapper->SetPlaybackRate(playbackSpeed);
}

void AudioPlayer::Play() {
    GstStateChangeReturn ret =
        gst_element_set_state(playbin, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        Logger::Error(
            std::string("Unable to set the pipeline to the playing state."));
        gst_object_unref(playbin);
        return;
    }
}

void AudioPlayer::Pause() {
    //    m_mediaEngineWrapper->Pause();
}

void AudioPlayer::Resume() {
    Play();
    //    m_mediaEngineWrapper->Resume();
}

int64_t AudioPlayer::GetPosition() {
    gint64 current = -1;
    if (!gst_element_query_position(playbin, GST_FORMAT_TIME, &current)) {
        Logger::Error(std::string("Could not query current position."));
        return 0;
    }
    return current;
}

int64_t AudioPlayer::GetDuration() {
    gint64 duration;
    if (!gst_element_query_duration(playbin, GST_FORMAT_TIME, &duration)) {
        Logger::Error(std::string("Could not query current duration."));
        return 0;
    }
    return duration;
}

void AudioPlayer::SeekTo(int64_t seek) {
    if (!gst_element_seek_simple(
            playbin, GST_FORMAT_TIME,
            GstSeekFlags(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT),
            seek * GST_MSECOND)) {
        Logger::Error(std::string("Could not seek to position"));
    }
}
