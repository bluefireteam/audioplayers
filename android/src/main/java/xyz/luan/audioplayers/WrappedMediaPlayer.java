package xyz.luan.audioplayers;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.RatingCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.LruCache;
import android.view.KeyEvent;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import androidx.media.MediaBrowserServiceCompat;
import androidx.media.app.NotificationCompat.MediaStyle;
import androidx.media.session.MediaButtonReceiver;

import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.AsyncTask;
import android.os.Build;
import android.os.PowerManager;
import android.content.Context;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import java.io.IOException;
import java.io.InputStream;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.ViewDestroyListener;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.plugin.common.BinaryMessenger;

import android.app.Service;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;

import android.content.res.AssetManager;

import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterRunArguments;

public class WrappedMediaPlayer extends Player implements MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener, MediaPlayer.OnSeekCompleteListener, MediaPlayer.OnErrorListener {

    private String playerId;

    private String url;
    private double volume = 1.0;
    private float rate = 1.0f;
    private boolean respectSilence;
    private boolean stayAwake;
    private ReleaseMode releaseMode = ReleaseMode.RELEASE;

    private String title;
    private String albumTitle;
    private String artist;
    private String imageUrl;
    private int maxDuration;
    private int elapsedTimeInMillis = 0;

    private boolean showNotification = false;

    private boolean released = true;
    private boolean prepared = false;
    private boolean playing = false;

    private int shouldSeekTo = -1;

    private MediaPlayer player;
    private AudioplayersPlugin ref;

	private static final int NOTIFICATION_ID = 1124;
    public static final int MAX_COMPACT_ACTIONS = 3;
	private int[] compactActionIndices;
    

    WrappedMediaPlayer(AudioplayersPlugin ref, String playerId) {
        this.ref = ref;
        this.playerId = playerId;
    }

    /**
     * Setter methods
     */

    @Override
    void setUrl(String url, boolean isLocal) {
        if (!objectEquals(this.url, url)) {
            this.url = url;
            if (this.released) {
                this.player = createPlayer();
                this.released = false;
            } else if (this.prepared) {
                this.player.reset();
                this.prepared = false;
            }

            this.setSource(url);
            this.player.setVolume((float) volume, (float) volume);
            this.player.setLooping(this.releaseMode == ReleaseMode.LOOP);
            this.player.prepareAsync();
        }
    }

    // @Override
    // void startHeadlessService() {
        
    // }

    @Override
    void setNotification(String title, String albumTitle, String artist, String imageUrl, int maxDuration, int elapsedTime) {
        this.title = title;
        this.albumTitle = albumTitle;
        this.artist = artist;
        this.imageUrl = imageUrl;

        this.maxDuration = maxDuration * 1000;
        this.elapsedTimeInMillis = elapsedTime * 1000;

        this.showNotification = true;
        Log.d("myTag", "setNotification start android!");
        Log.d("myTag", "setNotification start android : " + maxDuration);

        // long updateTimeSinceEpoch = System.currentTimeMillis();
        // List<Object> compactActionIndexList = (List<Object>)args.get(6);

        // On the flutter side, we represent the update time relative to the epoch.
        // On the native side, we must represent the update time relative to the boot time.
        // long updateTimeSinceBoot = updateTimeSinceEpoch;
        // int playbackState = 1; //(Integer)args.get(2);
        // long position = 0; // getLong(args.get(3));
        // float speed = (float)((double)((Double) 1.0));

        // MediaMetadataCompat mediaMetadata = createMediaMetadata("random", albumTitle, title, artist, "", 0, null, title, artist, "", null, null);
        // AudioService.instance.setMetadata(mediaMetadata);
                
        // updateNotification();

        new setNotificationAsyncTask().execute(imageUrl);
    }

    private class setNotificationAsyncTask extends AsyncTask<String, Void, Bitmap> {
        // ImageView bmImage;
        // public DownloadImageTask(ImageView bmImage) {
        //     this.bmImage = bmImage;
        // }
    
        protected Bitmap doInBackground(String... urls) {
            String urldisplay = urls[0];
            Log.d("myTag", "setNotification urldisplay : " + urldisplay);
            Bitmap bmp = null;
            try {
                if(urldisplay.startsWith("http")) {
                    Log.d("myTag", "setNotification urldisplay 0 : " + urldisplay);
                    InputStream in = new java.net.URL(urldisplay).openStream();
                    bmp = BitmapFactory.decodeStream(in);
                } else {
                    Log.d("myTag", "setNotification urldisplay 1 : " + urldisplay);
                    bmp = AudioService.loadArtBitmapFromFile(urldisplay);
                }
            } catch (Exception e) {
                Log.e("Error setNotification ", e.getMessage());
                e.printStackTrace();
            }
            return bmp;
        }
        protected void onPostExecute(Bitmap result) {
            // bmImage.setImageBitmap(result);
            MediaMetadataCompat mediaMetadata = createMediaMetadata("random", albumTitle, title, artist, "", maxDuration, result, title, artist, "", null, null);
            AudioService.instance.setMetadata(mediaMetadata);
                    
            updateNotification();
        }
    }

