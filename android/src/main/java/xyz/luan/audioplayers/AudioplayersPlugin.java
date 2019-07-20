package xyz.luan.audioplayers;

import android.media.AudioManager;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.os.Handler;
import android.os.Build;
import android.app.Activity;
import android.content.Context;

import java.lang.ref.WeakReference;
import java.util.HashMap;
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
    private final Map<String, Player> mediaPlayers = new HashMap<>();
    private final Handler handler = new Handler();
    private Runnable positionUpdates;
    private final Activity activity;
    private final Map<String, Boolean> respectAudioFocuses = new HashMap<>();
    private final Map<String, AudioManager> audioManagers = new HashMap<>();
    private AudioAttributes mPlaybackAttributes;
    private AudioFocusRequest mFocusRequest;

    public static void registerWith(final Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "xyz.luan/audioplayers");
        channel.setMethodCallHandler(new AudioplayersPlugin(channel, registrar.activity()));
    }

    private AudioplayersPlugin(final MethodChannel channel, Activity activity) {
        this.channel = channel;
        this.channel.setMethodCallHandler(this);
        this.activity = activity;
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

    @SuppressWarnings( "deprecation" )
    private void handleMethodCall(final MethodCall call, final MethodChannel.Result response) {
        final String playerId = call.argument("playerId");
        final String mode = call.argument("mode");
        final Player player = getPlayer(playerId, mode);
        switch (call.method) {
            case "play": {
                final String url = call.argument("url");
                final double volume = call.argument("volume");
                final Integer position = call.argument("position");
                final boolean respectSilence = call.argument("respectSilence");
                final boolean isLocal = call.argument("isLocal");
                final boolean stayAwake = call.argument("stayAwake");
                final boolean respectAudioFocus = call.argument("respectAudioFocus");
                if(respectAudioFocus){
                    AudioManager manager = initAudioManger();
                    audioManagers.put(player.getPlayerId(),manager); 
                }
                player.setUrl(url, isLocal);
                player.configAttributes(respectSilence, stayAwake, activity.getApplicationContext(), respectAudioFocus);
                player.setVolume(volume);
                if (position != null && !mode.equals("PlayerMode.LOW_LATENCY")) {
                    player.seek(position);
                }
                player.play();
                break;
            }
            case "resume": {
                AudioManager manager = initAudioManger();
                audioManagers.put(player.getPlayerId(),manager);
                player.play();
                break;
            }
            case "pause": {
                if(audioManagers.get(player.getPlayerId()) != null){
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        audioManagers.get(player.getPlayerId()).abandonAudioFocusRequest(mFocusRequest);
                    }else{
                        audioManagers.get(player.getPlayerId()).abandonAudioFocus(audioFocusChangeListener);
                    }
                    audioManagers.remove(player.getPlayerId());
                }
                player.pause();
                break;
            }
            case "stop": {
                if(audioManagers.get(player.getPlayerId()) != null){
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        audioManagers.get(player.getPlayerId()).abandonAudioFocusRequest(mFocusRequest);
                    }else{
                        audioManagers.get(player.getPlayerId()).abandonAudioFocus(audioFocusChangeListener);
                    }
                    audioManagers.remove(player.getPlayerId());
                }  
                player.stop();
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
                player.setUrl(url, isLocal);
                break;
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
        startPositionUpdates();
    }

    public void handleDuration(Player player) {
        channel.invokeMethod("audio.onDuration", buildArguments(player.getPlayerId(), player.getDuration()));
    }

    public void handleCompletion(Player player) {
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

    @SuppressWarnings( "deprecation" )
    private AudioManager initAudioManger(){
        AudioManager manager = (AudioManager)activity.getApplicationContext().getSystemService(Context.AUDIO_SERVICE);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            mPlaybackAttributes = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build();
                        
            mFocusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(mPlaybackAttributes)
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener(audioFocusChangeListener)
                .build();

            manager.requestAudioFocus(mFocusRequest);
        }else{
            manager.requestAudioFocus(audioFocusChangeListener,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN); 
        }
        return manager;
    }
    @SuppressWarnings( "deprecation" )
    private AudioManager.OnAudioFocusChangeListener audioFocusChangeListener = new AudioManager.OnAudioFocusChangeListener() {
        public void onAudioFocusChange(int focusChange) {
            switch (focusChange) {
                case AudioManager.AUDIOFOCUS_GAIN:
                    for (Player player : mediaPlayers.values()) {
                        if(player.isRespectingAudioFocus()){
                            if(!player.isActuallyPlaying()){
                                if(respectAudioFocuses.get(player.getPlayerId())){
                                    player.play();
                                    channel.invokeMethod("audio.onFocusChange", buildArguments(player.getPlayerId(), true));
                                    respectAudioFocuses.replace(player.getPlayerId(),false);
                                }
                            } 
                        }
                    }
                    break;
                case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                    for (Player player : mediaPlayers.values()) {
                        if(player.isRespectingAudioFocus()){
                            if (player.isActuallyPlaying()) {
                                respectAudioFocuses.replace(player.getPlayerId(),true);
                                player.pause();
                                channel.invokeMethod("audio.onFocusChange", buildArguments(player.getPlayerId(), false));
                            }
                        }                                        }
                    break;
                case AudioManager.AUDIOFOCUS_LOSS:
                    for (Player player : mediaPlayers.values()) {
                        if(player.isRespectingAudioFocus()){
                            if (player.isActuallyPlaying()) {
                                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                                    audioManagers.get(player.getPlayerId()).abandonAudioFocusRequest(mFocusRequest);
                                }else{
                                    audioManagers.get(player.getPlayerId()).abandonAudioFocus(audioFocusChangeListener);
                                }
                                audioManagers.remove(player.getPlayerId());
                                player.pause();
                                channel.invokeMethod("audio.onFocusChange", buildArguments(player.getPlayerId(), false));
                            }
                        }
                    }
                    break;
            }
        }
    };
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
            final Map<String, Player> mediaPlayers = this.mediaPlayers.get();
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
            for (Player player : mediaPlayers.values()) {
                if (!player.isActuallyPlaying()) {
                    continue;
                }
                try {
                    nonePlaying = false;
                    final String key = player.getPlayerId();
                    final int duration = player.getDuration();
                    final int time = player.getCurrentPosition();
                    channel.invokeMethod("audio.onDuration", buildArguments(key, duration));
                    channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time));
                } catch(UnsupportedOperationException e) {

                }
            }

            if (nonePlaying) {
                audioplayersPlugin.stopPositionUpdates();
            } else {
                handler.postDelayed(this, 200);
            }
        }
    }
}
