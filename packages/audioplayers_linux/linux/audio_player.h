#pragma once

#include <flutter_linux/flutter_linux.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <future>

// STL headers
#include <functional>
#include <memory>

#include <map>
#include <memory>
#include <sstream>
#include <string>

class AudioPlayer {

public:

    AudioPlayer(std::string playerId, FlMethodChannel* channel);

    void Dispose();
    void SetLooping(bool isLooping);
    void SetVolume(double volume);
    void SetPlaybackSpeed(double playbackSpeed);
    void Play();
    void Pause();
    void Resume();
    bool GetLooping();
    int64_t GetPosition();
    int64_t GetDuration();
    void SeekTo(int64_t seek);

    void SetSourceUrl(std::string url);

    virtual ~AudioPlayer();

private:

    // Media members
//    media::MFPlatformRef m_mfPlatform;
//    lnx::com_ptr<media::MediaEngineWrapper> m_mediaEngineWrapper;

    bool _isInitialized = false;
    std::string _url{};

//    void SendInitialized();

//    void OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr);
//    void OnMediaStateChange(media::MediaEngineWrapper::BufferingState bufferingState);
//    void OnPlaybackEnded();
//    void OnTimeUpdate();
//    void OnSeekCompleted();

    std::string _playerId;

    FlMethodChannel* _channel;

};
