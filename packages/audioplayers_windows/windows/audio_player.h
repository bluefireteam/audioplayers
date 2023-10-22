#pragma once

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#undef GetCurrentTime

#include <shobjidl.h>
#include <unknwn.h>
#include <winrt/Windows.Foundation.Collections.h>

#include "winrt/Windows.System.h"

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>

// Windows Implementation Library
#include <wil/resource.h>
#include <wil/result_macros.h>

// MediaFoundation headers
#include <Audioclient.h>
#include <mfapi.h>
#include <mferror.h>
#include <mfmediaengine.h>

// STL headers
#include <wincodec.h>

#include <functional>
#include <future>
#include <map>
#include <memory>
#include <sstream>
#include <string>

#include "MediaEngineWrapper.h"
#include "MediaFoundationHelpers.h"
#include "event_stream_handler.h"

using namespace winrt;

class AudioPlayer {
 public:
  AudioPlayer(std::string playerId,
              flutter::MethodChannel<flutter::EncodableValue>* methodChannel,
              EventStreamHandler<>* eventHandler);

  void Dispose();

  void ReleaseMediaSource();

  void SetLooping(bool isLooping);

  void SetVolume(double volume);

  void SetPlaybackSpeed(double playbackSpeed);

  void SetBalance(double balance);

  void Play();

  void Pause();

  void Resume();

  bool GetLooping();

  double GetPosition();

  double GetDuration();

  void SeekTo(double seek);

  void SetSourceBytes(std::vector<uint8_t> bytes);

  void SetSourceUrl(std::string url);

  void OnLog(const std::string& message);

  void OnError(const std::string& code,
               const std::string& message,
               const flutter::EncodableValue& details);

  virtual ~AudioPlayer();

 private:
  // Media members
  media::MFPlatformRef m_mfPlatform;
  winrt::com_ptr<media::MediaEngineWrapper> m_mediaEngineWrapper;

  bool _isInitialized = false;
  std::string _url{};

  void SendInitialized();

  void OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr);

  void OnMediaStateChange(
      media::MediaEngineWrapper::BufferingState bufferingState);

  void OnPlaybackEnded();

  void OnDurationUpdate();

  void OnSeekCompleted();

  void OnPrepared(bool isPrepared);

  std::string _playerId;

  flutter::MethodChannel<flutter::EncodableValue>* _methodChannel;

  EventStreamHandler<>* _eventHandler;
};
