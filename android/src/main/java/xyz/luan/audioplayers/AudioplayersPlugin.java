package xyz.luan.audioplayers;

import android.util.Log;

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

import android.os.RemoteException;


import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.RatingCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.LruCache;
import android.view.KeyEvent;

import android.os.Build;
import android.content.Context;
import android.os.Handler;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class AudioplayersPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware  {

    private static final Logger LOGGER = Logger.getLogger(AudioplayersPlugin.class.getCanonicalName());

    private Activity activity;
    private MethodChannel channel;
    private final Map<String, Player> mediaPlayers = new HashMap<>();
    private final Handler handler = new Handler();
    private Runnable positionUpdates;
    private Context context;
    private boolean seekFinish;

    public static void registerWith(final Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "xyz.luan/audioplayers");
        channel.setMethodCallHandler(new AudioplayersPlugin(channel, registrar.activeContext(), registrar.activity()));
    }

    private AudioplayersPlugin(final MethodChannel channel, Context context, Activity activity) {
        this.channel = channel;
        this.channel.setMethodCallHandler(this);
        this.context = context;
        this.activity = activity;
        this.seekFinish = false;	
    }	
    
    public AudioplayersPlugin() {}	
    
    @Override	
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {	
        final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), "xyz.luan/audioplayers");	
        this.channel = channel;	
        this.context = binding.getApplicationContext();	
        this.seekFinish = false;	
        channel.setMethodCallHandler(this);	
    }	
    
    @Override	
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

    // /
	// ActivityAware callbacks
	//

	@Override
	public void onAttachedToActivity(ActivityPluginBinding binding) {
		// clientHandler = new ClientHandler(flutterPluginBinding.getFlutterEngine().getDartExecutor());
		this.activity = binding.getActivity();
	}

	@Override
	public void onDetachedFromActivityForConfigChanges() {
	}

	@Override
	public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
		this.activity = binding.getActivity();
	}

	@Override
	public void onDetachedFromActivity() {
		// clientHandler = null;
    }

    private static void sendConnectResult(boolean result) {
		// connectResult.success(result);
		// connectResult = null;
	}
    
    /// mediaplayback
    private boolean playPending;
    public MediaBrowserCompat mediaBrowser;
    public MediaControllerCompat mediaController;
    public MediaControllerCompat.Callback controllerCallback = new MediaControllerCompat.Callback() {
        @Override
        public void onMetadataChanged(MediaMetadataCompat metadata) {
            invokeMethod("onMediaChanged", mediaMetadata2raw(metadata));
        }

        @Override
        public void onPlaybackStateChanged(PlaybackStateCompat state) {
            // On the native side, we represent the update time relative to the boot time.
            // On the flutter side, we represent the update time relative to the epoch.
            long updateTimeSinceBoot = state.getLastPositionUpdateTime();
            long updateTimeSinceEpoch = updateTimeSinceBoot; // bootTime + updateTimeSinceBoot;
            invokeMethod("onPlaybackStateChanged", state.getState(), state.getActions(), state.getPosition(), state.getPlaybackSpeed(), updateTimeSinceEpoch);
        }

        @Override
        public void onQueueChanged(List<MediaSessionCompat.QueueItem> queue) {
            // invokeMethod("onQueueChanged", queue2raw(queue));
        }
    };

    private final MediaBrowserCompat.SubscriptionCallback subscriptionCallback = new MediaBrowserCompat.SubscriptionCallback() {
        @Override
        public void onChildrenLoaded(String parentId, List<MediaBrowserCompat.MediaItem> children) {
            // invokeMethod("onChildrenLoaded", mediaItems2raw(children));
        }
    };

    private final MediaBrowserCompat.ConnectionCallback connectionCallback = new MediaBrowserCompat.ConnectionCallback() {
        @Override
        public void onConnected() {
            try {
                //Activity activity = registrar.activity();
                MediaSessionCompat.Token token = mediaBrowser.getSessionToken();
                mediaController = new MediaControllerCompat(activity, token);
                MediaControllerCompat.setMediaController(activity, mediaController);
                mediaController.registerCallback(controllerCallback);
                PlaybackStateCompat state = mediaController.getPlaybackState();
                controllerCallback.onPlaybackStateChanged(state);
                MediaMetadataCompat metadata = mediaController.getMetadata();
                controllerCallback.onQueueChanged(mediaController.getQueue());
                controllerCallback.onMetadataChanged(metadata);

                synchronized (this) {
                    if (playPending) {
                        mediaController.getTransportControls().play();
                        playPending = false;
                    }
                }
                sendConnectResult(true);
            } catch (RemoteException e) {
                sendConnectResult(false);
                throw new RuntimeException(e);
            }
        }

        @Override
        public void onConnectionSuspended() {
            // TODO: Handle this
        }

        @Override
        public void onConnectionFailed() {
            sendConnectResult(false);
        }
    };

    public void invokeMethod(String method, Object... args) {
        ArrayList<Object> list = new ArrayList<Object>(Arrays.asList(args));
        channel.invokeMethod(method, list);
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
        switch (call.method) {
            case "startHeadlessService": {
                // player.startHeadlessService();
                Log.d("myTag", "setNotification startHeadlessService android!");
                // Context context = this.activity;
                // startResult = result; // The result will be sent after the background task actually starts.
                // if (AudioService.isRunning()) {
                //     sendStartResult(false);
                //     break;
                // }
                // Map<?, ?> arguments = (Map<?, ?>)call.arguments;
                // final long callbackHandle = getLong(arguments.get("callbackHandle"));
                boolean androidNotificationClickStartsActivity = false; // (Boolean)arguments.get("androidNotificationClickStartsActivity");
                boolean androidNotificationOngoing = true; //(Boolean)arguments.get("androidNotificationOngoing");
                boolean resumeOnClick = true; //(Boolean)arguments.get("resumeOnClick");
                String androidNotificationChannelName = "test"; // (String)arguments.get("androidNotificationChannelName");
                String androidNotificationChannelDescription = "test2"; // (String)arguments.get("androidNotificationChannelDescription");
                Integer notificationColor = null; // arguments.get("notificationColor") == null ? null : getInt(arguments.get("notificationColor"));
                String androidNotificationIcon = "mipmap/ic_launcher"; // (String)arguments.get("androidNotificationIcon");
                Log.d("myTag", "setNotification startHeadlessService android 11!");
                final boolean enableQueue = false; //(Boolean)arguments.get("enableQueue");
                final boolean androidStopForegroundOnPause = false; //(Boolean)arguments.get("androidStopForegroundOnPause");
                final boolean androidStopOnRemoveTask = false; // (Boolean)arguments.get("androidStopOnRemoveTask");
                final Map<String, Double> artDownscaleSizeMap = null; // (Map)arguments.get("androidArtDownscaleSize");
                final Size artDownscaleSize = artDownscaleSizeMap == null ? null
                    : new Size((int)Math.round(artDownscaleSizeMap.get("width")), (int)Math.round(artDownscaleSizeMap.get("height")));
                Log.d("myTag", "setNotification startHeadlessService android 12!");

                // final String appBundlePath = FlutterMain.findAppBundlePath(context.getApplicationContext());
                Log.d("myTag", "setNotification startHeadlessService android 2!");
                // backgroundHandler = null; // new BackgroundHandler(callbackHandle, appBundlePath, enableQueue);
                AudioService.init(activity, resumeOnClick, androidNotificationChannelName, androidNotificationChannelDescription, notificationColor, androidNotificationIcon, androidNotificationClickStartsActivity, androidNotificationOngoing, androidStopForegroundOnPause, androidStopOnRemoveTask, artDownscaleSize, null);

                synchronized (connectionCallback) {
                    // mediaController.getTransportControls().play();
                    if (mediaController != null)
						mediaController.getTransportControls().play();
					else
						playPending = true;
                }

                if (mediaBrowser == null) {
					// connectResult = result;
					mediaBrowser = new MediaBrowserCompat(context,
							new ComponentName(context, AudioService.class),
							connectionCallback,
							null);
					mediaBrowser.connect();
				} else {
					// result.success(true);
				}
                
                break;
            }
            case "play": {
                final String url = call.argument("url");
                final double volume = call.argument("volume");
                final Integer position = call.argument("position");
                final boolean respectSilence = call.argument("respectSilence");
                final boolean isLocal = call.argument("isLocal");
                final boolean stayAwake = call.argument("stayAwake");
                player.configAttributes(respectSilence, stayAwake, context.getApplicationContext());
                player.setVolume(volume);
                player.setUrl(url, isLocal);
                if (position != null && !mode.equals("PlayerMode.LOW_LATENCY")) {
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
            case "setPlaybackRate": {
                final double rate = call.argument("playbackRate");
                response.success(player.setRate(rate));
                return;
            }
            case "setNotification": {
                final String title = call.argument("title");
                final String albumTitle = call.argument("albumTitle");
                final String artist = call.argument("artist");
                final String imageUrl = call.argument("imageUrl");

                player.setNotification(title, albumTitle, artist, imageUrl);
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
                    if (audioplayersPlugin.seekFinish) {
                        channel.invokeMethod("audio.onSeekComplete", buildArguments(player.getPlayerId(), true));
                        audioplayersPlugin.seekFinish = false;
                    }
                } catch (UnsupportedOperationException e) {

                }
            }

            if (nonePlaying) {
                audioplayersPlugin.stopPositionUpdates();
            } else {
                handler.postDelayed(this, 200);
            }
        }
    }

    private static Map<?, ?> mediaMetadata2raw(MediaMetadataCompat mediaMetadata) {
		if (mediaMetadata == null) return null;
		MediaDescriptionCompat description = mediaMetadata.getDescription();
		Map<String, Object> raw = new HashMap<String, Object>();
		raw.put("id", description.getMediaId());
		raw.put("album", mediaMetadata.getText(MediaMetadataCompat.METADATA_KEY_ALBUM).toString());
		raw.put("title", mediaMetadata.getText(MediaMetadataCompat.METADATA_KEY_TITLE).toString());
		if (description.getIconUri() != null)
			raw.put("artUri", description.getIconUri().toString());
		if (mediaMetadata.containsKey(MediaMetadataCompat.METADATA_KEY_ARTIST))
			raw.put("artist", mediaMetadata.getText(MediaMetadataCompat.METADATA_KEY_ARTIST).toString());
		if (mediaMetadata.containsKey(MediaMetadataCompat.METADATA_KEY_GENRE))
			raw.put("genre", mediaMetadata.getText(MediaMetadataCompat.METADATA_KEY_GENRE).toString());
		if (mediaMetadata.containsKey(MediaMetadataCompat.METADATA_KEY_DURATION))
			raw.put("duration", mediaMetadata.getLong(MediaMetadataCompat.METADATA_KEY_DURATION));
		if (mediaMetadata.containsKey(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE))
			raw.put("displayTitle", mediaMetadata.getText(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE).toString());
		if (mediaMetadata.containsKey(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE))
			raw.put("displaySubtitle", mediaMetadata.getText(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE).toString());
		if (mediaMetadata.containsKey(MediaMetadataCompat.METADATA_KEY_DISPLAY_DESCRIPTION))
			raw.put("displayDescription", mediaMetadata.getText(MediaMetadataCompat.METADATA_KEY_DISPLAY_DESCRIPTION).toString());
		if (mediaMetadata.containsKey(MediaMetadataCompat.METADATA_KEY_RATING)) {
			// raw.put("rating", rating2raw(mediaMetadata.getRating(MediaMetadataCompat.METADATA_KEY_RATING)));
		}
		Map<String, Object> extras = new HashMap<>();
		for (String key : mediaMetadata.keySet()) {
			if (key.startsWith("extra_long_")) {
				String rawKey = key.substring("extra_long_".length());
				extras.put(rawKey, mediaMetadata.getLong(key));
			} else if (key.startsWith("extra_string_")) {
				String rawKey = key.substring("extra_string_".length());
				extras.put(rawKey, mediaMetadata.getString(key));
			}
		}
		if (extras.size() > 0) {
			raw.put("extras", extras);
		}
		return raw;
	}
}

