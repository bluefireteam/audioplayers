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
#include <mutex>
#include <sstream>

#include "Logger.h"
#include "audio_player.h"

namespace {

using namespace flutter;

template <typename T>
T GetArgument(const std::string arg, const EncodableValue *args, T fallback) {
    T result{fallback};
    const auto *arguments = std::get_if<EncodableMap>(args);
    if (arguments) {
        auto result_it = arguments->find(EncodableValue(arg));
        if (result_it != arguments->end()) {
            if (!result_it->second.IsNull())
                result = std::get<T>(result_it->second);
        }
    }
    return result;
}

template <typename T = EncodableValue>
class EventStreamHandler : public StreamHandler<T> {
   public:
    EventStreamHandler() = default;

    virtual ~EventStreamHandler() = default;

    void on_callback(EncodableValue _data) {
        std::unique_lock<std::mutex> _ul(m_mtx);
        if (m_sink.get()) m_sink.get()->Success(_data);
    }

   protected:
    std::unique_ptr<StreamHandlerError<T>> OnListenInternal(
        const T *arguments, std::unique_ptr<EventSink<T>> &&events) override {
        std::unique_lock<std::mutex> _ul(m_mtx);
        m_sink = std::move(events);
        return nullptr;
    }

    std::unique_ptr<StreamHandlerError<T>> OnCancelInternal(
        const T *arguments) override {
        std::unique_lock<std::mutex> _ul(m_mtx);
        m_sink.release();
        return nullptr;
    }

   private:
    EncodableValue m_value;
    std::mutex m_mtx;
    std::unique_ptr<EventSink<T>> m_sink;
};

class AudioplayersWindowsPlugin : public Plugin {
   public:
    static void RegisterWithRegistrar(PluginRegistrarWindows *registrar);

    AudioplayersWindowsPlugin();

    virtual ~AudioplayersWindowsPlugin();

   private:
    std::map<std::string, std::unique_ptr<AudioPlayer>> audioPlayers;

    static inline BinaryMessenger *binaryMessenger;
    static inline std::unique_ptr<MethodChannel<EncodableValue>> methods{};
    static inline std::unique_ptr<MethodChannel<EncodableValue>>
        globalMethods{};
    static inline std::unique_ptr<EventChannel<EncodableValue>> globalEvents;

    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(const MethodCall<EncodableValue> &method_call,
                          std::unique_ptr<MethodResult<EncodableValue>> result);

    void HandleGlobalMethodCall(
        const MethodCall<EncodableValue> &method_call,
        std::unique_ptr<MethodResult<EncodableValue>> result);

    void CreatePlayer(std::string playerId);

    AudioPlayer *GetPlayer(std::string playerId);
};

// static
void AudioplayersWindowsPlugin::RegisterWithRegistrar(
    PluginRegistrarWindows *registrar) {
    binaryMessenger = registrar->messenger();
    methods = std::make_unique<MethodChannel<EncodableValue>>(
        binaryMessenger, "xyz.luan/audioplayers",
        &StandardMethodCodec::GetInstance());
    globalMethods = std::make_unique<MethodChannel<EncodableValue>>(
        binaryMessenger, "xyz.luan/audioplayers.global",
        &StandardMethodCodec::GetInstance());
    globalEvents = std::make_unique<EventChannel<EncodableValue>>(
        binaryMessenger, "xyz.luan/audioplayers.global/events",
        &StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<AudioplayersWindowsPlugin>();

    methods->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    globalMethods->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
            plugin_pointer->HandleGlobalMethodCall(call, std::move(result));
        });

    EventStreamHandler<> *_globalEventStreamHandler =
        new EventStreamHandler<>();
    auto _obj_stm_handle =
        static_cast<StreamHandler<EncodableValue> *>(_globalEventStreamHandler);
    std::unique_ptr<StreamHandler<EncodableValue>> _ptr{_obj_stm_handle};
    globalEvents->SetStreamHandler(std::move(_ptr));

    registrar->AddPlugin(std::move(plugin));
}

AudioplayersWindowsPlugin::AudioplayersWindowsPlugin() {}

AudioplayersWindowsPlugin::~AudioplayersWindowsPlugin() {}

