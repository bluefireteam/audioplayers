#pragma once

#include <flutter_linux/flutter_linux.h>

#include <future>
#include <map>
#include <memory>
#include <sstream>
#include <string>

// STL headers
#include <functional>
#include <map>
#include <memory>
#include <sstream>
#include <string>
extern "C" {
#include <gst/gst.h>
}

class AudioPlayer {
   public:
    AudioPlayer(std::string playerId, FlMethodChannel *channel);

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
    // Gst members
    GstElement *playbin;
    GstElement *source;
    GstBus *bus;
    GMainLoop *main_loop;

    bool _isInitialized = false;
    bool _isLooping = false;

    std::string _url{};

    static gboolean OnBusMessage(GstBus *bus, GstMessage *message,
                                 AudioPlayer *data);
    static void SourceSetup(GstElement *playbin, GstElement *source,
                            GstElement **p_src);
    static gboolean OnRefresh(AudioPlayer *data);
    // void SendInitialized();

    void OnMediaError(GError *error, gchar *debug);
    void OnMediaStateChange(GstObject *src, GstState *old_state,
                            GstState *new_state);
    void OnPlaybackEnded();
    void OnPositionUpdate();
    void OnDurationUpdate();
    void OnSeekCompleted();

    std::string _playerId;

    FlMethodChannel *_channel;
};
