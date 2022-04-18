#include "include/audioplayers_linux/audioplayers_linux_plugin.h"

// This must be included before many other Windows headers.
//#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
//#include <VersionHelpers.h>

#include <flutter_linux/flutter_linux.h>
#include <string.h>

#include <map>
#include <memory>
#include <sstream>

#include "Logger.h"
#include "audio_player.h"

#define AUDIOPLAYERS_LINUX_PLUGIN(obj)                                       \
    (G_TYPE_CHECK_INSTANCE_CAST((obj), audioplayers_linux_plugin_get_type(), \
                                AudioplayersLinuxPlugin))

struct _AudioplayersLinuxPlugin {
    GObject parent_instance;
};

G_DEFINE_TYPE(AudioplayersLinuxPlugin, audioplayers_linux_plugin,
              g_object_get_type())

static FlMethodChannel *channel;
static FlMethodChannel *globalChannel;
static std::map<std::string, std::unique_ptr<AudioPlayer>> audioPlayers;

static AudioPlayer *audioplayers_linux_plugin_GetPlayer(
    AudioplayersLinuxPlugin *self, std::string playerId, std::string mode) {
    auto searchPlayer = audioPlayers.find(playerId);
    if (searchPlayer != audioPlayers.end()) {
        return searchPlayer->second.get();
    } else {
        auto player = std::make_unique<AudioPlayer>(playerId, channel);
        auto playerPtr = player.get();
        audioPlayers.insert(std::make_pair(playerId, std::move(player)));
        return playerPtr;
    }
}

static void audioplayers_linux_plugin_HandleGlobalMethodCall(
    AudioplayersLinuxPlugin *self, FlMethodCall *method_call) {
    g_autoptr(FlMethodResponse) response = nullptr;
    int result = 1;
    const gchar *method = fl_method_call_get_name(method_call);
    FlValue *args = fl_method_call_get_args(method_call);

    if (strcmp(method, "changeLogLevel") == 0) {
        auto flValueName = fl_value_lookup_string(args, "value");
        if (flValueName == nullptr) {
            Logger::Error("Null value received on changeLogLevel");
            result = 0;
            return;
        }
        auto valueName = fl_value_get_string(flValueName);
        LogLevel value;
        if (strcmp(valueName, "LogLevel.info") == 0) {
            value = LogLevel::Info;
        } else if (strcmp(valueName, "LogLevel.error") == 0) {
            value = LogLevel::Error;
        } else if (strcmp(valueName, "LogLevel.none") == 0) {
            value = LogLevel::None;
        } else {
            Logger::Error("Invalid value received on changeLogLevel");
            result = 0;
            return;
        }

        Logger::logLevel = value;
    }

    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_int(result)));
    fl_method_call_respond(method_call, response, nullptr);
}

