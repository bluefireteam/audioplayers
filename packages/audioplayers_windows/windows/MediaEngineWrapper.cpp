#include <windows.h>

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>

// Windows Implementation Library
#include <wil/resource.h>
#include <wil/result_macros.h>

// MediaFoundation headers
#include <mfapi.h>
#include <mferror.h>
#include <mfmediaengine.h>

// STL headers
#include <functional>
#include <memory>

#include <Audioclient.h>
#include "MediaEngineWrapper.h"
#include "MediaFoundationHelpers.h"
#include "audioplayers_helpers.h"

using namespace Microsoft::WRL;

namespace media {

namespace {
class MediaEngineCallbackHelper
    : public winrt::implements<MediaEngineCallbackHelper,
                               IMFMediaEngineNotify> {
 public:
  MediaEngineCallbackHelper(
      std::function<void()> onLoadedCB,
      MediaEngineWrapper::ErrorCB errorCB,
      MediaEngineWrapper::BufferingStateChangeCB bufferingStateChangeCB,
      std::function<void()> playbackEndedCB,
      std::function<void()> seekCompletedCB)
      : m_onLoadedCB(onLoadedCB),
        m_errorCB(errorCB),
        m_bufferingStateChangeCB(bufferingStateChangeCB),
        m_playbackEndedCB(playbackEndedCB),
        m_seekCompletedCB(seekCompletedCB) {
    // Ensure that callbacks are valid
    THROW_HR_IF(E_INVALIDARG, !m_onLoadedCB);
    THROW_HR_IF(E_INVALIDARG, !m_errorCB);
    THROW_HR_IF(E_INVALIDARG, !m_bufferingStateChangeCB);
    THROW_HR_IF(E_INVALIDARG, !m_playbackEndedCB);
    THROW_HR_IF(E_INVALIDARG, !m_seekCompletedCB);
  }
  virtual ~MediaEngineCallbackHelper() = default;

  void DetachParent() {
    auto lock = m_lock.lock();
    m_detached = true;
    m_onLoadedCB = nullptr;
    m_errorCB = nullptr;
    m_bufferingStateChangeCB = nullptr;
    m_playbackEndedCB = nullptr;
    m_seekCompletedCB = nullptr;
  }

  // IMFMediaEngineNotify
  IFACEMETHODIMP EventNotify(DWORD eventCode,
                             DWORD_PTR param1,
                             DWORD param2) noexcept override try {
    auto lock = m_lock.lock();
    THROW_HR_IF(MF_E_SHUTDOWN, m_detached);

    switch ((MF_MEDIA_ENGINE_EVENT)eventCode) {
      case MF_MEDIA_ENGINE_EVENT_LOADEDDATA:
        m_onLoadedCB();
        break;
      case MF_MEDIA_ENGINE_EVENT_ERROR:
        m_errorCB((MF_MEDIA_ENGINE_ERR)param1, (HRESULT)param2);
        break;
      case MF_MEDIA_ENGINE_EVENT_CANPLAY:
        m_bufferingStateChangeCB(
            MediaEngineWrapper::BufferingState::HAVE_ENOUGH);
        break;
      case MF_MEDIA_ENGINE_EVENT_WAITING:
        m_bufferingStateChangeCB(
            MediaEngineWrapper::BufferingState::HAVE_NOTHING);
        break;
      case MF_MEDIA_ENGINE_EVENT_ENDED:
        m_playbackEndedCB();
        break;
      case MF_MEDIA_ENGINE_EVENT_SEEKED:
        m_seekCompletedCB();
        break;
      default:
        break;
    }

    return S_OK;
  }
  CATCH_RETURN();

 private:
  wil::critical_section m_lock;
  std::function<void()> m_onLoadedCB;
  MediaEngineWrapper::ErrorCB m_errorCB;
  MediaEngineWrapper::BufferingStateChangeCB m_bufferingStateChangeCB;
  std::function<void()> m_playbackEndedCB;
  std::function<void()> m_seekCompletedCB;
  bool m_detached = false;
};
}  // namespace

// Public methods

void MediaEngineWrapper::Initialize() {
  RunSyncInMTA([&]() { CreateMediaEngine(); });
}

void MediaEngineWrapper::Pause() {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->Pause());
  });
}

void MediaEngineWrapper::Shutdown() {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->Shutdown());
  });
}

void MediaEngineWrapper::StartPlayingFrom(double timestampInSeconds) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->SetCurrentTime(timestampInSeconds));
    THROW_IF_FAILED(m_mediaEngine->Play());
  });
}

void MediaEngineWrapper::Resume() {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->Play());
  });
}

void MediaEngineWrapper::SetBalance(double balance) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }

    winrt::com_ptr<IMFMediaEngineEx> mediaEngineEx =
        m_mediaEngine.as<IMFMediaEngineEx>();
    THROW_IF_FAILED(mediaEngineEx->SetBalance(balance));
  });
}

void MediaEngineWrapper::SetPlaybackRate(double playbackRate) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->SetPlaybackRate(playbackRate));
  });
}

void MediaEngineWrapper::SetVolume(float volume) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->SetVolume(volume));
  });
}

void MediaEngineWrapper::SetLooping(bool isLooping) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->SetLoop(isLooping));
  });
}

bool MediaEngineWrapper::GetLooping() {
  bool looping = false;
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    looping = m_mediaEngine->GetLoop();
  });
  return looping;
}

void MediaEngineWrapper::SeekTo(double timestampInSeconds) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    THROW_IF_FAILED(m_mediaEngine->SetCurrentTime(timestampInSeconds));
  });
}

