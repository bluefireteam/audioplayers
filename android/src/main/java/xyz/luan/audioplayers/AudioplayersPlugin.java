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
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.media.AudioManager;
import android.nfc.Tag;
import android.os.Build;
import android.os.Handler;
import android.provider.MediaStore;
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


public class AudioplayersPlugin implements MethodCallHandler, FlutterPlugin,AudioPlayerStatusListener {

    private static final Logger LOGGER = Logger.getLogger(AudioplayersPlugin.class.getCanonicalName());

    private MethodChannel channel;
    private final Map<String, Player> mediaPlayers = new HashMap<>();
    private final Handler handler = new Handler();
    private Runnable positionUpdates;
    private Context context;
    public static final String INSOMNIAC_PLAY = "insomniac.play";
    public static final String INSOMNIAC_PAUSE = "insomniac.pause";
    public static final String INSOMNIAC_STOP = "insomniac.stop";
    public static final String TAG = "AudioplayersPlugin";
    private IntentFilter intentFilter;
    private Player currentPlayer;

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
        initInFilter();
    }

    private void initInFilter() {
        if(intentFilter==null){
            intentFilter = new IntentFilter();
            intentFilter.addAction(INSOMNIAC_PLAY);
            intentFilter.addAction(INSOMNIAC_PAUSE);
            intentFilter.addAction(INSOMNIAC_STOP);
            intentFilter.addAction(Intent.ACTION_HEADSET_PLUG);
            intentFilter.addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY);
            context.registerReceiver(notificationReceiver, intentFilter);
            //start service
            startAudioService();
        }
    }

    private void startAudioService(){
        context.startService(new Intent(context,AudioService.class));
        AudioService.setAudioPlayerStatusListener(this);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        if(channel==null){
            final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), "xyz.luan/audioplayers");
            this.channel = channel;
            channel.setMethodCallHandler(this);
        }
        this.context = binding.getApplicationContext();
        initInFilter();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d("interFilter", "onDetachedFromEngine");
        if(currentPlayer!=null){
            currentPlayer.release();
            currentPlayer=null;
        }
        context.unregisterReceiver(notificationReceiver);
        context.stopService(new Intent(context,AudioService.class));
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
        Intent intent=new Intent(context,AudioService.class);
        final String playerId = call.argument("playerId");
        final String mode = call.argument("mode");
        intent.putExtra("playerId",playerId);
        intent.putExtra("mode",mode);
        switch (call.method) {
            case "play": {
                final String url = call.argument("url");
                final double volume = call.argument("volume");
                final Integer position = call.argument("position");
                final boolean respectSilence = call.argument("respectSilence");
                final boolean isLocal = call.argument("isLocal");
                final boolean stayAwake = call.argument("stayAwake");
                final boolean duckAudio = call.argument("duckAudio");
                intent.putExtra("url",url);
                intent.putExtra("position",position);
                intent.putExtra("volume",volume);
                intent.putExtra("respectSilence",respectSilence);
                intent.putExtra("isLocal",isLocal);
                intent.putExtra("stayAwake",stayAwake);
                intent.putExtra("duckAudio",duckAudio);
                intent.setAction("play");
                context.startService(intent);
                Log.d(TAG,"startService");
                break;
            }
            case "playBytes": {
                break;
            }
            case "resume": {
                intent.setAction("resume");
                context.startService(intent);
                break;
            }
            case "pause": {
                intent.setAction("pause");
                context.startService(intent);
                break;
            }
            case "stop": {
                intent.setAction("stop");
                context.startService(intent);
                break;
            }
            case "release": {
                intent.setAction("release");
                context.startService(intent);
                break;
            }
            case "seek": {
                final Integer position = call.argument("position");
                intent.setAction("seek");
                intent.putExtra("position",position);
                context.startService(intent);
                break;
            }
            case "setVolume": {
                final double volume = call.argument("volume");
                intent.setAction("setVolume");
                intent.putExtra("volume",volume);
                context.startService(intent);
                break;
            }
            case "setUrl": {
                final String url = call.argument("url");
                final boolean isLocal = call.argument("isLocal");
                intent.setAction("setUrl");
                intent.putExtra("url",url);
                intent.putExtra("isLocal",isLocal);
                context.startService(intent);
                break;
            }
            case "setPlaybackRate": {
                final double rate = call.argument("playbackRate");
                intent.setAction("setPlaybackRate");
                intent.putExtra("playbackRate",rate);
                context.startService(intent);
                response.success(1);
                return;
            }
            case "getDuration": {
                int duration=0;
                if(currentPlayer!=null){
                    currentPlayer.getDuration();
                }
                response.success(duration);
                return;
            }
            case "getCurrentPosition": {
                int currentPostition=0;
                if(currentPlayer!=null){
                    currentPlayer.getCurrentPosition();
                }
                response.success(currentPostition);
                return;
            }
            case "setReleaseMode": {
                final String releaseModeName = call.argument("releaseMode");
                intent.setAction("setReleaseMode");
                intent.putExtra("releaseMode",releaseModeName);
                context.startService(intent);
                break;
            }
            case "earpieceOrSpeakersToggle": {
                final String playingRoute = call.argument("playingRoute");
                intent.setAction("earpieceOrSpeakersToggle");
                intent.putExtra("playingRoute",playingRoute);
                context.startService(intent);
                break;
            }
            case "setNotification":{
                String title = call.argument("title");
                String imageUrl = call.argument("imageUrl");
                intent.setAction("setNotification");
                intent.putExtra("title",title);
                intent.putExtra("imageUrl",imageUrl);
                context.startService(intent);
                break;
            }
            default: {
                response.notImplemented();
                return;
            }
        }
        response.success(1);
    }

    @Override
    public void handleIsPlaying(Player player) {
        Log.d(TAG,"handleIsPlaying");
        currentPlayer=player;
    }

    @Override
    public void handleDuration(Player player) {
        currentPlayer=player;
        channel.invokeMethod("audio.onDuration", buildArguments(player.getPlayerId(), player.getDuration()));
    }

    @Override
    public void handleCompletion(Player player) {
        currentPlayer=player;
        channel.invokeMethod("audio.onComplete", buildArguments(player.getPlayerId(), true));
    }

    @Override
    public void handleError(Player player, String message) {
        currentPlayer=player;
        channel.invokeMethod("audio.onError", buildArguments(player.getPlayerId(), message));
    }

    @Override
    public void handlePause(Player player) {
        currentPlayer=player;
        handleNotificationClick();
    }

    @Override
    public void handleSeekComplete(Player player) {
        currentPlayer=player;
    }


    private static Map<String, Object> buildArguments(String playerId, Object value) {
        Map<String, Object> result = new HashMap<>();
        result.put("playerId", playerId);
        result.put("value", value);
        return result;
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

    private void sendPauseToService(){
        if(currentPlayer!=null){
            Intent intent=new Intent(context,AudioService.class);
            intent.setAction("pause");
            intent.putExtra("playerId",currentPlayer.getPlayerId());
            intent.putExtra("mode","PlayerMode.MEDIA_PLAYER");
            context.startService(intent);
        }
    }

    private void sendResumeToService(){
        if(currentPlayer!=null){
            Intent intent=new Intent(context,AudioService.class);
            intent.setAction("resume");
            intent.putExtra("playerId",currentPlayer.getPlayerId());
            intent.putExtra("mode","PlayerMode.MEDIA_PLAYER");
            context.startService(intent);
        }
    }

    BroadcastReceiver notificationReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(INSOMNIAC_PLAY)) {
                sendPauseToService();
                handleNotificationClick();
            } else if (action.equals(INSOMNIAC_PAUSE)) {
                sendResumeToService();
                handleNotificationClick();
            }else if(action.equals(AudioManager.ACTION_HEADSET_PLUG)||action.equals(AudioManager.ACTION_AUDIO_BECOMING_NOISY)){
                int state=intent.getIntExtra("state",2);
                if(state==0){//拔出耳机
                    if(currentPlayer!=null&&currentPlayer.isActuallyPlaying()){
                        sendPauseToService();
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