static void audioplayers_linux_plugin_HandleMethodCall(
    AudioplayersLinuxPlugin *self, FlMethodCall *method_call) {
    g_autoptr(FlMethodResponse) response = nullptr;
    int result;
    const gchar *method = fl_method_call_get_name(method_call);
    FlValue *args = fl_method_call_get_args(method_call);

    auto flPlayerId = fl_value_lookup_string(args, "playerId");
    if (flPlayerId == nullptr) {
        Logger::Error("Call missing mandatory parameter playerId.");
        result = 0;
    }
    auto playerId = std::string(fl_value_get_string(flPlayerId));

    auto flMode = fl_value_lookup_string(args, "mode");

    std::string mode;
    if (flMode == nullptr) {
        mode = std::string();
    } else {
        mode = std::string(fl_value_get_string(flMode));
    }

    auto player = audioplayers_linux_plugin_GetPlayer(self, playerId, mode);

    if (strcmp(method, "pause") == 0) {
        player->Pause();
        result = 1;
    } else if (strcmp(method, "resume") == 0) {
        player->Resume();
        result = 1;
    } else if (strcmp(method, "stop") == 0) {
        player->Pause();
        player->SeekTo(0);
        result = 1;
    } else if (strcmp(method, "release") == 0) {
        player->Pause();
        player->SeekTo(0);
        result = 1;
    } else if (strcmp(method, "seek") == 0) {
        int position =
            fl_value_get_float(fl_value_lookup_string(args, "position"));
        if (!position) {
            position = (int)(player->GetPosition() / 10000);
        }
        player->SeekTo(position * 10000);
        result = 1;
    } else if (strcmp(method, "setSourceUrl") == 0) {
        auto flUrl = fl_value_lookup_string(args, "url");
        if (flUrl == nullptr) {
            Logger::Error("Null URL received on setSourceUrl");
            result = 0;
            return;
        }
        auto url = std::string(fl_value_get_string(flUrl));
        
        auto flIsLocal = fl_value_lookup_string(args, "isLocal");
        bool isLocal = false;
        if(flIsLocal != nullptr) {
           isLocal = fl_value_get_bool(flIsLocal);
        }
        if(isLocal) {
            url = std::string("file://") + url;
        }

        try {
            player->SetSourceUrl(url);
            result = 1;
        } catch (...) {
            Logger::Error("Error setting url to '" + url + "'.");
            result = 0;
        }
    } else if (strcmp(method, "getDuration") == 0) {
        result = player->GetDuration() / 10000;
    } else if (strcmp(method, "setVolume") == 0) {
        // double volume = GetArgument<double>("volume", args, 1.0);
        // player->SetVolume(volume);
        // result = 1;
    } else if (strcmp(method, "getCurrentPosition") == 0) {
        result = player->GetPosition() / 10000;
    } else if (strcmp(method, "setPlaybackRate") == 0) {
        // auto playbackRate = GetArgument<double>("playbackRate", args, 1.0);
        // player->SetPlaybackSpeed(playbackRate);
        // result = 1;
    } else if (strcmp(method, "setReleaseMode") == 0) {
        // auto releaseMode = GetArgument<std::string>("releaseMode", args,
        // std::string()); if (releaseMode.empty()) {
        //     Logger::Error("Error calling setReleaseMode, releaseMode cannot
        //     be null"); result = 0; return;
        // }
        // auto looping = releaseMode.find("loop") != std::string::npos;
        // player->SetLooping(looping);
        // result = 1;
    } else {
        response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
        fl_method_call_respond(method_call, response, nullptr);
        return;
    }

    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_int(result)));
    fl_method_call_respond(method_call, response, nullptr);
}

static void audioplayers_linux_plugin_dispose(GObject *object) {
    G_OBJECT_CLASS(audioplayers_linux_plugin_parent_class)->dispose(object);
}

static void audioplayers_linux_plugin_class_init(
    AudioplayersLinuxPluginClass *klass) {
    G_OBJECT_CLASS(klass)->dispose = audioplayers_linux_plugin_dispose;
}

static void audioplayers_linux_plugin_init(AudioplayersLinuxPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data) {
    AudioplayersLinuxPlugin *plugin = AUDIOPLAYERS_LINUX_PLUGIN(user_data);
    audioplayers_linux_plugin_HandleMethodCall(plugin, method_call);
}

static void method_call_global_cb(FlMethodChannel *channel,
                                  FlMethodCall *method_call,
                                  gpointer user_data) {
    AudioplayersLinuxPlugin *plugin = AUDIOPLAYERS_LINUX_PLUGIN(user_data);
    audioplayers_linux_plugin_HandleGlobalMethodCall(plugin, method_call);
}

void audioplayers_linux_plugin_register_with_registrar(
    FlPluginRegistrar *registrar) {
    AudioplayersLinuxPlugin *plugin = AUDIOPLAYERS_LINUX_PLUGIN(
        g_object_new(audioplayers_linux_plugin_get_type(), nullptr));

    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    channel =
        fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                              "xyz.luan/audioplayers", FL_METHOD_CODEC(codec));

    g_autoptr(FlStandardMethodCodec) globalCodec =
        fl_standard_method_codec_new();
    globalChannel = fl_method_channel_new(
        fl_plugin_registrar_get_messenger(registrar),
        "xyz.luan/audioplayers.global", FL_METHOD_CODEC(globalCodec));

    fl_method_channel_set_method_call_handler(
        channel, method_call_cb, g_object_ref(plugin), g_object_unref);

    fl_method_channel_set_method_call_handler(
        globalChannel, method_call_global_cb, g_object_ref(plugin),
        g_object_unref);

    g_object_unref(plugin);
}