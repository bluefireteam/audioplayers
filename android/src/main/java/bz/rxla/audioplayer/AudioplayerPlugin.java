package bz.rxla.audioplayer;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.util.Log;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AudioplayerPlugin
 */
public class AudioplayerPlugin implements MethodCallHandler {
    private final MethodChannel channel;
    private Activity activity;
    private boolean mAudioFocusGranted = false;
    private AudioManager.OnAudioFocusChangeListener mOnAudioFocusChangeListener;
    private BroadcastReceiver mIntentReceiver;
    private boolean mReceiverRegistered = false;
    private static final String TAG = "AUDIO_PLAYER";

    private static final String CMD_NAME = "command";
    private static final String CMD_PAUSE = "pause";
    private static final String CMD_STOP = "pause";
    private static final String CMD_PLAY = "play";

    private static String SERVICE_CMD = "com.sec.android.app.music.musicservicecommand";
    private static String PAUSE_SERVICE_CMD = "com.sec.android.app.music.musicservicecommand.pause";
    private static String PLAY_SERVICE_CMD = "com.sec.android.app.music.musicservicecommand.play";

    private Context mContext;

    final Handler handler = new Handler();

    Map<String, MediaPlayer> mediaPlayers = new HashMap<>();
    Map<String, String> mediaPlayerState = new HashMap<>();


    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "bz.rxla.flutter/audio");
        channel.setMethodCallHandler(new AudioplayerPlugin(registrar.activity(), channel));
    }

    private AudioplayerPlugin(Activity activity, MethodChannel channel) {
        this.mContext = activity;
        this.activity = activity;
        this.channel = channel;
        this.channel.setMethodCallHandler(this);

        mOnAudioFocusChangeListener = new AudioManager.OnAudioFocusChangeListener() {

            @Override
            public void onAudioFocusChange(int focusChange) {
                switch (focusChange) {
                    case AudioManager.AUDIOFOCUS_GAIN:
                        Log.i(TAG, "AUDIOFOCUS_GAIN");
                        break;
                    case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT:
                        Log.i(TAG, "AUDIOFOCUS_GAIN_TRANSIENT");
                        break;
                    case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK:
                        Log.i(TAG, "AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK");
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS:
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        Log.e(TAG, "loss or transient");
                        for (Map.Entry<String, MediaPlayer> entry : mediaPlayers.entrySet()) {
                            pause(entry.getKey());
                        }
                        break;
                     case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                         Log.e(TAG, "AUDIOFOCUS_CAN_DUCK");
                         break;
                    case AudioManager.AUDIOFOCUS_REQUEST_FAILED:
                        Log.e(TAG, "AUDIOFOCUS_REQUEST_FAILED");
                        break;
                    default:
                        //
                }
            }
        };
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result response) {
        String playerId = ((HashMap) call.arguments()).get("playerId").toString();
        if (call.method.equals("play")) {
            String url = ((HashMap) call.arguments()).get("url").toString();
            double volume = (double)((HashMap) call.arguments()).get("volume");
            Boolean resPlay = play(playerId, url, (float)volume);
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
        if (mediaPlayer != null &&  mAudioFocusGranted && mediaPlayerState.get(playerId) == "playing") {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayers.remove(playerId);
            mediaPlayerState.put(playerId, "stopped");
            abandonAudioFocus();
        }
    }

    private void pause(String playerId) {
        MediaPlayer mediaPlayer = mediaPlayers.get(playerId);
        if (mediaPlayer != null && mAudioFocusGranted && mediaPlayerState.get(playerId) == "playing") {
            mediaPlayer.pause();
            channel.invokeMethod("audio.onPaused", buildArguments(playerId, true));
            mediaPlayerState.put(playerId, "paused");
        }
        handler.removeCallbacks(sendData);
    }

    private Boolean play(final String playerId, String url, float volume) {
        if (mediaPlayerState.get(playerId) != "playing") {
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

            // 1. Acquire audio focus
            if (!mAudioFocusGranted && requestAudioFocus()) {
                // 2. Kill off any other play back sources
                forceMusicStop();
                // 3. Register broadcast receiver for player intents
                setupBroadcastReceiver();
            }

            channel.invokeMethod("audio.onDuration", buildArguments(playerId, mediaPlayer.getDuration()));

            mediaPlayer.setVolume(volume, volume);
            mediaPlayer.start();
            mediaPlayerState.put(playerId, "playing");

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
        return false;
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

    private void setupBroadcastReceiver() {
        mIntentReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                String cmd = intent.getStringExtra(CMD_NAME);
                Log.i(TAG, "mIntentReceiver.onReceive " + action + " / " + cmd);

                if (PAUSE_SERVICE_CMD.equals(action)
                        || (SERVICE_CMD.equals(action) && CMD_PAUSE.equals(cmd))) {
                    //play();
                }

                if (PLAY_SERVICE_CMD.equals(action)
                        || (SERVICE_CMD.equals(action) && CMD_PLAY.equals(cmd))) {
                    //pause();
                }
            }
        };

        // Do the right thing when something else tries to play
        if (!mReceiverRegistered) {
            IntentFilter commandFilter = new IntentFilter();
            commandFilter.addAction(SERVICE_CMD);
            commandFilter.addAction(PAUSE_SERVICE_CMD);
            commandFilter.addAction(PLAY_SERVICE_CMD);
            mContext.registerReceiver(mIntentReceiver, commandFilter);
            mReceiverRegistered = true;
        }
    }

    private void forceMusicStop() {
        AudioManager am = (AudioManager) mContext
                .getSystemService(Context.AUDIO_SERVICE);
        if (am.isMusicActive()) {
            Intent intentToStop = new Intent(SERVICE_CMD);
            intentToStop.putExtra(CMD_NAME, CMD_STOP);
            mContext.sendBroadcast(intentToStop);
        }
    }

    private boolean requestAudioFocus() {
        if (!mAudioFocusGranted) {
            AudioManager am = (AudioManager) mContext
                    .getSystemService(Context.AUDIO_SERVICE);
            // Request audio focus for play back
            int result = am.requestAudioFocus(mOnAudioFocusChangeListener,
                    // Use the music stream.
                    AudioManager.STREAM_MUSIC,
                    // Request permanent focus.
                    AudioManager.AUDIOFOCUS_GAIN);

            if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                mAudioFocusGranted = true;
            } else {
                // FAILED
                Log.e(TAG, ">>>>>>>>>>>>> FAILED TO GET AUDIO FOCUS <<<<<<<<<<<<<<<<<<<<<<<<");
            }
        }
        return mAudioFocusGranted;
    }

    private void abandonAudioFocus() {
        AudioManager am = (AudioManager) mContext
                .getSystemService(Context.AUDIO_SERVICE);
        int result = am.abandonAudioFocus(mOnAudioFocusChangeListener);
        if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            mAudioFocusGranted = false;
        } else {
            // FAILED
            Log.e(TAG, ">>>>>>>>>>>>> FAILED TO ABANDON AUDIO FOCUS <<<<<<<<<<<<<<<<<<<<<<<<");
        }
        mOnAudioFocusChangeListener = null;
    }
}
