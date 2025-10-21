#include "audio_player.h"

#include <comdef.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <shlwapi.h>  // for SHCreateMemStream
#include <shobjidl.h>
#include <windows.h>

#include <excpt.h>
#include <delayimp.h>
#include "audioplayers_helpers.h"

#define STR_LINK_TROUBLESHOOTING \
  "https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md"
#undef GetCurrentTime

using namespace winrt;

// SEH C-wrapper functions to solve C2712
HRESULT InitializeMediaFoundation_SEH(media::MediaEngineWrapper* wrapper) {
  __try {
    THROW_IF_FAILED(MFStartup(MF_VERSION, MFSTARTUP_FULL));
    wrapper->Initialize();
  } __except (EXCEPTION_EXECUTE_HANDLER) {
    DWORD exceptionCode = GetExceptionCode();
    if (exceptionCode == 0xC06D007E || exceptionCode == 0xC06D007F) {
      return exceptionCode;
    }
    return E_FAIL;
  }
  return S_OK;
}

HRESULT CreateSourceFromUrl_SEH(std::string url, IMFMediaSource** ppMediaSource) {
  __try {
    winrt::com_ptr<IMFSourceResolver> sourceResolver;
    THROW_IF_FAILED(MFCreateSourceResolver(sourceResolver.put()));
    constexpr uint32_t sourceResolutionFlags =
        MF_RESOLUTION_MEDIASOURCE |
        MF_RESOLUTION_CONTENT_DOES_NOT_HAVE_TO_MATCH_EXTENSION_OR_MIME_TYPE |
        MF_RESOLUTION_READ;
    MF_OBJECT_TYPE objectType = {};
    THROW_IF_FAILED(sourceResolver->CreateObjectFromURL(
        winrt::to_hstring(url).c_str(), sourceResolutionFlags, nullptr,
        &objectType, reinterpret_cast<IUnknown**>(ppMediaSource)));
  } __except (EXCEPTION_EXECUTE_HANDLER) {
    DWORD exceptionCode = GetExceptionCode();
    if (exceptionCode == 0xC06D007E || exceptionCode == 0xC06D007F) {
      return exceptionCode;
    }
    return E_FAIL;
  }
  return S_OK;
}

HRESULT CreateSourceFromBytes_SEH(std::vector<uint8_t> bytes,
                                  IMFMediaSource** ppMediaSource) {
  __try {
    winrt::com_ptr<IMFSourceResolver> sourceResolver;
    THROW_IF_FAILED(MFCreateSourceResolver(sourceResolver.put()));
    constexpr uint32_t sourceResolutionFlags =
        MF_RESOLUTION_MEDIASOURCE |
        MF_RESOLUTION_CONTENT_DOES_NOT_HAVE_TO_MATCH_EXTENSION_OR_MIME_TYPE |
        MF_RESOLUTION_READ;
    MF_OBJECT_TYPE objectType = {};
    IStream* pstm =
        SHCreateMemStream(bytes.data(), static_cast<unsigned int>(bytes.size()));
    IMFByteStream* stream = NULL;
    THROW_IF_FAILED(MFCreateMFByteStreamOnStream(pstm, &stream));
    sourceResolver->CreateObjectFromByteStream(
        stream, nullptr, sourceResolutionFlags, nullptr, &objectType,
        reinterpret_cast<IUnknown**>(ppMediaSource));
  } __except (EXCEPTION_EXECUTE_HANDLER) {
    DWORD exceptionCode = GetExceptionCode();
    if (exceptionCode == 0xC06D007E || exceptionCode == 0xC06D007F) {
      return exceptionCode;
    }
    return E_FAIL;
  }
  return S_OK;
}

AudioPlayer::AudioPlayer(
    std::string playerId,
    flutter::MethodChannel<flutter::EncodableValue>* methodChannel,
    EventStreamHandler<>* eventHandler)
    : _playerId(playerId),
      _methodChannel(methodChannel),
      _eventHandler(eventHandler) {
  // Callbacks invoked by the media engine wrapper
  auto onError = std::bind(&AudioPlayer::OnMediaError, this,
                           std::placeholders::_1, std::placeholders::_2);
  auto onBufferingStateChanged =
      std::bind(&AudioPlayer::OnMediaStateChange, this, std::placeholders::_1);
  auto onPlaybackEndedCB = std::bind(&AudioPlayer::OnPlaybackEnded, this);
  auto onSeekCompletedCB = std::bind(&AudioPlayer::OnSeekCompleted, this);
  auto onLoadedCB = std::bind(&AudioPlayer::SendInitialized, this);

  // Create and initialize the MediaEngineWrapper which manages media playback
  m_mediaEngineWrapper = winrt::make_self<media::MediaEngineWrapper>(
      onLoadedCB, onError, onBufferingStateChanged, onPlaybackEndedCB,
      onSeekCompletedCB);

  HRESULT hr = InitializeMediaFoundation_SEH(m_mediaEngineWrapper.get());
  if (FAILED(hr)) {
    if (hr == 0xC06D007E || hr == 0xC06D007F) {
      m_mediaFoundationFailed = true;
    }
    return;
  }
}

