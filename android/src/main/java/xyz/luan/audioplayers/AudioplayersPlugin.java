package xyz.luan.audioplayers;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioManager;
import android.os.Build;
import android.os.Handler;
import android.support.v4.media.session.PlaybackStateCompat;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class AudioplayersPlugin implements MethodCallHandler, FlutterPlugin {

    private static final Logger LOGGER = Logger.getLogger(AudioplayersPlugin.class.getCanonicalName());

    private MethodChannel channel;
    private final Map<String, Player> mediaPlayers = new HashMap<>();
    private final Handler handler = new Handler();
    private Runnable positionUpdates;
    private Context context;
    private boolean seekFinish;
    private String notificationChannelId = "InsomniacNotificationChannelId";
    ;
    public static final int KEYCODE_BYPASS_PLAY = KeyEvent.KEYCODE_MUTE;
    public static final int KEYCODE_BYPASS_PAUSE = KeyEvent.KEYCODE_MEDIA_RECORD;
    public static final String INSOMNIAC_PLAY = "insomniac.play";
    public static final String INSOMNIAC_PAUSE = "insomniac.pause";
    public static final String INSOMNIAC_STOP = "insomniac.stop";
    public static final String INSOMNIAC_EXTRA_INSTANCE_ID = "insomniac.instance.id";
    public static final String PHONE_STATE_ACTION = "android.intent.action.PHONE_STATE";
    private int instanceIdCounter = 0;
    private Map<String, NotificationCompat.Action> playbackActions;
    private IntentFilter intentFilter;
    private boolean isPlaying = false;
    private Player currentPlayer;
    private String TAG = "AudioplayersPlugin";
    private String notificationTitle = "insomniac";

    public static void registerWith(final Registrar registrar) {
        Log.d("AudioplayersPlugin", "registerWith");
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "xyz.luan/audioplayers");
        channel.setMethodCallHandler(new AudioplayersPlugin(channel, registrar.activeContext()));
    }

    public AudioplayersPlugin() {
    }

    private AudioplayersPlugin(final MethodChannel channel, Context context) {
        Log.d("AudioplayersPlugin", "private AudioplayersPlugin");
        this.channel = channel;
        this.channel.setMethodCallHandler(this);
        this.context = context;
        this.seekFinish = false;
        instanceIdCounter++;
        initInFilter();
    }

    private void initInFilter() {
        if(intentFilter==null){
            intentFilter = new IntentFilter();
            for (String action : playbackActions.keySet()) {
                intentFilter.addAction(action);
            }
            intentFilter.addAction(Intent.ACTION_HEADSET_PLUG);
            intentFilter.addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY);
            context.registerReceiver(notificationReceiver, intentFilter);
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        if(channel==null){
            final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), "xyz.luan/audioplayers");
            this.channel = channel;
            channel.setMethodCallHandler(this);
        }
        this.context = binding.getApplicationContext();
        this.seekFinish = false;
        instanceIdCounter++;
        playbackActions = createPlaybackActions(context, instanceIdCounter);
        initInFilter();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d("interFilter", "onDetachedFromEngine");
        if(currentPlayer!=null){
            currentPlayer.release();
            currentPlayer=null;
        }
        cancelNotification();
        context.unregisterReceiver(notificationReceiver);
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
        final String mode = call.argument("mode");
        final Player player = getPlayer(playerId, mode);
        currentPlayer = player;
        switch (call.method) {
            case "play": {
                final String url = call.argument("url");
                final double volume = call.argument("volume");
                final Integer position = call.argument("position");
                final boolean respectSilence = call.argument("respectSilence");
                final boolean isLocal = call.argument("isLocal");
                final boolean stayAwake = call.argument("stayAwake");
                final boolean duckAudio = call.argument("duckAudio");
                player.configAttributes(respectSilence, stayAwake, duckAudio, context.getApplicationContext());
                player.setVolume(volume);
                player.setUrl(url, isLocal, context.getApplicationContext());
                if (position != null && !mode.equals("PlayerMode.LOW_LATENCY")) {
                    player.seek(position);
                }
                player.play(context.getApplicationContext());
                updateNotification();
                break;
            }
            case "playBytes": {
                // API version 23 is required for MediaDataSource
                if (android.os.Build.VERSION.SDK_INT < 23) {
                    throw new UnsupportedOperationException("API version 23 is required");
                }

                final byte[] bytes = call.argument("bytes");
                final double volume = call.argument("volume");
                final Integer position = call.argument("position");
                final boolean respectSilence = call.argument("respectSilence");
                final boolean stayAwake = call.argument("stayAwake");
                final boolean duckAudio = call.argument("duckAudio");
                player.configAttributes(respectSilence, stayAwake, duckAudio, context.getApplicationContext());
                player.setVolume(volume);
                player.setDataSource(new ByteDataSource(bytes), context.getApplicationContext());
                if (position != null && !mode.equals("PlayerMode.LOW_LATENCY")) {
                    player.seek(position);
                }
                player.play(context.getApplicationContext());
                break;
            }
            case "resume": {
                Log.d(TAG,"resume");
                player.play(context.getApplicationContext());
                updateNotification();
                break;
            }
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
                final Integer position = call.argument("position");
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
                final boolean isLocal = call.argument("isLocal");
                player.setUrl(url, isLocal, context.getApplicationContext());
                break;
            }
            case "setPlaybackRate": {
                final double rate = call.argument("playbackRate");
                response.success(player.setRate(rate));
                return;
            }
            case "getDuration": {
                response.success(player.getDuration());
                return;
            }
            case "getCurrentPosition": {
                response.success(player.getCurrentPosition());
                return;
            }
            case "setReleaseMode": {
                final String releaseModeName = call.argument("releaseMode");
                final ReleaseMode releaseMode = ReleaseMode.valueOf(releaseModeName.substring("ReleaseMode.".length()));
                player.setReleaseMode(releaseMode);
                break;
            }
            case "earpieceOrSpeakersToggle": {
                final String playingRoute = call.argument("playingRoute");
                player.setPlayingRoute(playingRoute, context.getApplicationContext());
                break;
            }
            case "setNotification":{
                notificationTitle = call.argument("title");
                Log.d(TAG,"setNotification  TITLE=="+notificationTitle);
                updateNotification();
                break;
            }
            default: {
                response.notImplemented();
                return;
            }
        }
        response.success(1);
    }

    private Player getPlayer(String playerId, String mode) {
        if (!mediaPlayers.containsKey(playerId)) {
            Player player =
                    mode.equalsIgnoreCase("PlayerMode.MEDIA_PLAYER") ?
                            new WrappedMediaPlayer(this, playerId) :
                            new WrappedSoundPool(this, playerId);
            mediaPlayers.put(playerId, player);
        }
        return mediaPlayers.get(playerId);
    }

    public void handleIsPlaying(Player player) {
        Log.d(TAG,"handleIsPlaying");
        updateNotification();
        startPositionUpdates();
    }

    public void handleDuration(Player player) {
        channel.invokeMethod("audio.onDuration", buildArguments(player.getPlayerId(), player.getDuration()));
    }

    public void handleCompletion(Player player) {
        updateNotification();
        channel.invokeMethod("audio.onComplete", buildArguments(player.getPlayerId(), true));
    }

    public void handleError(Player player, String message) {
        updateNotification();
        channel.invokeMethod("audio.onError", buildArguments(player.getPlayerId(), message));
    }

    public void handlePause(Player player) {
        updateNotification();
        handleNotificationClick();
    }

    public void handleSeekComplete(Player player) {
        this.seekFinish = true;
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
//        actions.put(
//                INSOMNIAC_STOP,
//                new NotificationCompat.Action(
//                        R.drawable.exo_notification_stop,
//                        context.getString(R.string.exo_controls_stop_description),
//                        createBroadcastIntent(INSOMNIAC_STOP, context, instanceId)));
        return actions;
    }

    private static PendingIntent createBroadcastIntent(
            String action, Context context, int instanceId) {
        Intent intent = new Intent(action).setPackage(context.getPackageName());
        intent.putExtra(INSOMNIAC_EXTRA_INSTANCE_ID, instanceId);
        return PendingIntent.getBroadcast(
                context, instanceId, intent, PendingIntent.FLAG_CANCEL_CURRENT);
    }

    private void updateNotification() {
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        Log.d("tag", "updateNotification");
        notificationManager.notify(33, initNotification());
    }

    private void cancelNotification() {
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        Log.d("tag", "cancelNotification");
        notificationManager.cancel(33);
    }

    private NotificationCompat.Builder getNotificationBuilder() {
        NotificationCompat.Builder notificationBuilder = null;
        if (notificationBuilder == null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                createChannel();
            Resources res = context.getResources();
            Bitmap bmp = BitmapFactory.decodeResource(res, R.mipmap.ic_launcher);
            notificationBuilder = new NotificationCompat.Builder(context, notificationChannelId)
                    .setSmallIcon(R.mipmap.ic_launcher_bar)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setShowWhen(false)
                    .setLargeIcon(bmp)
//                    .setDeleteIntent(buildMediaButtonPendingIntent(PlaybackStateCompat.ACTION_STOP))
            ;
        }
        return notificationBuilder;
    }

    PendingIntent buildMediaButtonPendingIntent(long action) {
        ComponentName component = new ComponentName(context.getPackageName(), "androidx.media.session.MediaButtonReceiver");
        return buildMediaButtonPendingIntent(component, action);
    }

    PendingIntent buildMediaButtonPendingIntent(ComponentName component, long action) {
        int keyCode = toKeyCode(action);
        if (keyCode == KeyEvent.KEYCODE_UNKNOWN)
            return null;
        Intent intent = new Intent(Intent.ACTION_MEDIA_BUTTON);
        intent.setComponent(component);
        intent.putExtra(Intent.EXTRA_KEY_EVENT, new KeyEvent(KeyEvent.ACTION_DOWN, keyCode));
        return PendingIntent.getBroadcast(context, keyCode, intent, 0);
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
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        NotificationChannel channel = notificationManager.getNotificationChannel(notificationChannelId);
        if (channel == null) {
            channel = new NotificationChannel(notificationChannelId, "insomniacNotificationId", NotificationManager.IMPORTANCE_LOW);
            notificationManager.createNotificationChannel(channel);
        }
    }


    private static final class UpdateCallback implements Runnable {

        private final WeakReference<Map<String, Player>> mediaPlayers;
        private final WeakReference<MethodChannel> channel;
        private final WeakReference<Handler> handler;
        private final WeakReference<AudioplayersPlugin> audioplayersPlugin;

        private UpdateCallback(final Map<String, Player> mediaPlayers,
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
//            final Map<String, Player> mediaPlayers = this.mediaPlayers.get();
//            final MethodChannel channel = this.channel.get();
//            final Handler handler = this.handler.get();
//            final AudioplayersPlugin audioplayersPlugin = this.audioplayersPlugin.get();
//            if (mediaPlayers == null || channel == null || handler == null || audioplayersPlugin == null) {
//                if (audioplayersPlugin != null) {
//                    audioplayersPlugin.stopPositionUpdates();
//                }
//                return;
//            }
//            boolean nonePlaying = true;
//            for (Player player : mediaPlayers.values()) {
//                if (!player.isActuallyPlaying()) {
//                    continue;
//                }
//                try {
//                    nonePlaying = false;
//                    final String key = player.getPlayerId();
//                    final int duration = player.getDuration();
//                    final int time = player.getCurrentPosition();
//                    channel.invokeMethod("audio.onDuration", buildArguments(key, duration));
//                    channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time));
//                    if (audioplayersPlugin.seekFinish) {
//                        channel.invokeMethod("audio.onSeekComplete", buildArguments(player.getPlayerId(), true));
//                        audioplayersPlugin.seekFinish = false;
//                    }
//                } catch (UnsupportedOperationException e) {
//
//                }
//            }
//
//            if (nonePlaying) {
//                audioplayersPlugin.stopPositionUpdates();
//            } else {
//                handler.postDelayed(this, 200);
//            }
        }
    }

    BroadcastReceiver notificationReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Log.d("onReceive", "onReceive action=" + action);
            if (action.equals(INSOMNIAC_PLAY)) {
                if(currentPlayer!=null)
                    currentPlayer.play(context.getApplicationContext());
                handleNotificationClick();
            } else if (action.equals(INSOMNIAC_PAUSE)) {
                if(currentPlayer!=null)currentPlayer.pause();
                updateNotification();
                handleNotificationClick();
            }else if(action.equals(AudioManager.ACTION_HEADSET_PLUG)||action.equals(AudioManager.ACTION_AUDIO_BECOMING_NOISY)){
                int state=intent.getIntExtra("state",2);
                if(state==0){//拔出耳机
                    if(currentPlayer!=null&&currentPlayer.isActuallyPlaying()){
                        currentPlayer.pause();
                        updateNotification();
                        handleNotificationClick();
                    }
                }
            }
        }
    };

    private void handleNotificationClick(){
        if(currentPlayer!=null){
            String playId=currentPlayer.getPlayerId();
            channel.invokeMethod("audio.onNotificationPlayerStateChanged", buildArguments(playId, currentPlayer.isActuallyPlaying()));
        }
    }

}