// Get media time in seconds, returns NaN if no duration is available.
double MediaEngineWrapper::GetMediaTime() {
  double currentTimeInSeconds = std::numeric_limits<double>::quiet_NaN();
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    currentTimeInSeconds = m_mediaEngine->GetCurrentTime();
  });
  return currentTimeInSeconds;
}

// Get duration in seconds, returns NaN if no duration is available.
double MediaEngineWrapper::GetDuration() {
  double durationInSeconds = std::numeric_limits<double>::quiet_NaN();
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    if (m_mediaEngine == nullptr) {
      return;
    }
    durationInSeconds = m_mediaEngine->GetDuration();
  });
  return durationInSeconds;
}

// Get buffered ranges in milliseconds
std::vector<std::tuple<int64_t, int64_t>>
MediaEngineWrapper::GetBufferedRanges() {
  std::vector<std::tuple<int64_t, int64_t>> result;
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();

    if (m_mediaEngine == nullptr) {
      return;
    }

    winrt::com_ptr<IMFMediaTimeRange> mediaTimeRange;
    THROW_IF_FAILED(m_mediaEngine->GetBuffered(mediaTimeRange.put()));

    double start;
    double end;
    for (uint32_t i = 0; i < mediaTimeRange->GetLength(); i++) {
      mediaTimeRange->GetStart(i, &start);
      mediaTimeRange->GetEnd(i, &end);
      result.push_back(
          std::make_tuple(ConvertSecondsToMs(start), ConvertSecondsToMs(end)));
    }
  });
  return result;
}

// Internal methods

void MediaEngineWrapper::CreateMediaEngine() {
  winrt::com_ptr<IMFMediaEngineClassFactory> classFactory;
  winrt::com_ptr<IMFAttributes> creationAttributes;

  m_platformRef.Startup();

  THROW_IF_FAILED(MFCreateAttributes(creationAttributes.put(), 7));
  m_callbackHelper = winrt::make<MediaEngineCallbackHelper>(
      [&]() { this->OnLoaded(); },
      [&](MF_MEDIA_ENGINE_ERR error, HRESULT hr) { this->OnError(error, hr); },
      [&](BufferingState state) { this->OnBufferingStateChange(state); },
      [&]() { this->OnPlaybackEnded(); }, [&]() { this->OnSeekCompleted(); });
  THROW_IF_FAILED(creationAttributes->SetUnknown(MF_MEDIA_ENGINE_CALLBACK,
                                                 m_callbackHelper.get()));
  THROW_IF_FAILED(
      creationAttributes->SetUINT32(MF_MEDIA_ENGINE_CONTENT_PROTECTION_FLAGS,
                                    MF_MEDIA_ENGINE_ENABLE_PROTECTED_CONTENT));
  THROW_IF_FAILED(creationAttributes->SetGUID(
      MF_MEDIA_ENGINE_BROWSER_COMPATIBILITY_MODE,
      MF_MEDIA_ENGINE_BROWSER_COMPATIBILITY_MODE_IE_EDGE));
  THROW_IF_FAILED(creationAttributes->SetUINT32(MF_MEDIA_ENGINE_AUDIO_CATEGORY,
                                                AudioCategory_Media));

  m_mediaEngineExtension = winrt::make_self<MediaEngineExtension>();
  THROW_IF_FAILED(creationAttributes->SetUnknown(MF_MEDIA_ENGINE_EXTENSION,
                                                 m_mediaEngineExtension.get()));

  THROW_IF_FAILED(CoCreateInstance(CLSID_MFMediaEngineClassFactory, nullptr,
                                   CLSCTX_INPROC_SERVER,
                                   IID_PPV_ARGS(classFactory.put())));
  m_mediaEngine = nullptr;
  THROW_IF_FAILED(classFactory->CreateInstance(0, creationAttributes.get(),
                                               m_mediaEngine.put()));
}

void MediaEngineWrapper::SetMediaSource(IMFMediaSource* mediaSource) {
  winrt::com_ptr<IUnknown> sourceUnknown;
  THROW_IF_FAILED(
      mediaSource->QueryInterface(IID_PPV_ARGS(sourceUnknown.put())));
  m_mediaEngineExtension->SetMediaSource(sourceUnknown.get());

  winrt::com_ptr<IMFMediaEngineEx> mediaEngineEx =
      m_mediaEngine.as<IMFMediaEngineEx>();
  wil::unique_bstr source = wil::make_bstr(L"customSrc");
  THROW_IF_FAILED(mediaEngineEx->SetSource(source.get()));
}

void MediaEngineWrapper::ReleaseMediaSource() {
  m_mediaEngineExtension->SetMediaSource(nullptr);
  m_mediaEngine->SetSource(nullptr);
}

// Callback methods

void MediaEngineWrapper::OnLoaded() {
  if (m_initializedCB) {
    m_initializedCB();
  }
}

void MediaEngineWrapper::OnError(MF_MEDIA_ENGINE_ERR error, HRESULT hr) {
  if (m_errorCB) {
    m_errorCB(error, hr);
  }
}

void MediaEngineWrapper::OnBufferingStateChange(BufferingState state) {
  if (m_bufferingStateChangeCB) {
    m_bufferingStateChangeCB(state);
  }
}

void MediaEngineWrapper::OnPlaybackEnded() {
  if (m_playbackEndedCB) {
    m_playbackEndedCB();
  }
}

void MediaEngineWrapper::OnSeekCompleted() {
  if (m_seekCompletedCB) {
    m_seekCompletedCB();
  }
}

}  // namespace media