AudioPlayer::~AudioPlayer() {}

// This method should be called asynchronously, to avoid freezing UI
void AudioPlayer::SetSourceUrl(std::string url) {
  if (m_mediaFoundationFailed) {
    this->OnError("WindowsAudioError",
                  "Media Feature Pack not found. Please install it from "
                  "Windows Settings > Optional Features.",
                  nullptr);
    return;
  }

  if (_url != url) {
    _url = url;
    _isInitialized = false;

    try {
      winrt::com_ptr<IMFMediaSource> mediaSource;

      HRESULT hr = CreateSourceFromUrl_SEH(url, mediaSource.put());

      if (FAILED(hr)) {
        if (hr == 0xC06D007E || hr == 0xC06D007F) {
          m_mediaFoundationFailed = true;
          this->OnError("WindowsAudioError",
                        "Media Feature Pack not found (delay-load failed).",
                        nullptr);
        } else {
          this->OnError("WindowsAudioError", "Failed to create source from URL.",
                        nullptr);
        }
        return;
      }

      m_mediaEngineWrapper->SetMediaSource(mediaSource.get());
    } catch (const std::exception& ex) {
      this->OnError("WindowsAudioError",
                    "Failed to set source. For troubleshooting, "
                    "see: " STR_LINK_TROUBLESHOOTING,
                    flutter::EncodableValue(ex.what()));
    } catch (...) {
      // Forward errors to event stream, as this is called asynchronously
      this->OnError("WindowsAudioError",
                    "Failed to set source. For troubleshooting, "
                    "see: " STR_LINK_TROUBLESHOOTING,
                    flutter::EncodableValue("Unknown Error setting url to '" +
                                            url + "'."));
    }
  } else {
    OnPrepared(true);
  }
}

void AudioPlayer::SetSourceBytes(std::vector<uint8_t> bytes) {
  if (m_mediaFoundationFailed) {
    this->OnError("WindowsAudioError",
                  "Media Feature Pack not found. Please install it from "
                  "Windows Settings > Optional Features.",
                  nullptr);
    return;
  }

  _isInitialized = false;
  _url.clear();
  size_t size = bytes.size();

  try {
    winrt::com_ptr<IMFMediaSource> mediaSource;

    HRESULT hr = CreateSourceFromBytes_SEH(bytes, mediaSource.put());

    if (FAILED(hr)) {
      if (hr == 0xC06D007E || hr == 0xC06D007F) {
        m_mediaFoundationFailed = true;
        this->OnError("WindowsAudioError",
                      "Media Feature Pack not found (delay-load failed).",
                      nullptr);
      } else {
        this->OnError("WindowsAudioError", "Failed to create source from bytes.",
                      nullptr);
      }
      return;
    }

    m_mediaEngineWrapper->SetMediaSource(mediaSource.get());
  } catch (...) {
    // Forward errors to event stream, as this is called asynchronously
    this->OnError("WindowsAudioError", "Error setting bytes", nullptr);
  }
}

void AudioPlayer::OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr) {
  LOG_HR_MSG(hr, "MediaEngine error (%d)", error);
  // TODO(Gustl22): adapt log message to dart error event, check stacktrace.
  if (this->_eventHandler) {
    _com_error err(hr);

    std::wstring wstr(err.ErrorMessage());

    int size = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, &wstr[0],
                                   (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string ret = std::string(size, 0);
    WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, &wstr[0],
                        (int)wstr.size(), &ret[0], size, NULL, NULL);

    std::string message = "MediaEngine error";
    this->OnError(std::to_string(error), message, flutter::EncodableValue(ret));
  }
}

void AudioPlayer::OnError(const std::string& code,
                          const std::string& message,
                          const flutter::EncodableValue& details) {
  if (this->_eventHandler) {
    this->_eventHandler->Error(code, message, details);
  }
}

void AudioPlayer::OnMediaStateChange(
    media::MediaEngineWrapper::BufferingState bufferingState) {
  if (bufferingState !=
      media::MediaEngineWrapper::BufferingState::HAVE_NOTHING) {
    // TODO(Gustl22): add buffering state
  }
}

void AudioPlayer::OnPrepared(bool isPrepared) {
  if (this->_eventHandler) {
    this->_eventHandler->Success(std::make_unique<flutter::EncodableValue>(
        flutter::EncodableMap({{flutter::EncodableValue("event"),
                                flutter::EncodableValue("audio.onPrepared")},
                               {flutter::EncodableValue("value"),
                                flutter::EncodableValue(isPrepared)}})));
  }
}

