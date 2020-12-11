package xyz.luan.audioplayers;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.IBinder;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.Log;
import android.view.KeyEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AudioService extends Service {

    private final Map<String, Player> mediaPlayers = new HashMap<>();
    private String notificationChannelId = "InsomniacNotificationChannelId";
    public static final int KEYCODE_BYPASS_PLAY = KeyEvent.KEYCODE_MUTE;
    public static final int KEYCODE_BYPASS_PAUSE = KeyEvent.KEYCODE_MEDIA_RECORD;
    public static final String INSOMNIAC_PLAY = "insomniac.play";
    public static final String INSOMNIAC_PAUSE = "insomniac.pause";
    public static final String INSOMNIAC_STOP = "insomniac.stop";
    public static final String INSOMNIAC_EXTRA_INSTANCE_ID = "insomniac.instance.id";
    public static final String PHONE_STATE_ACTION = "android.intent.action.PHONE_STATE";
    public static AudioPlayerStatusListener audioPlayerStatusListener = null;
    private int instanceIdCounter = 0;
    private Map<String, NotificationCompat.Action> playbackActions;
    private boolean isPlaying = false;
    private Player currentPlayer;
    private String TAG = "AudioplayersPlugin";
    private String notificationTitle = "insomniac";
    private String notificationImageUrl ="";
    private Bitmap notificationImage=null;

    @Override
    public void onCreate() {
        super.onCreate();
        instanceIdCounter++;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public static void setAudioPlayerStatusListener(AudioPlayerStatusListener listener){
        audioPlayerStatusListener=listener;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        handleIntent(intent);
        return super.onStartCommand(intent, flags, startId);
    }

    private void handleIntent(Intent intent) {
        if (intent == null || intent.getAction() == null) {
            return;
        }
        final String playerId = intent.getStringExtra("playerId");
        final String mode = intent.getStringExtra("mode");
        final Player player = getPlayer(playerId, mode);
        currentPlayer = player;
        switch (intent.getAction()){
            case "play":
                final String url = intent.getStringExtra("url");
                final double volume = intent.getDoubleExtra("volume",1.0);
                final Integer position = intent.getIntExtra("position",0);
                final boolean respectSilence = intent.getBooleanExtra("respectSilence",false);
                final boolean isLocal = intent.getBooleanExtra("isLocal",false);
                final boolean stayAwake = intent.getBooleanExtra("stayAwake",false);
                final boolean duckAudio = intent.getBooleanExtra("duckAudio",false);
                player.configAttributes(respectSilence, stayAwake, duckAudio, getApplicationContext());
                player.setVolume(volume);
                player.setUrl(url, isLocal, getApplicationContext());
                if (position != null && !mode.equals("PlayerMode.LOW_LATENCY")) {
                    player.seek(position);
                }
                player.play(getApplicationContext());
                updateNotification();
            break;
            case "resume":
                player.play(getApplicationContext());
                updateNotification();
                break;
            case "pause": {
                player.pause();
                updateNotification();
                break;
            }
            case "stop": {
                player.stop();
                cancelNotification();
                break;
            }
            case "release": {
                player.release();
                break;
            }
            case "seek": {
                final Integer positionValue = intent.getIntExtra("position",0);
                player.seek(positionValue);
                break;
            }
            case "setVolume": {
                final double volumeValue = intent.getDoubleExtra("volume",1.0);
                player.setVolume(volumeValue);
                break;
            }
            case "setUrl": {
                final String urlValue = intent.getStringExtra("url");
                final boolean isLocalValue = intent.getBooleanExtra("isLocal",false);
                player.setUrl(urlValue, isLocalValue,getApplicationContext());
                break;
            }
            case "setPlaybackRate": {
                final double rate = intent.getDoubleExtra("playbackRate",1.0);
                player.setRate(rate);
                return;
            }
            case "setReleaseMode": {
                final String releaseModeName = intent.getStringExtra("releaseMode");
                final ReleaseMode releaseMode = ReleaseMode.valueOf(releaseModeName.substring("ReleaseMode.".length()));
                player.setReleaseMode(releaseMode);
                break;
            }
            case "earpieceOrSpeakersToggle": {
                final String playingRoute = intent.getStringExtra("playingRoute");
                player.setPlayingRoute(playingRoute, getApplicationContext());
                break;
            }
            case "setNotification":{
                notificationTitle = intent.getStringExtra("title");
                notificationImageUrl = intent.getStringExtra("imageUrl");
                Log.d(TAG,"setNotification  TITLE=="+notificationTitle+" notificationImageUrl="+notificationImageUrl);
                loadImage();
                break;
            }
        }
    }

    private Player getPlayer(String playerId, String mode) {
        if (!mediaPlayers.containsKey(playerId)) {
            Player player =
                    mode.equalsIgnoreCase("PlayerMode.MEDIA_PLAYER") ?
                            new WrappedMediaPlayer(audioPlayerStatusListener, playerId) :
                            new WrappedSoundPool(audioPlayerStatusListener, playerId);
            mediaPlayers.put(playerId, player);
        }
        return mediaPlayers.get(playerId);
    }


    private static Map<String, Object> buildArguments(String playerId, Object value) {
        Map<String, Object> result = new HashMap<>();
        result.put("playerId", playerId);
        result.put("value", value);
        return result;
    }


    private Notification initNotification() {
        NotificationCompat.Builder builder = getNotificationBuilder()
                .setContentTitle(notificationTitle)
                .setContentText("");
        List<String> actionNames = getActions();
        for (int i = 0; i < actionNames.size(); i++) {
            String actionName = actionNames.get(i);
            NotificationCompat.Action action = playbackActions.get(actionName);
            if (action != null) {
                builder.addAction(action);
            }
        }
        builder.setOngoing(true);
        builder.setPriority(NotificationCompat.PRIORITY_LOW);
        builder.setStyle(new androidx.media.app.NotificationCompat.MediaStyle()
//                .setMediaSession(mediaSession.getSessionToken())
                        .setShowActionsInCompactView(new int[]{0})
                        .setShowCancelButton(true)
                        .setCancelButtonIntent(buildMediaButtonPendingIntent(PlaybackStateCompat.ACTION_STOP))
        );
        Notification notification = builder.build();
        return notification;
    }

    protected List<String> getActions() {
        boolean isPlayingAd = currentPlayer==null?false:currentPlayer.isActuallyPlaying();
        List<String> stringActions = new ArrayList<>();
        if (isPlayingAd) {
            stringActions.add(INSOMNIAC_PAUSE);
        } else {
            stringActions.add(INSOMNIAC_PLAY);
        }
        stringActions.add(INSOMNIAC_STOP);
        return stringActions;
    }

    private Map<String, NotificationCompat.Action> createPlaybackActions(
            Context context, int instanceId) {
        Map<String, NotificationCompat.Action> actions = new HashMap<>();
        actions.put(
                INSOMNIAC_PLAY,
                new NotificationCompat.Action(
                        R.drawable.exo_notification_play,
                        context.getString(R.string.exo_controls_play_description),
                        createBroadcastIntent(INSOMNIAC_PLAY, context, instanceId)));
        actions.put(
                INSOMNIAC_PAUSE,
                new NotificationCompat.Action(
                        R.drawable.exo_notification_pause,
                        context.getString(R.string.exo_controls_pause_description),
                        createBroadcastIntent(INSOMNIAC_PAUSE, context, instanceId)));
        return actions;
    }

    private static PendingIntent createBroadcastIntent(
            String action, Context context, int instanceId) {
        Intent intent = new Intent(action).setPackage(context.getPackageName());
        intent.putExtra(INSOMNIAC_EXTRA_INSTANCE_ID, instanceId);
        return PendingIntent.getBroadcast(
                context, instanceId, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    void loadImage(){
        notificationImage=null;
        if(notificationImageUrl!=null&&notificationImageUrl.startsWith("http")){
            Glide.with(this).asBitmap().load(notificationImageUrl).override(50, 50).into(new SimpleTarget<Bitmap>() {
                @Override
                public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                    notificationImage=resource;
                    updateNotification();
                }
            });
        }
        updateNotification();
    }

    private void updateNotification() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        Notification notification=initNotification();
        startForeground(33,notification);
        notificationManager.notify(33, notification);
    }

    private void cancelNotification() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(33);
    }

    private NotificationCompat.Builder getNotificationBuilder() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) createChannel();
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, notificationChannelId);
        Bitmap bmp=null;
        if(notificationImage==null){
            Resources res = getResources();
            bmp = BitmapFactory.decodeResource(res, R.mipmap.ic_launcher);
        }else{
            bmp=notificationImage;
        }
        notificationBuilder.setSmallIcon(R.mipmap.ic_launcher_bar)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setShowWhen(false)
                .setLargeIcon(bmp);
        return notificationBuilder;
    }

    PendingIntent buildMediaButtonPendingIntent(long action) {
        ComponentName component = new ComponentName(getPackageName(), "androidx.media.session.MediaButtonReceiver");
        return buildMediaButtonPendingIntent(component, action);
    }

    PendingIntent buildMediaButtonPendingIntent(ComponentName component, long action) {
        int keyCode = toKeyCode(action);
        if (keyCode == KeyEvent.KEYCODE_UNKNOWN)
            return null;
        Intent intent = new Intent(Intent.ACTION_MEDIA_BUTTON);
        intent.setComponent(component);
        intent.putExtra(Intent.EXTRA_KEY_EVENT, new KeyEvent(KeyEvent.ACTION_DOWN, keyCode));
        return PendingIntent.getBroadcast(this, keyCode, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    public static int toKeyCode(long action) {
        if (action == PlaybackStateCompat.ACTION_PLAY) {
            return KEYCODE_BYPASS_PLAY;
        } else if (action == PlaybackStateCompat.ACTION_PAUSE) {
            return KEYCODE_BYPASS_PAUSE;
        } else {
            return PlaybackStateCompat.toKeyCode(action);
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private void createChannel() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        NotificationChannel channel = notificationManager.getNotificationChannel(notificationChannelId);
        if (channel == null) {
            channel = new NotificationChannel(notificationChannelId, "insomniacNotificationId", NotificationManager.IMPORTANCE_LOW);
            notificationManager.createNotificationChannel(channel);
        }
    }


}
