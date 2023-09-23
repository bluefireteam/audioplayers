#include "include/audioplayers_windows/audioplayers_windows_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

#include "audio_player.h"
#include "audioplayers_helpers.h"

namespace {

using namespace flutter;

template <typename T>
T GetArgument(const std::string arg, const EncodableValue* args, T fallback) {
  T result{fallback};
  const auto* arguments = std::get_if<EncodableMap>(args);
  if (arguments) {
    auto result_it = arguments->find(EncodableValue(arg));
    if (result_it != arguments->end()) {
      if (!result_it->second.IsNull())
        result = std::get<T>(result_it->second);
    }
  }
  return result;
}

class AudioplayersWindowsPlugin : public Plugin {
 public:
  static void RegisterWithRegistrar(PluginRegistrarWindows* registrar);

  AudioplayersWindowsPlugin();

  virtual ~AudioplayersWindowsPlugin();

 private:
  std::map<std::string, std::unique_ptr<AudioPlayer>> audioPlayers;

  static inline BinaryMessenger* binaryMessenger;
  static inline std::unique_ptr<MethodChannel<EncodableValue>> methods{};
  static inline std::unique_ptr<MethodChannel<EncodableValue>> globalMethods{};
  static inline std::unique_ptr<EventStreamHandler<>> globalEvents{};

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(const MethodCall<EncodableValue>& method_call,
                        std::unique_ptr<MethodResult<EncodableValue>> result);

  void HandleGlobalMethodCall(
      const MethodCall<EncodableValue>& method_call,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void CreatePlayer(std::string playerId);

  AudioPlayer* GetPlayer(std::string playerId);

  void OnGlobalLog(const std::string& message);
};

// static
void AudioplayersWindowsPlugin::RegisterWithRegistrar(
    PluginRegistrarWindows* registrar) {
  binaryMessenger = registrar->messenger();
  methods = std::make_unique<MethodChannel<EncodableValue>>(
      binaryMessenger, "xyz.luan/audioplayers",
      &StandardMethodCodec::GetInstance());
  globalMethods = std::make_unique<MethodChannel<EncodableValue>>(
      binaryMessenger, "xyz.luan/audioplayers.global",
      &StandardMethodCodec::GetInstance());
  auto _globalEventChannel = std::make_unique<EventChannel<EncodableValue>>(
      binaryMessenger, "xyz.luan/audioplayers.global/events",
      &StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AudioplayersWindowsPlugin>();

  methods->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  globalMethods->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleGlobalMethodCall(call, std::move(result));
      });
  globalEvents = std::make_unique<EventStreamHandler<>>();
  auto _obj_stm_handle =
      static_cast<StreamHandler<EncodableValue>*>(globalEvents.get());
  std::unique_ptr<StreamHandler<EncodableValue>> _ptr{_obj_stm_handle};
  _globalEventChannel->SetStreamHandler(std::move(_ptr));

