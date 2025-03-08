#include "include/audioplayers_linux/audioplayers_linux_plugin.h"

// This must be included before many other Windows headers.
// #include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
// #include <VersionHelpers.h>

#include <flutter_linux/flutter_linux.h>
#include <string.h>

#include <map>
#include <memory>
#include <sstream>

#include "audio_player.h"

#define AUDIOPLAYERS_LINUX_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), audioplayers_linux_plugin_get_type(), \
                              AudioplayersLinuxPlugin))

struct _AudioplayersLinuxPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(AudioplayersLinuxPlugin,
              audioplayers_linux_plugin,
              g_object_get_type())

static FlBinaryMessenger* binaryMessenger;
static FlMethodChannel* methods;
static FlMethodChannel* globalMethods;
static FlEventChannel* globalEvents;
static std::map<std::string, std::unique_ptr<AudioPlayer>> audioPlayers;

static void audioplayers_linux_plugin_create_player(
    const std::string& playerId) {
  g_autoptr(FlStandardMethodCodec) eventCodec = fl_standard_method_codec_new();
  auto eventChannel = fl_event_channel_new(
      binaryMessenger, ("xyz.luan/audioplayers/events/" + playerId).c_str(),
      FL_METHOD_CODEC(eventCodec));

  auto player = std::make_unique<AudioPlayer>(playerId, methods, eventChannel);
  audioPlayers.insert(std::make_pair(playerId, std::move(player)));
}

static AudioPlayer* audioplayers_linux_plugin_get_player(
    const std::string& playerId) {
  auto searchPlayer = audioPlayers.find(playerId);
  if (searchPlayer == audioPlayers.end()) {
    return nullptr;
  }
  return searchPlayer->second.get();
}

static void audioplayers_linux_plugin_on_global_log(const gchar* message) {
  g_autoptr(FlValue) map = fl_value_new_map();
  fl_value_set_string(map, "event", fl_value_new_string("audio.onLog"));
  fl_value_set_string(map, "value", fl_value_new_string(message));

  fl_event_channel_send(globalEvents, map, nullptr, nullptr);
}

static void audioplayers_linux_plugin_handle_global_method_call(
    AudioplayersLinuxPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  int result = 1;
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "init") == 0) {
    for (const auto& entry : audioPlayers) {
      entry.second->Dispose();
    }
    audioPlayers.clear();
  } else if (strcmp(method, "setAudioContext") == 0) {
    audioplayers_linux_plugin_on_global_log(
        "Setting AudioContext is not supported on Linux");
  } else if (strcmp(method, "emitLog") == 0) {
    auto flMessage = fl_value_lookup_string(args, "message");
    auto message = flMessage == nullptr ? "" : fl_value_get_string(flMessage);
    audioplayers_linux_plugin_on_global_log(message);
  } else if (strcmp(method, "emitError") == 0) {
    auto flCode = fl_value_lookup_string(args, "code");
    auto code = flCode == nullptr ? "" : fl_value_get_string(flCode);
    auto flMessage = fl_value_lookup_string(args, "message");
    auto message = flMessage == nullptr ? "" : fl_value_get_string(flMessage);
    fl_event_channel_send_error(globalEvents, code, message, nullptr, nullptr,
                                nullptr);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  response = FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_int(result)));
  fl_method_call_respond(method_call, response, nullptr);
}