void AudioPlayer::OnPlaybackEnded() {
  if (GetReleaseMode() == ReleaseMode::loop) {
    Play();
  } else {
    Stop();
  }
  if (this->_eventHandler) {
    this->_eventHandler->Success(std::make_unique<flutter::EncodableValue>(
        flutter::EncodableMap({{flutter::EncodableValue("event"),
                                flutter::EncodableValue("audio.onComplete")},
                               {flutter::EncodableValue("value"),
                                flutter::EncodableValue(true)}})));
  }
}

void AudioPlayer::OnDurationUpdate() {
  auto duration = m_mediaEngineWrapper->GetDuration();
  if (this->_eventHandler) {
    this->_eventHandler->Success(
        std::make_unique<flutter::EncodableValue>(flutter::EncodableMap(
            {{flutter::EncodableValue("event"),
              flutter::EncodableValue("audio.onDuration")},
             {flutter::EncodableValue("value"),
              isnan(duration)
                  ? flutter::EncodableValue(std::monostate{})
                  : flutter::EncodableValue(ConvertSecondsToMs(duration))}})));
  }
}

void AudioPlayer::OnSeekCompleted() {
  if (this->_eventHandler) {
    this->_eventHandler->Success(
        std::make_unique<flutter::EncodableValue>(flutter::EncodableMap(
            {{flutter::EncodableValue("event"),
              flutter::EncodableValue("audio.onSeekComplete")},
             {flutter::EncodableValue("value"),
              flutter::EncodableValue(true)}})));
  }
}

void AudioPlayer::OnLog(const std::string& message) {
  this->_eventHandler->Success(std::make_unique<flutter::EncodableValue>(
      flutter::EncodableMap({{flutter::EncodableValue("event"),
                              flutter::EncodableValue("audio.onLog")},
                             {flutter::EncodableValue("value"),
                              flutter::EncodableValue(message)}})));
}

void AudioPlayer::SendInitialized() {
  if (m_mediaFoundationFailed) return;
  if (!this->_isInitialized) {
    this->_isInitialized = true;
    OnPrepared(true);
    OnDurationUpdate();
  }
}

void AudioPlayer::ReleaseMediaSource() {
  if (m_mediaFoundationFailed) return;
  if (_isInitialized) {
    m_mediaEngineWrapper->Pause();
  }
  m_mediaEngineWrapper->ReleaseMediaSource();
  _url.clear();
  _isInitialized = false;
}

void AudioPlayer::Dispose() {
  if (m_mediaFoundationFailed) return;
  ReleaseMediaSource();
  m_mediaEngineWrapper->Shutdown();
  _methodChannel = nullptr;
  _eventHandler = nullptr;
}

void AudioPlayer::SetReleaseMode(ReleaseMode releaseMode) {
  if (m_mediaFoundationFailed) return;
  m_mediaEngineWrapper->SetLooping(releaseMode == ReleaseMode::loop);
  _releaseMode = releaseMode;
}

ReleaseMode AudioPlayer::GetReleaseMode() {
  return _releaseMode;
}

void AudioPlayer::SetVolume(double volume) {
  if (m_mediaFoundationFailed) return;

  if (volume > 1) {
    volume = 1;
  } else if (volume < 0) {
    volume = 0;
  }
  m_mediaEngineWrapper->SetVolume((float)volume);
}

void AudioPlayer::SetPlaybackSpeed(double playbackSpeed) {
  if (m_mediaFoundationFailed) return;
  m_mediaEngineWrapper->SetPlaybackRate(playbackSpeed);
}

void AudioPlayer::SetBalance(double balance) {
  if (m_mediaFoundationFailed) return;
  m_mediaEngineWrapper->SetBalance(balance);
}

void AudioPlayer::Play() {
  if (m_mediaFoundationFailed) return;
  m_mediaEngineWrapper->StartPlayingFrom(m_mediaEngineWrapper->GetMediaTime());
  OnDurationUpdate();
}

void AudioPlayer::Pause() {
  if (m_mediaFoundationFailed) return;
  m_mediaEngineWrapper->Pause();
}

void AudioPlayer::Stop() {
  if (m_mediaFoundationFailed) return;
  Pause();
  if (GetReleaseMode() == ReleaseMode::release) {
    ReleaseMediaSource();
  } else {
    SeekTo(0);
  }
}

void AudioPlayer::Resume() {
  if (m_mediaFoundationFailed) return;
  m_mediaEngineWrapper->Resume();
  OnDurationUpdate();
}

double AudioPlayer::GetPosition() {
  if (m_mediaFoundationFailed || !_isInitialized) {
    return std::numeric_limits<double>::quiet_NaN();
  }
  return m_mediaEngineWrapper->GetMediaTime();
}

double AudioPlayer::GetDuration() {
  if (m_mediaFoundationFailed) {
    return std::numeric_limits<double>::quiet_NaN();
  }
  return m_mediaEngineWrapper->GetDuration();
}

void AudioPlayer::SeekTo(double seek) {
  if (m_mediaFoundationFailed) return;
  m_mediaEngineWrapper->SeekTo(seek);
}