  registrar->AddPlugin(std::move(plugin));
}

AudioplayersWindowsPlugin::AudioplayersWindowsPlugin() {}

AudioplayersWindowsPlugin::~AudioplayersWindowsPlugin() {}

void AudioplayersWindowsPlugin::HandleGlobalMethodCall(
    const MethodCall<EncodableValue>& method_call,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto args = method_call.arguments();

  if (method_call.method_name().compare("setAudioContext") == 0) {
    this->OnGlobalLog("Setting AudioContext is not supported on Windows");
  } else if (method_call.method_name().compare("emitLog") == 0) {
    auto message = GetArgument<std::string>("message", args, std::string());
    this->OnGlobalLog(message);
  } else if (method_call.method_name().compare("emitError") == 0) {
    auto code = GetArgument<std::string>("code", args, std::string());
    auto message = GetArgument<std::string>("message", args, std::string());
    globalEvents->Error(code, message, nullptr);
    result->Success();
  } else {
    result->NotImplemented();
    return;
  }

  result->Success();
}

void AudioplayersWindowsPlugin::HandleMethodCall(
    const MethodCall<EncodableValue>& method_call,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto args = method_call.arguments();

  auto playerId = GetArgument<std::string>("playerId", args, std::string());
  if (playerId.empty()) {
    result->Error("WindowsAudioError",
                  "Call missing mandatory parameter playerId.", nullptr);
    return;
  }

  if (method_call.method_name().compare("create") == 0) {
    CreatePlayer(playerId);
    result->Success();
    return;
  }

  auto player = GetPlayer(playerId);
  if (!player) {
    result->Error(
        "WindowsAudioError",
        "Player has not yet been created or has already been disposed.",
        nullptr);
    return;
  }

  if (method_call.method_name().compare("pause") == 0) {
    player->Pause();
  } else if (method_call.method_name().compare("resume") == 0) {
    player->Resume();
  } else if (method_call.method_name().compare("stop") == 0) {
    player->Pause();
    player->SeekTo(0);
  } else if (method_call.method_name().compare("release") == 0) {
    player->ReleaseMediaSource();
  } else if (method_call.method_name().compare("seek") == 0) {
    auto positionInMs = GetArgument<int>(
        "position", args, (int)ConvertSecondsToMs(player->GetPosition()));
    player->SeekTo(ConvertMsToSeconds(positionInMs));
  } else if (method_call.method_name().compare("setSourceUrl") == 0) {
    auto url = GetArgument<std::string>("url", args, std::string());

    if (url.empty()) {
      result->Error("WindowsAudioError", "Null URL received on setSourceUrl",
                    nullptr);
      return;
    }

    std::thread(&AudioPlayer::SetSourceUrl, player, url).detach();
  } else if (method_call.method_name().compare("setSourceBytes") == 0) {
    auto data = GetArgument<std::vector<uint8_t>>("bytes", args,
                                                  std::vector<uint8_t>{});

    if (data.empty()) {
      result->Error("WindowsAudioError",
                    "Null bytes received on setSourceBytes", nullptr);
      return;
    }

    std::thread(&AudioPlayer::SetSourceBytes, player, data).detach();
  } else if (method_call.method_name().compare("getDuration") == 0) {
    auto duration = player->GetDuration();
    result->Success(isnan(duration)
                        ? EncodableValue(std::monostate{})
                        : EncodableValue(ConvertSecondsToMs(duration)));
    return;
  } else if (method_call.method_name().compare("setVolume") == 0) {
    auto volume = GetArgument<double>("volume", args, 1.0);
    player->SetVolume(volume);
  } else if (method_call.method_name().compare("getCurrentPosition") == 0) {
    auto position = player->GetPosition();
    result->Success(isnan(position)
                        ? EncodableValue(std::monostate{})
                        : EncodableValue(ConvertSecondsToMs(position)));
    return;
  } else if (method_call.method_name().compare("setPlaybackRate") == 0) {
    auto playbackRate = GetArgument<double>("playbackRate", args, 1.0);
    player->SetPlaybackSpeed(playbackRate);
  } else if (method_call.method_name().compare("setReleaseMode") == 0) {
    auto releaseMode =
        GetArgument<std::string>("releaseMode", args, std::string());
    if (releaseMode.empty()) {
      result->Error("WindowsAudioError",
                    "Error calling setReleaseMode, releaseMode cannot be null",
                    nullptr);
      return;
    }
    auto looping = releaseMode.find("loop") != std::string::npos;
    player->SetLooping(looping);
  } else if (method_call.method_name().compare("setPlayerMode") == 0) {
    // windows doesn't have multiple player modes, so this should no-op
  } else if (method_call.method_name().compare("setBalance") == 0) {
    auto balance = GetArgument<double>("balance", args, 0.0);
    player->SetBalance(balance);
  } else if (method_call.method_name().compare("emitLog") == 0) {
    auto message = GetArgument<std::string>("message", args, std::string());
    player->OnLog(message);
  } else if (method_call.method_name().compare("emitError") == 0) {
    auto code = GetArgument<std::string>("code", args, std::string());
    auto message = GetArgument<std::string>("message", args, std::string());
    player->OnError(code, message, nullptr);
  } else if (method_call.method_name().compare("dispose") == 0) {
    player->Dispose();
    audioPlayers.erase(playerId);
  } else {
    result->NotImplemented();
    return;
  }
  result->Success();
}

void AudioplayersWindowsPlugin::CreatePlayer(std::string playerId) {
  auto eventChannel = std::make_unique<EventChannel<EncodableValue>>(
      binaryMessenger, "xyz.luan/audioplayers/events/" + playerId,
      &StandardMethodCodec::GetInstance());

  auto eventHandler = new EventStreamHandler<>();
  auto _obj_stm_handle =
      static_cast<StreamHandler<EncodableValue>*>(eventHandler);
  std::unique_ptr<StreamHandler<EncodableValue>> _ptr{_obj_stm_handle};
  eventChannel->SetStreamHandler(std::move(_ptr));

  auto player =
      std::make_unique<AudioPlayer>(playerId, methods.get(), eventHandler);
  audioPlayers.insert(std::make_pair(playerId, std::move(player)));
}

AudioPlayer* AudioplayersWindowsPlugin::GetPlayer(std::string playerId) {
  auto searchPlayer = audioPlayers.find(playerId);
  if (searchPlayer == audioPlayers.end()) {
    return nullptr;
  }
  return searchPlayer->second.get();
}

void AudioplayersWindowsPlugin::OnGlobalLog(const std::string& message) {
  globalEvents->Success(std::make_unique<flutter::EncodableValue>(
      flutter::EncodableMap({{flutter::EncodableValue("event"),
                              flutter::EncodableValue("audio.onLog")},
                             {flutter::EncodableValue("value"),
                              flutter::EncodableValue(message)}})));
}

}  // namespace

void AudioplayersWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  AudioplayersWindowsPlugin::RegisterWithRegistrar(
      PluginRegistrarManager::GetInstance()
          ->GetRegistrar<PluginRegistrarWindows>(registrar));
}
