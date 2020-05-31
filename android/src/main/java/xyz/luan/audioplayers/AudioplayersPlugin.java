package xyz.luan.audioplayers;

import android.util.Log;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.content.ComponentName;
import android.content.Context;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.SystemClock;

import androidx.media.MediaBrowserServiceCompat;
import androidx.core.app.NotificationCompat;

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
	private static final String CHANNEL_AUDIO_SERVICE_BACKGROUND = "xyz.luan/audioplayers_callback";

    private Activity activity;
    private MethodChannel channel;
    private final Map<String, Player> mediaPlayers = new HashMap<>();
    private final Handler handler = new Handler();
    private Runnable positionUpdates;
    private Context context;
    private boolean seekFinish;

    private static long updateHandleMonitorKey;

	private static PluginRegistrantCallback pluginRegistrantCallback;
	private static BackgroundHandler backgroundHandler;
	private static FlutterEngine backgroundFlutterEngine;
	private static long bootTime;

	private static Player notificationPlayer;
	private static String notificationPlayerId = "";
	private static int forwardSkipIntervalInSeconds = 0;
	private static int backwardSkipIntervalInSeconds = 0;

	static {
		bootTime = System.currentTimeMillis() - SystemClock.elapsedRealtime();
	}

	public static void setPluginRegistrantCallback(PluginRegistrantCallback pluginRegistrantCallback) {
		AudioplayersPlugin.pluginRegistrantCallback = pluginRegistrantCallback;
	}


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
            // invokeMethod("onMediaChanged", mediaMetadata2raw(metadata));
        }

        @Override
        public void onPlaybackStateChanged(PlaybackStateCompat state) {
            // On the native side, we represent the update time relative to the boot time.
            // On the flutter side, we represent the update time relative to the epoch.
            long updateTimeSinceBoot = state.getLastPositionUpdateTime();
            long updateTimeSinceEpoch = bootTime + updateTimeSinceBoot;
            // invokeMethod("onPlaybackStateChanged", state.getState(), state.getActions(), state.getPosition(), state.getPlaybackSpeed(), updateTimeSinceEpoch);
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
		this.notificationPlayer = player;
		this.notificationPlayerId = playerId;
        switch (call.method) {
            case "startHeadlessService": {
                // player.startHeadlessService();
                Log.d("myTag", "setNotification startHeadlessService android!");
                // Context context = this.activity;
                // startResult = result; // The result will be sent after the background task actually starts.
                if (AudioService.isRunning()) {
                    // sendStartResult(false);
                    break;
                }

                Map<?, ?> arguments = (Map<?, ?>)call.arguments;
				List<Object> args = (List<Object>)arguments.get("handleKey");
                final long callbackHandle = getLong(args.get(0));
                // final long callbackHandle = getLong(call.argument("handleKey"));
                Log.d("myTag", "setNotification startHeadlessService android 10!");
                boolean androidNotificationClickStartsActivity = true; // (Boolean)arguments.get("androidNotificationClickStartsActivity");
                boolean androidNotificationOngoing = false; //(Boolean)arguments.get("androidNotificationOngoing");
                boolean resumeOnClick = true; //(Boolean)arguments.get("resumeOnClick");
                String androidNotificationChannelName = "test"; // (String)arguments.get("androidNotificationChannelName");
                String androidNotificationChannelDescription = "test2"; // (String)arguments.get("androidNotificationChannelDescription");
                Integer notificationColor = null; // arguments.get("notificationColor") == null ? null : getInt(arguments.get("notificationColor"));
                String androidNotificationIcon = "mipmap/icon"; // (String)arguments.get("androidNotificationIcon");
                Log.d("myTag", "setNotification startHeadlessService android 11!");
                final boolean enableQueue = false; //(Boolean)arguments.get("enableQueue");
                final boolean androidStopForegroundOnPause = true; //(Boolean)arguments.get("androidStopForegroundOnPause");
                final boolean androidStopOnRemoveTask = false; // (Boolean)arguments.get("androidStopOnRemoveTask");
                final Map<String, Double> artDownscaleSizeMap = null; // (Map)arguments.get("androidArtDownscaleSize");
                final Size artDownscaleSize = artDownscaleSizeMap == null ? null
                    : new Size((int)Math.round(artDownscaleSizeMap.get("width")), (int)Math.round(artDownscaleSizeMap.get("height")));
                Log.d("myTag", "setNotification startHeadlessService android 12!");

                final String appBundlePath = FlutterMain.findAppBundlePath(context.getApplicationContext());
                Log.d("myTag", "setNotification startHeadlessService android 2!");
                backgroundHandler = new BackgroundHandler(callbackHandle, appBundlePath, enableQueue);
                AudioService.init(activity, resumeOnClick, androidNotificationChannelName, androidNotificationChannelDescription, notificationColor, androidNotificationIcon, androidNotificationClickStartsActivity, androidNotificationOngoing, androidStopForegroundOnPause, androidStopOnRemoveTask, artDownscaleSize, backgroundHandler);

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
            case "monitorNotificationStateChanges": {
                Map<?, ?> arguments = (Map<?, ?>)call.arguments;
				List<Object> args = (List<Object>)arguments.get("handleMonitorKey");
                final long callbackHandle = getLong(args.get(0));
                updateHandleMonitorKey = callbackHandle;

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

				final int maxDuration = call.argument("duration");
				
				this.forwardSkipIntervalInSeconds = call.argument("forwardSkipInterval");
				this.backwardSkipIntervalInSeconds = call.argument("backwardSkipInterval");

                player.setNotification(title, albumTitle, artist, imageUrl, maxDuration);
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

    public void handleNotificationPlayerStateChanged(Player player, boolean isPlaying) {
        channel.invokeMethod("audio.onNotificationPlayerStateChanged", buildArguments(player.getPlayerId(), isPlaying));
    }

    public void handleIsPlaying(Player player) {
        startPositionUpdates();
    }

    public void handleDuration(Player player) {
        channel.invokeMethod("audio.onDuration", buildArguments(player.getPlayerId(), player.getDuration()));
    }

    public void handleCompletion(Player player) {
		channel.invokeMethod("audio.onComplete", buildArguments(player.getPlayerId(), true));
		if (backgroundHandler != null) {
			Map<String, Object> arguments = new HashMap<String, Object>();
			arguments.put("value", "completed");
			arguments.put("updateHandleMonitorKey", updateHandleMonitorKey);
			backgroundHandler.backgroundChannel.invokeMethod("audio.onNotificationBackgroundPlayerStateChanged", arguments);
		}
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

    private static class BackgroundHandler implements MethodCallHandler, AudioService.ServiceListener {
		private long callbackHandle;
		private String appBundlePath;
		private boolean enableQueue;
		public MethodChannel backgroundChannel;
		private AudioTrack silenceAudioTrack;
		private static final int SILENCE_SAMPLE_RATE = 44100;
		private byte[] silence;

		public BackgroundHandler(long callbackHandle, String appBundlePath, boolean enableQueue) {
			this.callbackHandle = callbackHandle;
			this.appBundlePath = appBundlePath;
			this.enableQueue = enableQueue;
		}

		public void init(BinaryMessenger messenger) {
			if (backgroundChannel != null) return;
			backgroundChannel = new MethodChannel(messenger, CHANNEL_AUDIO_SERVICE_BACKGROUND);
			backgroundChannel.setMethodCallHandler(this);
		}

		@Override
		public void onAudioFocusGained() {
			invokeMethod("onAudioFocusGained");
		}

		@Override
		public void onAudioFocusLost() {
			invokeMethod("onAudioFocusLost");
		}

		@Override
		public void onAudioFocusLostTransient() {
			invokeMethod("onAudioFocusLostTransient");
		}

		@Override
		public void onAudioFocusLostTransientCanDuck() {
			invokeMethod("onAudioFocusLostTransientCanDuck");
		}

		@Override
		public void onAudioBecomingNoisy() {
			invokeMethod("onAudioBecomingNoisy");
		}

		@Override
		public void onLoadChildren(final String parentMediaId, final MediaBrowserServiceCompat.Result<List<MediaBrowserCompat.MediaItem>> result) {
			ArrayList<Object> list = new ArrayList<Object>();
			list.add(parentMediaId);
			if (backgroundHandler != null) {
				backgroundHandler.backgroundChannel.invokeMethod("onLoadChildren", list, new MethodChannel.Result() {
					@Override
					public void error(String errorCode, String errorMessage, Object errorDetails) {
						result.sendError(new Bundle());
					}

					@Override
					public void notImplemented() {
						result.sendError(new Bundle());
					}

					@Override
					public void success(Object obj) {
						List<Map<?, ?>> rawMediaItems = (List<Map<?, ?>>)obj;
						List<MediaBrowserCompat.MediaItem> mediaItems = new ArrayList<MediaBrowserCompat.MediaItem>();
						for (Map<?, ?> rawMediaItem : rawMediaItems) {
							// MediaMetadataCompat mediaMetadata = createMediaMetadata(rawMediaItem);
							// mediaItems.add(new MediaBrowserCompat.MediaItem(mediaMetadata.getDescription(), (Boolean)rawMediaItem.get("playable") ? MediaBrowserCompat.MediaItem.FLAG_PLAYABLE : MediaBrowserCompat.MediaItem.FLAG_BROWSABLE));
						}
						result.sendResult(mediaItems);
					}
				});
			}
			result.detach();
		}

		@Override
		public void onClick(MediaControl mediaControl) {
			invokeMethod("onClick", mediaControl.ordinal());
		}

		@Override
		public void onPause() {
			// invokeMethod("onPause");
			notificationPlayer.pause();

            Log.d("myTag", "setNotification onPlay pause!");
            Map<String, Object> arguments = new HashMap<String, Object>();
            arguments.put("value", "paused");
            arguments.put("playerId", notificationPlayerId);
            arguments.put("updateHandleMonitorKey", updateHandleMonitorKey);

            backgroundChannel.invokeMethod("audio.onNotificationBackgroundPlayerStateChanged", arguments);
		}

		@Override
		public void onPrepare() {
			invokeMethod("onPrepare");
		}

		@Override
		public void onPrepareFromMediaId(String mediaId) {
			invokeMethod("onPrepareFromMediaId", mediaId);
		}

		@Override
		public void onPlay() {
			if (backgroundFlutterEngine == null) {
				Context context = AudioService.instance;
				backgroundFlutterEngine = new FlutterEngine(context.getApplicationContext());
				FlutterCallbackInformation cb = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);
				if (cb == null || appBundlePath == null) {
					// sendStartResult(false);
					return;
				}
				if (enableQueue)
					AudioService.instance.enableQueue();
				// Register plugins in background isolate if app is using v1 embedding
				if (pluginRegistrantCallback != null) {
					pluginRegistrantCallback.registerWith(new ShimPluginRegistry(backgroundFlutterEngine));
				}

				DartExecutor executor = backgroundFlutterEngine.getDartExecutor();
				init(executor);
				DartCallback dartCallback = new DartCallback(context.getAssets(), appBundlePath, cb);

				executor.executeDartCallback(dartCallback);
                Log.d("myTag", "setNotification onPlay 0!");
            } else {
				Log.d("myTag", "setNotification onPlay 1!");
				notificationPlayer.play();
                // invokeMethod("onPlay");
                Map<String, Object> arguments = new HashMap<String, Object>();
                arguments.put("value", "playing");
                arguments.put("updateHandleMonitorKey", updateHandleMonitorKey);

                backgroundChannel.invokeMethod("audio.onNotificationBackgroundPlayerStateChanged", arguments);
            }
		}

		@Override
		public void onPlayFromMediaId(String mediaId) {
			invokeMethod("onPlayFromMediaId", mediaId);
		}

		@Override
		public void onPlayMediaItem(MediaMetadataCompat metadata) {
			invokeMethod("onPlayMediaItem", mediaMetadata2raw(metadata));
		}

		@Override
		public void onStop() {
			invokeMethod("onStop");
		}

		@Override
		public void onDestroy() {
			clear();
		}

		@Override
		public void onAddQueueItem(MediaMetadataCompat metadata) {
			invokeMethod("onAddQueueItem", mediaMetadata2raw(metadata));
		}

		@Override
		public void onAddQueueItemAt(MediaMetadataCompat metadata, int index) {
			invokeMethod("onAddQueueItemAt", mediaMetadata2raw(metadata), index);
		}

		@Override
		public void onRemoveQueueItem(MediaMetadataCompat metadata) {
			invokeMethod("onRemoveQueueItem", mediaMetadata2raw(metadata));
		}

		@Override
		public void onSkipToQueueItem(long queueItemId) {
			// String mediaId = queueMediaIds.get((int)queueItemId);
			// invokeMethod("onSkipToQueueItem", mediaId);
		}

		@Override
		public void onSkipToNext() {
			invokeMethod("onSkipToNext");
		}

		@Override
		public void onSkipToPrevious() {
			invokeMethod("onSkipToPrevious");
		}

		@Override
		public void onFastForward() {
			// invokeMethod("onFastForward");
			Log.d("myTag", "setNotification onFastForward!");
			final int currentTime = notificationPlayer.getCurrentPosition();
			final int maxDuration = notificationPlayer.getDuration();
			final int newTime = currentTime + (forwardSkipIntervalInSeconds * 1000);
			Log.d("myTag", "setNotification newTime : " + newTime);
			if (newTime > maxDuration) {
				notificationPlayer.seek(maxDuration);
			} else {
				notificationPlayer.seek(newTime);
			}
		}

		@Override
		public void onRewind() {
			// invokeMethod("onRewind");
			final int currentTime = notificationPlayer.getCurrentPosition();
			final int maxDuration = notificationPlayer.getDuration();
			final int newTime = currentTime - (backwardSkipIntervalInSeconds * 1000);
			if (newTime < 0) {
				notificationPlayer.seek(0);
			} else {
				notificationPlayer.seek(newTime);
			}
		}

		@Override
		public void onSeekTo(long pos) {
			// invokeMethod("onSeekTo", pos);
			notificationPlayer.seek(Math.toIntExact(pos));
		}

		@Override
		public void onSetRating(RatingCompat rating) {
			// invokeMethod("onSetRating", rating2raw(rating), null);
		}

		@Override
		public void onSetRating(RatingCompat rating, Bundle extras) {
			// invokeMethod("onSetRating", rating2raw(rating), extras.getSerializable("extrasMap"));
		}

		@Override
		public void onMethodCall(MethodCall call, Result result) {
			Context context = AudioService.instance;
			switch (call.method) {
			case "ready":
				result.success(true);
				// sendStartResult(true);
				// If the client subscribed to browse children before we
				// started, process the pending request.
				// TODO: It should be possible to browse children before
				// starting.
				// if (subscribedParentMediaId != null)
				// 	AudioService.instance.notifyChildrenChanged(subscribedParentMediaId);
				break;
			case "setMediaItem":
				// Map<?, ?> rawMediaItem = (Map<?, ?>)call.arguments;
				// MediaMetadataCompat mediaMetadata = createMediaMetadata(rawMediaItem);
				// AudioService.instance.setMetadata(mediaMetadata);
				// result.success(true);
				break;
			case "setQueue":
				// List<Map<?, ?>> rawQueue = (List<Map<?, ?>>)call.arguments;
				// List<MediaSessionCompat.QueueItem> queue = raw2queue(rawQueue);
				// AudioService.instance.setQueue(queue);
				// result.success(true);
				break;
			case "setState":
				List<Object> args = (List<Object>)call.arguments;
				List<Map<?, ?>> rawControls = (List<Map<?, ?>>)args.get(0);
				List<Integer> rawSystemActions = (List<Integer>)args.get(1);
				int playbackState = (Integer)args.get(2);
				long position = getLong(args.get(3));
				float speed = (float)((double)((Double)args.get(4)));
				long updateTimeSinceEpoch = args.get(5) == null ? System.currentTimeMillis() : getLong(args.get(5));
				List<Object> compactActionIndexList = (List<Object>)args.get(6);

				// On the flutter side, we represent the update time relative to the epoch.
				// On the native side, we must represent the update time relative to the boot time.
				long updateTimeSinceBoot = updateTimeSinceEpoch - bootTime;

				List<NotificationCompat.Action> actions = new ArrayList<NotificationCompat.Action>();
				int actionBits = 0;
				for (Map<?, ?> rawControl : rawControls) {
					String resource = (String)rawControl.get("androidIcon");
					int actionCode = 1 << ((Integer)rawControl.get("action"));
					actionBits |= actionCode;
					actions.add(AudioService.instance.action(resource, (String)rawControl.get("label"), actionCode));
				}
				for (Integer rawSystemAction : rawSystemActions) {
					int actionCode = 1 << rawSystemAction;
					actionBits |= actionCode;
				}
				int[] compactActionIndices = null;
				if (compactActionIndexList != null) {
					compactActionIndices = new int[Math.min(AudioService.MAX_COMPACT_ACTIONS, compactActionIndexList.size())];
					for (int i = 0; i < compactActionIndices.length; i++)
						compactActionIndices[i] = (Integer)compactActionIndexList.get(i);
				}
				AudioService.instance.setState(actions, actionBits, compactActionIndices, playbackState, position, speed);
				result.success(true);
				break;
			case "stopped":
				clear();
				result.success(true);
				break;
			case "notifyChildrenChanged":
				String parentMediaId = (String)call.arguments;
				AudioService.instance.notifyChildrenChanged(parentMediaId);
				result.success(true);
				break;
			case "androidForceEnableMediaButtons":
				// Just play a short amount of silence. This convinces Android
				// that we are playing "real" audio so that it will route
				// media buttons to us.
				// See: https://issuetracker.google.com/issues/65344811
				if (silenceAudioTrack == null) {
					silence = new byte[2048];
					silenceAudioTrack = new AudioTrack(
							AudioManager.STREAM_MUSIC,
							SILENCE_SAMPLE_RATE,
							AudioFormat.CHANNEL_CONFIGURATION_MONO,
							AudioFormat.ENCODING_PCM_8BIT,
							silence.length,
							AudioTrack.MODE_STATIC);
					silenceAudioTrack.write(silence, 0, silence.length);
				}
				silenceAudioTrack.reloadStaticData();
				silenceAudioTrack.play();
				result.success(true);
				break;
			}
		}

		public void invokeMethod(String method, Object... args) {
			ArrayList<Object> list = new ArrayList<Object>(Arrays.asList(args));
			backgroundChannel.invokeMethod(method, list);
		}

		public void invokeMethod(final Result result, String method, Object... args) {
			ArrayList<Object> list = new ArrayList<Object>(Arrays.asList(args));
			backgroundChannel.invokeMethod(method, list, result);
		}

		private void clear() {
			AudioService.instance.stop();
			if (silenceAudioTrack != null)
				silenceAudioTrack.release();
			// if (handler != null) handler.invokeMethod("audio.onComplete");
			backgroundFlutterEngine.destroy();
			backgroundFlutterEngine = null;
			backgroundHandler = null;
		}
    }

	// private static MediaMetadataCompat createMediaMetadata(Map<?, ?> rawMediaItem) {
	// 	return AudioService.createMediaMetadata(
	// 			(String)rawMediaItem.get("id"),
	// 			(String)rawMediaItem.get("album"),
	// 			(String)rawMediaItem.get("title"),
	// 			(String)rawMediaItem.get("artist"),
	// 			(String)rawMediaItem.get("genre"),
	// 			getLong(rawMediaItem.get("duration")),
	// 			(String)rawMediaItem.get("artUri"),
	// 			(String)rawMediaItem.get("displayTitle"),
	// 			(String)rawMediaItem.get("displaySubtitle"),
	// 			(String)rawMediaItem.get("displayDescription"),
	// 			// raw2rating((Map<String, Object>)rawMediaItem.get("rating")),
	// 			(Map<?, ?>)rawMediaItem.get("extras")
	// 	);
	// }

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
    
    public static Long getLong(Object o) {
		return (o == null || o instanceof Long) ? (Long)o : new Long(((Integer)o).intValue());
	}
}