    private void updateNotification() {
        long position = Long.valueOf(elapsedTimeInMillis); // getLong(args.get(3));

        int actionBits = 0;

        int playbackState = 1;

        List<NotificationCompat.Action> actions = new ArrayList<NotificationCompat.Action>();

        List<Map<String, Object>> rawControls = new ArrayList<Map<String, Object>>();
        Map<String, Object> mapRewindParams = new HashMap<>();
        mapRewindParams.put("androidIcon", "drawable/ic_action_replay");
        mapRewindParams.put("label", "rewind");
        mapRewindParams.put("action", PlaybackStateCompat.ACTION_REWIND);
        rawControls.add(mapRewindParams);

        Map<String, Object> map1 = new HashMap<>();
        if(this.playing) {
            map1.put("androidIcon", "drawable/ic_action_pause");
            map1.put("label", "Pause");
            map1.put("action", PlaybackStateCompat.ACTION_PAUSE);
            playbackState = 3;

            long actionLongValue = (long) PlaybackStateCompat.ACTION_SEEK_TO;
            int actionCode = (int) actionLongValue;
            actionBits |= actionCode;
        } else {
            map1.put("androidIcon", "drawable/ic_action_play_arrow");
            map1.put("label", "Play");
            map1.put("action", PlaybackStateCompat.ACTION_PLAY);
            playbackState = 2;
        }
        rawControls.add(map1);

        Map<String, Object> mapForwardParams = new HashMap<>();
        mapForwardParams.put("androidIcon", "drawable/ic_action_skip");
        mapForwardParams.put("label", "fastForward");
        mapForwardParams.put("action", PlaybackStateCompat.ACTION_FAST_FORWARD);
        rawControls.add(mapForwardParams);

        // Map<String, Object> map2 = new HashMap<>();
        // map1.put("androidIcon", "drawable/ic_action_pause");
        // map1.put("label", "Pause");
        // map1.put("action", PlaybackStateCompat.ACTION_PAUSE);
        // rawControls.add(map2);
         // (List<Map<?, ?>>)args.get(0);
        for (Map<String, Object> rawControl : rawControls) {
            String resource = (String)rawControl.get("androidIcon");
            long actionLongValue = (long) rawControl.get("action");
            int actionCode = (int) actionLongValue;
            Log.d("myTag", "setNotification keycode 0 : " + actionCode);
            actionBits |= actionCode;
            actions.add(AudioService.instance.action(resource, (String)rawControl.get("label"), actionCode));
        }

        // AudioService.instance.setState(actions, actionBits, compactActionIndices, playbackState, position, speed, updateTimeSinceBoot);
        AudioService.instance.setState(actions, actionBits, compactActionIndices, playbackState, position, this.rate);
        // startForegroundService(NOTIFICATION_ID, buildNotification());
    }

    private static MediaMetadataCompat createMediaMetadata(String mediaId, String album, String title, String artist, String genre, int duration, Bitmap artUri, String displayTitle, String displaySubtitle, String displayDescription, RatingCompat rating, Map<?, ?> extras) {
        Log.d("myTag", "setNotification image!");
        Log.d("myTag", "setNotification image - " + artUri);
		return AudioService.createMediaMetadata(
                mediaId,
				album,
				title,
				artist,
				genre,
				getLong(duration),
				artUri,
				displayTitle,
				displaySubtitle,
				displayDescription,
				null, //raw2rating((Map<String, Object>)rawMediaItem.get("rating")),
				null //(Map<?, ?>)rawMediaItem.get("extras")
		);
	}

    @Override
    void setVolume(double volume) {
        if (this.volume != volume) {
            this.volume = volume;
            if (!this.released) {
                this.player.setVolume((float) volume, (float) volume);
            }
        }
    }

