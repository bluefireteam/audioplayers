package xyz.luan.audioplayers;

import android.media.MediaPlayer;
import android.media.AudioAttributes;
import android.os.Handler;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class AudioplayersPlugin implements MethodCallHandler {

    private static final Logger LOGGER = Logger.getLogger(AudioplayersPlugin.class.getCanonicalName());

    private final MethodChannel channel;
    private final Map<String, WrappedMediaPlayer> mediaPlayers = new HashMap<>();
    private final Handler handler = new Handler();
    private Runnable positionUpdates;

    public static void registerWith(final Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "xyz.luan/audioplayers");
        channel.setMethodCallHandler(new AudioplayersPlugin(channel));
    }

    private AudioplayersPlugin(final MethodChannel channel) {
        this.channel = channel;
        this.channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(final MethodCall call, final MethodChannel.Result response) {
        try {
            handleMethodCall(call, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error!", e);
            response.error("Unexpected error!", e.getMessage(), e);
        }
    }

    private void handleMethodCall(final MethodCall call, final MethodChannel.Result response) {
        final String playerId = call.argument("playerId");
        final WrappedMediaPlayer player = getPlayer(playerId);
        switch (call.method) {
            case "play": {
                final String url = call.argument("url");
                final double volume = call.argument("volume");
                final double position = call.argument("position");
                final boolean respectSilence = call.argument("respectSilence");
                player.configAttributes(respectSilence);
                player.setVolume(volume);
                player.setUrl(url);
                if (position != null) {
                    player.seek(position);
                }
                player.play();
                break;
            }
            case "resume": {
                player.play();
                break;
            }
            case "pause": {
                player.pause();
                break;
            }
            case "stop": {
                player.stop();
                break;
            }
            case "release": {
                player.release();
                break;
            }
            case "seek": {
                final Double position = call.argument("position");
                player.seek(position);
                break;
            }
            case "setVolume": {
                final double volume = call.argument("volume");
                player.setVolume(volume);
                break;
            }
            case "setUrl": {
                final String url = call.argument("url");
                player.setUrl(url);
                break;
            }
            case "setReleaseMode": {
                final String releaseModeName = call.argument("releaseMode");
                final ReleaseMode releaseMode = ReleaseMode.valueOf(releaseModeName.substring("ReleaseMode.".length()));
                player.setReleaseMode(releaseMode);
                break;
            }
            default: {
                response.notImplemented();
                return;
            }
        }
        response.success(1);
    }

    private WrappedMediaPlayer getPlayer(String playerId) {
        if (!mediaPlayers.containsKey(playerId)) {
            mediaPlayers.put(playerId, new WrappedMediaPlayer(this, playerId));
        }
        return mediaPlayers.get(playerId);
    }

    public void handleIsPlaying(WrappedMediaPlayer player) {
        startPositionUpdates();
    }

    public void handleCompletion(WrappedMediaPlayer player) {
        channel.invokeMethod("audio.onComplete", buildArguments(player.getPlayerId(), true));
    }

    private void startPositionUpdates() {
        if (positionUpdates != null) {
            return;
        }
        positionUpdates = new UpdateCallback(mediaPlayers, channel, handler, this);
        handler.post(positionUpdates);
    }

    private void stopPositionUpdates() {
        positionUpdates = null;
        handler.removeCallbacksAndMessages(null);
    }

    private static Map<String, Object> buildArguments(String playerId, Object value) {
        Map<String, Object> result = new HashMap<>();
        result.put("playerId", playerId);
        result.put("value", value);
        return result;
    }

    private static final class UpdateCallback implements Runnable {

        private final WeakReference<Map<String, WrappedMediaPlayer>> mediaPlayers;
        private final WeakReference<MethodChannel> channel;
        private final WeakReference<Handler> handler;
        private final WeakReference<AudioplayersPlugin> audioplayersPlugin;

        private UpdateCallback(final Map<String, WrappedMediaPlayer> mediaPlayers,
                       final MethodChannel channel,
                       final Handler handler,
                       final AudioplayersPlugin audioplayersPlugin) {
            this.mediaPlayers = new WeakReference<>(mediaPlayers);
            this.channel = new WeakReference<>(channel);
            this.handler = new WeakReference<>(handler);
            this.audioplayersPlugin = new WeakReference<>(audioplayersPlugin);
        }

        @Override
        public void run() {
            final Map<String, WrappedMediaPlayer> mediaPlayers = this.mediaPlayers.get();
            final MethodChannel channel = this.channel.get();
            final Handler handler = this.handler.get();
            final AudioplayersPlugin audioplayersPlugin = this.audioplayersPlugin.get();

            if (mediaPlayers == null || channel == null || handler == null || audioplayersPlugin == null) {
                if (audioplayersPlugin != null) {
                    audioplayersPlugin.stopPositionUpdates();
                }
                return;
            }

            boolean nonePlaying = true;
            for (WrappedMediaPlayer player : mediaPlayers.values()) {
                if (!player.isActuallyPlaying()) {
                    continue;
                }
                nonePlaying = false;
                final String key = player.getPlayerId();
                final int duration = player.getDuration();
                final int time = player.getCurrentPosition();
                channel.invokeMethod("audio.onDuration", buildArguments(key, duration));
                channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time));
            }

            if (nonePlaying) {
                audioplayersPlugin.stopPositionUpdates();
            } else {
                handler.postDelayed(this, 200);
            }
        }
    }
}