static void audioplayers_linux_plugin_handle_method_call(
    AudioplayersLinuxPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  auto flPlayerId = fl_value_lookup_string(args, "playerId");
  if (flPlayerId == nullptr) {
    response = FL_METHOD_RESPONSE(fl_method_error_response_new(
        "LinuxAudioError", "Call missing mandatory parameter playerId.",
        nullptr));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }
  auto playerId = std::string(fl_value_get_string(flPlayerId));

  if (strcmp(method, "create") == 0) {
    audioplayers_linux_plugin_create_player(playerId);
    response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_int(1)));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  auto player = audioplayers_linux_plugin_get_player(playerId);
  if (!player) {
    response = FL_METHOD_RESPONSE(fl_method_error_response_new(
        "LinuxAudioError",
        "Player has not yet been created or has already been disposed.",
        nullptr));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  FlValue* result = nullptr;

  try {
    if (strcmp(method, "pause") == 0) {
      player->Pause();
    } else if (strcmp(method, "resume") == 0) {
      player->Resume();
    } else if (strcmp(method, "stop") == 0) {
      player->Stop();
    } else if (strcmp(method, "release") == 0) {
      player->ReleaseMediaSource();
    } else if (strcmp(method, "seek") == 0) {
      auto flPosition = fl_value_lookup_string(args, "position");
      int position = flPosition == nullptr
                         ? (int)(player->GetPosition().value_or(0))
                         : fl_value_get_int(flPosition);
      player->SetPosition(position);
    } else if (strcmp(method, "setSourceUrl") == 0) {
      auto flUrl = fl_value_lookup_string(args, "url");
      if (flUrl == nullptr) {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new(
            "LinuxAudioError", "Null URL received on setSourceUrl.", nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }
      auto url = std::string(fl_value_get_string(flUrl));

      auto flIsLocal = fl_value_lookup_string(args, "isLocal");
      bool isLocal =
          flIsLocal == nullptr ? false : fl_value_get_bool(flIsLocal);
      if (isLocal) {
        url = std::string("file://") + url;
      }
      player->SetSourceUrl(url);
    } else if (strcmp(method, "getDuration") == 0) {
      auto optDuration = player->GetDuration();
      result = optDuration.has_value() ? fl_value_new_int(optDuration.value())
                                       : nullptr;
    } else if (strcmp(method, "setVolume") == 0) {
      auto flVolume = fl_value_lookup_string(args, "volume");
      double volume = flVolume == nullptr ? 1.0 : fl_value_get_float(flVolume);
      player->SetVolume(volume);
    } else if (strcmp(method, "getCurrentPosition") == 0) {
      auto optPosition = player->GetPosition();
      result = optPosition.has_value() ? fl_value_new_int(optPosition.value())
                                       : nullptr;
    } else if (strcmp(method, "setPlaybackRate") == 0) {
      auto flPlaybackRate = fl_value_lookup_string(args, "playbackRate");
      double playbackRate =
          flPlaybackRate == nullptr ? 1.0 : fl_value_get_float(flPlaybackRate);
      player->SetPlaybackRate(playbackRate);
    } else if (strcmp(method, "setReleaseMode") == 0) {
      auto flReleaseMode = fl_value_lookup_string(args, "releaseMode");
      std::string releaseModeStr =
          flReleaseMode == nullptr
              ? std::string()
              : std::string(fl_value_get_string(flReleaseMode));
      if (releaseModeStr.empty()) {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new(
            "LinuxAudioError",
            "Error calling setReleaseMode, releaseMode cannot be null",
            nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }

      auto releaseModeIt = releaseModeMap.find(releaseModeStr);
      if (releaseModeIt != releaseModeMap.end()) {
        player->SetReleaseMode(releaseModeIt->second);
      } else {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new(
            "LinuxAudioError",
            ("Error calling setReleaseMode, releaseMode '" + releaseModeStr +
             "' not known")
                .c_str(),
            nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }
    } else if (strcmp(method, "setPlayerMode") == 0) {
      // TODO check support for low latency mode:
      // https://gstreamer.freedesktop.org/documentation/additional/design/latency.html?gi-language=c
    } else if (strcmp(method, "setAudioContext") == 0) {
      player->OnLog("Setting AudioContext is not supported on Linux");
    } else if (strcmp(method, "setBalance") == 0) {
      auto flBalance = fl_value_lookup_string(args, "balance");
      double balance =
          flBalance == nullptr ? 0.0f : fl_value_get_float(flBalance);
      player->SetBalance(balance);
    } else if (strcmp(method, "emitLog") == 0) {
      auto flMessage = fl_value_lookup_string(args, "message");
      auto message = flMessage == nullptr ? "" : fl_value_get_string(flMessage);
      player->OnLog(message);
    } else if (strcmp(method, "emitError") == 0) {
      auto flCode = fl_value_lookup_string(args, "code");
      auto code = flCode == nullptr ? "" : fl_value_get_string(flCode);
      auto flMessage = fl_value_lookup_string(args, "message");
      auto message = flMessage == nullptr ? "" : fl_value_get_string(flMessage);
      player->OnError(code, message, nullptr, nullptr);
    } else if (strcmp(method, "dispose") == 0) {
      player->Dispose();
      audioPlayers.erase(playerId);
    } else {
      response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  } catch (const gchar* error) {
    response = FL_METHOD_RESPONSE(
        fl_method_error_response_new("LinuxAudioError", error, nullptr));
    fl_method_call_respond(method_call, response, nullptr);
  } catch (...) {
    std::exception_ptr p = std::current_exception();
    response = FL_METHOD_RESPONSE(
        fl_method_error_response_new("LinuxAudioError",
                                     p ? p.__cxa_exception_type()->name()
                                       : "Unknown AudioPlayersLinux error",
                                     nullptr));
    fl_method_call_respond(method_call, response, nullptr);
  }
}

static void audioplayers_linux_plugin_dispose(GObject* object) {
  for (const auto& entry : audioPlayers) {
    entry.second->Dispose();
  }
  audioPlayers.clear();
  gst_deinit();
  g_clear_object(&globalEvents);
  g_clear_object(&globalMethods);
  g_clear_object(&methods);
  G_OBJECT_CLASS(audioplayers_linux_plugin_parent_class)->dispose(object);
}

static void audioplayers_linux_plugin_class_init(
    AudioplayersLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = audioplayers_linux_plugin_dispose;
}

static void audioplayers_linux_plugin_init(AudioplayersLinuxPlugin* self) {}

static void method_call_cb(FlMethodChannel* methods,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  AudioplayersLinuxPlugin* plugin = AUDIOPLAYERS_LINUX_PLUGIN(user_data);
  audioplayers_linux_plugin_handle_method_call(plugin, method_call);
}

static void method_call_global_cb(FlMethodChannel* methods,
                                  FlMethodCall* method_call,
                                  gpointer user_data) {
  AudioplayersLinuxPlugin* plugin = AUDIOPLAYERS_LINUX_PLUGIN(user_data);
  audioplayers_linux_plugin_handle_global_method_call(plugin, method_call);
}

void audioplayers_linux_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  AudioplayersLinuxPlugin* plugin = AUDIOPLAYERS_LINUX_PLUGIN(
      g_object_new(audioplayers_linux_plugin_get_type(), nullptr));

  binaryMessenger = fl_plugin_registrar_get_messenger(registrar);

  g_autoptr(FlStandardMethodCodec) methodCodec = fl_standard_method_codec_new();
  methods = fl_method_channel_new(binaryMessenger, "xyz.luan/audioplayers",
                                  FL_METHOD_CODEC(methodCodec));

  g_autoptr(FlStandardMethodCodec) globalMethodCodec =
      fl_standard_method_codec_new();
  globalMethods =
      fl_method_channel_new(binaryMessenger, "xyz.luan/audioplayers.global",
                            FL_METHOD_CODEC(globalMethodCodec));

  g_autoptr(FlStandardMethodCodec) globalEventCodec =
      fl_standard_method_codec_new();
  globalEvents = fl_event_channel_new(binaryMessenger,
                                      "xyz.luan/audioplayers.global/events",
                                      FL_METHOD_CODEC(globalEventCodec));

  fl_method_channel_set_method_call_handler(
      methods, method_call_cb, g_object_ref(plugin), g_object_unref);

  fl_method_channel_set_method_call_handler(
      globalMethods, method_call_global_cb, g_object_ref(plugin),
      g_object_unref);

  // No need to set handler for `globalEvents` as no events are received.

  g_object_unref(plugin);
}
