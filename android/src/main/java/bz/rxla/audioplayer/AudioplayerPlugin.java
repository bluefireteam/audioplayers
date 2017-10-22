package bz.rxla.audioplayer;

import android.app.Activity;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * AudioplayerPlugin
 */
public class AudioplayerPlugin implements MethodCallHandler {
    private final MethodChannel channel;
    private Activity activity;

    final Handler handler = new Handler();

    Map<String, MediaPlayer> mediaPlayers = new HashMap<>();

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "bz.rxla.flutter/audio");
        channel.setMethodCallHandler(new AudioplayerPlugin(registrar.activity(), channel));
    }

    private AudioplayerPlugin(Activity activity, MethodChannel channel) {
        this.activity = activity;
        this.channel = channel;
        this.channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result response) {
        String playerId = ((HashMap) call.arguments()).get("playerId").toString();
        if (call.method.equals("play")) {
            String url = ((HashMap) call.arguments()).get("url").toString();
            Boolean resPlay = play(playerId, url);
            response.success(1);
        } else if (call.method.equals("pause")) {
            pause(playerId);
            response.success(1);
        } else if (call.method.equals("stop")) {
            stop(playerId);
            response.success(1);
        } else if (call.method.equals("seek")) {
            double position = Double.parseDouble(((HashMap) call.arguments()).get("position").toString());
            seek(playerId, position);
            response.success(1);
        } else {
            response.notImplemented();
        }
    }

    private void seek(String playerId, double position) {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        mediaPlayer.seekTo((int) (position * 1000));
    }

    private void stop(String playerId) {
        handler.removeCallbacks(sendData);
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayers.remove(playerId);
        }
    }

    private void pause(String playerId) {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer != null) {
            mediaPlayer.pause();
        }
        handler.removeCallbacks(sendData);
    }

    private Boolean play(final String playerId, String url) {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer == null) {
            mediaPlayer = new MediaPlayer();
            mediaPlayers.put(playerId, mediaPlayer);
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);

            try {
                mediaPlayer.setDataSource(url);
            } catch (IOException e) {
                e.printStackTrace();
                Log.d("AUDIO", "invalid DataSource");
            }

            try {
                mediaPlayer.prepare();
            } catch (IOException e) {
                Log.d("AUDIO", "media prepare ERROR");
                e.printStackTrace();
            }
        }

        channel.invokeMethod("audio.onDuration", buildArguments(playerId, mediaPlayer.getDuration()));

        mediaPlayer.start();

        mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                stop(playerId);
                channel.invokeMethod("audio.onComplete", buildArguments(playerId, true));
            }
        });

        handler.post(sendData);

        return true;
    }

    private final Runnable sendData = new Runnable() {
        public void run() {
            try {
                for (String playerId : mediaPlayers.keySet()) {
                    MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
                    if (!mediaPlayer.isPlaying()) {
                        handler.removeCallbacks(sendData);
                    }
                    int time = mediaPlayer.getCurrentPosition();
                    channel.invokeMethod("audio.onCurrentPosition", buildArguments(playerId, time));

                    handler.postDelayed(this, 200);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    private static Map<String, Object> buildArguments(String playerId, Object value) {
        Map<String, Object> result = new HashMap<>();
        result.put("playerId", playerId);
        result.put("value", value);
        return result;
    }
}
