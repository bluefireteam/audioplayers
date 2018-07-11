package xyz.luan.audioplayers;

import android.media.MediaPlayer;
import android.media.AudioAttributes;
import android.os.Handler;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class AudioplayersPlugin implements MethodCallHandler, MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener {

    private final MethodChannel channel;
    private final Map<String, MediaPlayer> mediaPlayers = new HashMap<>();
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
        final String playerId = call.argument("playerId");
        switch (call.method) {
            case "play":
                final String url = call.argument("url");
                final double volume = call.argument("volume");
                try {
                    play(playerId, url, (float) volume);
                    response.success(1);
                } catch (IOException e) {
                    e.printStackTrace();
                    response.error("IOException", e.getMessage(), e);
                }
                break;
            case "pause":
                pause(playerId);
                response.success(1);
                break;
            case "stop":
                stop(playerId);
                response.success(1);
                break;
            case "seek":
                double position = call.argument("position");
                seek(playerId, position);
                response.success(1);
                break;
            default:
                response.notImplemented();
                break;
        }
    }

    @Override
    public void onPrepared(final MediaPlayer mediaPlayer) {
        mediaPlayer.start();
        sendPositionUpdates();
    }

    @Override
    public void onCompletion(final MediaPlayer mediaPlayer) {
        mediaPlayer.stop();
        mediaPlayer.reset();
        mediaPlayer.release();
        String key = removePlayer(mediaPlayer);
        channel.invokeMethod("audio.onComplete", buildArguments(key, true));
    }

    private synchronized void play(final String playerId, final String url, final float volume) throws IOException {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer == null) {
            mediaPlayer = new MediaPlayer();
            mediaPlayers.put(playerId, mediaPlayer);
            mediaPlayer.setOnPreparedListener(this);
            mediaPlayer.setOnCompletionListener(this);
            mediaPlayer.setAudioAttributes(new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
            );
        } else {
            mediaPlayer.stop();
            mediaPlayer.reset();
        }

        mediaPlayer.setVolume(volume, volume);
        mediaPlayer.setDataSource(url);
        mediaPlayer.prepareAsync();
    }

    private synchronized void pause(final String playerId) {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer != null) {
            mediaPlayer.pause();
        }
    }

    private synchronized void seek(final String playerId, final double position) {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer != null) {
            mediaPlayer.seekTo((int) (position * 1000));
        }
    }

    private synchronized void stop(final String playerId) {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.reset();
            mediaPlayer.release();
            removePlayer(mediaPlayer);
        }
    }

    private String removePlayer(final MediaPlayer mediaPlayer) {
        final Iterator<Map.Entry<String, MediaPlayer>> iterator = mediaPlayers.entrySet().iterator();
        while (iterator.hasNext()) {
            final Map.Entry<String, MediaPlayer> next = iterator.next();
            if (next.getValue() == mediaPlayer) {
                iterator.remove();
                return next.getKey();
            }
        }
        return null;
    }

    private void sendPositionUpdates() {
        if (positionUpdates != null) {
            return;
        }
        positionUpdates = new UpdateCallback(mediaPlayers, channel, handler, this);
        handler.post(positionUpdates);
    }

    void stopPositionUpdates() {
        positionUpdates = null;
        handler.removeCallbacksAndMessages(null);
    }

    static Map<String, Object> buildArguments(String playerId, Object value) {
        Map<String, Object> result = new HashMap<>();
        result.put("playerId", playerId);
        result.put("value", value);
        return result;
    }

    private static final class UpdateCallback implements Runnable {

        private final WeakReference<Map<String, MediaPlayer>> mediaPlayers;
        private final WeakReference<MethodChannel> channel;
        private final WeakReference<Handler> handler;
        private final WeakReference<AudioplayersPlugin> audioplayersPlugin;

        UpdateCallback(final Map<String, MediaPlayer> mediaPlayers,
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
            final Map<String, MediaPlayer> mediaPlayers = this.mediaPlayers.get();
            final MethodChannel channel = this.channel.get();
            final Handler handler = this.handler.get();
            final AudioplayersPlugin audioplayersPlugin = this.audioplayersPlugin.get();

            if (mediaPlayers == null || channel == null || handler == null || audioplayersPlugin == null) {
                return;
            }

            if (mediaPlayers.isEmpty()) {
                audioplayersPlugin.stopPositionUpdates();
                return;
            }

            for (final Map.Entry<String, MediaPlayer> next : mediaPlayers.entrySet()) {
                final MediaPlayer mediaPlayer = next.getValue();
                if (!mediaPlayer.isPlaying()) {
                    continue;
                }
                final String key = next.getKey();
                final int duration = mediaPlayer.getDuration();
                final int time = mediaPlayer.getCurrentPosition();
                channel.invokeMethod("audio.onDuration", buildArguments(key, duration));
                channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time));
            }
            handler.postDelayed(this, 200);
        }
    }
}