void AudioplayersWindowsPlugin::HandleGlobalMethodCall(
    const MethodCall<EncodableValue> &method_call,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
    // auto args = method_call.arguments();

    if (method_call.method_name().compare("setGlobalAudioContext") == 0) {
        Logger::Error("Setting AudioContext is not supported for Windows");
    }

    result->Success(EncodableValue(1));
}

void AudioplayersWindowsPlugin::HandleMethodCall(
    const MethodCall<EncodableValue> &method_call,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
    auto args = method_call.arguments();

    auto playerId = GetArgument<std::string>("playerId", args, std::string());
    if (playerId.empty()) {
        Logger::Error("Call missing mandatory parameter playerId.");
        result->Success(EncodableValue(0));
    }

    if (method_call.method_name().compare("create") == 0) {
        CreatePlayer(playerId);
        result->Success(EncodableValue(1));
        return;
    }

    auto player = GetPlayer(playerId);

    if (method_call.method_name().compare("pause") == 0) {
        player->Pause();
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("resume") == 0) {
        player->Resume();
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("stop") == 0) {
        player->Pause();
        player->SeekTo(0);
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("release") == 0) {
        player->Pause();
        player->SeekTo(0);
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("seek") == 0) {
        auto position = GetArgument<int>("position", args,
                                         (int)(player->GetPosition() / 10000));
        player->SeekTo(static_cast<int64_t>(position * 10000.0));
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("setSourceUrl") == 0) {
        auto url = GetArgument<std::string>("url", args, std::string());

        if (url.empty()) {
            Logger::Error("Null URL received on setSourceUrl");
            result->Success(EncodableValue(0));
            return;
        }

        try {
            player->SetSourceUrl(url);
            result->Success(EncodableValue(1));
        } catch (...) {
            Logger::Error("Error setting url to '" + url + "'.");
            result->Success(EncodableValue(0));
        }
    } else if (method_call.method_name().compare("getDuration") == 0) {
        result->Success(EncodableValue(player->GetDuration() / 10000));
    } else if (method_call.method_name().compare("setVolume") == 0) {
        auto volume = GetArgument<double>("volume", args, 1.0);
        player->SetVolume(volume);
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("getCurrentPosition") == 0) {
        result->Success(EncodableValue(player->GetPosition() / 10000));
    } else if (method_call.method_name().compare("setPlaybackRate") == 0) {
        auto playbackRate = GetArgument<double>("playbackRate", args, 1.0);
        player->SetPlaybackSpeed(playbackRate);
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("setReleaseMode") == 0) {
        auto releaseMode =
            GetArgument<std::string>("releaseMode", args, std::string());
        if (releaseMode.empty()) {
            Logger::Error(
                "Error calling setReleaseMode, releaseMode cannot be null");
            result->Success(EncodableValue(0));
            return;
        }
        auto looping = releaseMode.find("loop") != std::string::npos;
        player->SetLooping(looping);
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("setPlayerMode") == 0) {
        // windows doesn't have multiple player modes, so this should no-op
        result->Success(EncodableValue(1));
    } else if (method_call.method_name().compare("setBalance") == 0) {
        auto balance = GetArgument<double>("balance", args, 0.0);
        player->SetBalance(balance);
        result->Success(EncodableValue(1));
    } else {
        result->NotImplemented();
    }
}

void AudioplayersWindowsPlugin::CreatePlayer(std::string playerId) {
    auto events = std::make_unique<EventChannel<EncodableValue>>(
        binaryMessenger, "xyz.luan/audioplayers/events/" + playerId,
        &StandardMethodCodec::GetInstance());

    auto player =
        std::make_unique<AudioPlayer>(playerId, methods.get(), events.get());
    audioPlayers.insert(std::make_pair(playerId, std::move(player)));
}

AudioPlayer *AudioplayersWindowsPlugin::GetPlayer(std::string playerId) {
    auto searchPlayer = audioPlayers.find(playerId);
    return searchPlayer->second.get();
}

}  // namespace

void AudioplayersWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
    AudioplayersWindowsPlugin::RegisterWithRegistrar(
        PluginRegistrarManager::GetInstance()
            ->GetRegistrar<PluginRegistrarWindows>(registrar));
}