    @Override
    int setRate(double rate) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            throw new UnsupportedOperationException("The method 'setRate' is available only on Android SDK version " + Build.VERSION_CODES.M + " or higher!");
        }
        if (this.player != null) {
            this.rate = (float) rate;
            this.player.setPlaybackParams(this.player.getPlaybackParams().setSpeed(this.rate));
            if(this.showNotification) {
                this.elapsedTimeInMillis = getCurrentPosition();
                updateNotification();
            }
            return 1;
        }
        return 0;
    }

    @Override
    void configAttributes(boolean respectSilence, boolean stayAwake, Context context) {
        if (this.respectSilence != respectSilence) {
            this.respectSilence = respectSilence;
            if (!this.released) {
                setAttributes(player);
            }
        }
        if (this.stayAwake != stayAwake) {
            this.stayAwake = stayAwake;
            if (!this.released && this.stayAwake) {
                this.player.setWakeMode(context, PowerManager.PARTIAL_WAKE_LOCK);
            }
        }
    }

    @Override
    void setReleaseMode(ReleaseMode releaseMode) {
        if (this.releaseMode != releaseMode) {
            this.releaseMode = releaseMode;
            if (!this.released) {
                this.player.setLooping(releaseMode == ReleaseMode.LOOP);
            }
        }
    }

    /**
     * Getter methods
     */

    @Override
    int getDuration() {
        return this.player.getDuration();
    }

    @Override
    int getCurrentPosition() {
        return this.player.getCurrentPosition();
    }

    @Override
    String getPlayerId() {
        return this.playerId;
    }

    @Override
    boolean isActuallyPlaying() {
        return this.playing && this.prepared;
    }

    /**
     * Playback handling methods
     */

    @Override
    void play() {
        if (!this.playing) {
            this.playing = true;
            if (this.released) {
                this.released = false;
                this.player = createPlayer();
                this.setSource(url);
                this.player.prepareAsync();
            } else if (this.prepared) {
                this.player.start();
                this.ref.handleIsPlaying(this);
                this.ref.handleNotificationPlayerStateChanged(this, true);
                if(this.showNotification) {
                    this.elapsedTimeInMillis = getCurrentPosition();
                    updateNotification();
                }
            }
        }
    }

    @Override
    void stop() {
        if (this.released) {
            return;
        }

        if (releaseMode != ReleaseMode.RELEASE) {
            if (this.playing) {
                this.playing = false;
                this.player.pause();
                this.player.seekTo(0);
            }
        } else {
            this.release();
        }
    }

    @Override
    void release() {
        if (this.released) {
            return;
        }

        if (this.playing) {
            this.player.stop();
        }
        this.player.reset();
        this.player.release();
        this.player = null;

        this.prepared = false;
        this.released = true;
        this.playing = false;
    }

    @Override
    void pause() {
        if (this.playing) {
            this.playing = false;
            this.player.pause();
            ref.handleNotificationPlayerStateChanged(this, false);
            if(this.showNotification) {
                this.elapsedTimeInMillis = getCurrentPosition();
                updateNotification();
            }
        }
    }

    // seek operations cannot be called until after
    // the player is ready.
    @Override
    void seek(int position) {
        if (this.prepared)
            this.player.seekTo(position);
            if(this.showNotification) {
                this.elapsedTimeInMillis = position;
                updateNotification();
            }
        else
            this.shouldSeekTo = position;
    }

    /**
     * MediaPlayer callbacks
     */

    @Override
    public void onPrepared(final MediaPlayer mediaPlayer) {
        Log.d("myTag", "setNotification onPrepared!");
        this.prepared = true;
        ref.handleDuration(this);
        if (this.playing) {
            this.player.start();
            ref.handleIsPlaying(this);
            ref.handleNotificationPlayerStateChanged(this, true);
        }
        if (this.shouldSeekTo >= 0) {
            this.player.seekTo(this.shouldSeekTo);
            this.shouldSeekTo = -1;
        }
    }

    @Override
    public void onCompletion(final MediaPlayer mediaPlayer) {
        if (releaseMode != ReleaseMode.LOOP) {
            this.stop();
        }
        ref.handleCompletion(this);
    }

    @Override
    public void onSeekComplete(final MediaPlayer mediaPlayer) {
        ref.handleSeekComplete(this);
    }

    @Override
    public boolean onError(final MediaPlayer mediaPlayer, int what, int extra) {
        Log.d("myTag", "setNotification onError mediaplayer!");
        //Invoked when there has been an error during an asynchronous operation
        switch (what) {
            case MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK:
                Log.e("MediaPlayer Error setNotification", "MEDIA ERROR NOT VALID FOR PROGRESSIVE PLAYBACK " + extra);
                break;
            case MediaPlayer.MEDIA_ERROR_SERVER_DIED:
                Log.e("MediaPlayer Error setNotification", "MEDIA ERROR SERVER DIED " + extra);
                break;
            case MediaPlayer.MEDIA_ERROR_UNKNOWN:
                Log.e("MediaPlayer Error setNotification", "MEDIA ERROR UNKNOWN " + extra);
                break;
        }
        return true;
    }
    
    public static Long getLong(Object o) {
		return (o == null || o instanceof Long) ? (Long)o : new Long(((Integer)o).intValue());
	}

    private MediaPlayer createPlayer() {
        MediaPlayer player = new MediaPlayer();
        player.setOnPreparedListener(this);
        player.setOnCompletionListener(this);
        player.setOnSeekCompleteListener(this);
        player.setOnErrorListener(this);
        setAttributes(player);
        player.setVolume((float) volume, (float) volume);
        player.setLooping(this.releaseMode == ReleaseMode.LOOP);
        return player;
    }

    private void setSource(String url) {
        try {
            this.player.setDataSource(url);
        } catch (IOException ex) {
            throw new RuntimeException("Unable to access resource", ex);
        }
    }

    @SuppressWarnings("deprecation")
    private void setAttributes(MediaPlayer player) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            player.setAudioAttributes(new AudioAttributes.Builder()
                    .setUsage(respectSilence ? AudioAttributes.USAGE_NOTIFICATION_RINGTONE : AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            );
        } else {
            // This method is deprecated but must be used on older devices
            player.setAudioStreamType(respectSilence ? AudioManager.STREAM_RING : AudioManager.STREAM_MUSIC);
        }
    }

}
