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
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class AudioService extends MediaBrowserServiceCompat implements AudioManager.OnAudioFocusChangeListener {
	private static final int NOTIFICATION_ID = 1124;
	private static final int REQUEST_CONTENT_INTENT = 1000;
	private static final String MEDIA_ROOT_ID = "root";
	// See the comment in onMediaButtonEvent to understand how the BYPASS keycodes work.
	// We hijack KEYCODE_MUTE and KEYCODE_MEDIA_RECORD since the media session subsystem
	// considers these keycodes relevant to media playback and will pass them on to us.
	public static final int KEYCODE_BYPASS_PLAY = KeyEvent.KEYCODE_MUTE;
	public static final int KEYCODE_BYPASS_PAUSE = KeyEvent.KEYCODE_MEDIA_RECORD;
	public static final int MAX_COMPACT_ACTIONS = 3;

	private static volatile boolean running;
	static AudioService instance;
	private static PendingIntent contentIntent;
	private static boolean resumeOnClick;
	private static ServiceListener listener;
	static String androidNotificationChannelName;
	static String androidNotificationChannelDescription;
	static Integer notificationColor;
	static String androidNotificationIcon;
	static boolean androidNotificationClickStartsActivity;
	static boolean androidNotificationOngoing;
	static boolean androidStopForegroundOnPause;
	static boolean androidStopOnRemoveTask;
	static boolean isForeground;
	private static List<MediaSessionCompat.QueueItem> queue = new ArrayList<MediaSessionCompat.QueueItem>();
	private static int queueIndex = -1;
	private static Map<String, MediaMetadataCompat> mediaMetadataCache = new HashMap<>();
	private static Set<String> artUriBlacklist = new HashSet<>();
	private static LruCache<String, Bitmap> artBitmapCache;
	private static Size artDownscaleSize;

	public static void init(Activity activity, boolean resumeOnClick, String androidNotificationChannelName, String androidNotificationChannelDescription, Integer notificationColor, String androidNotificationIcon, boolean androidNotificationClickStartsActivity, boolean androidNotificationOngoing, boolean androidStopForegroundOnPause, boolean androidStopOnRemoveTask, Size artDownscaleSize, ServiceListener listener) {
		if (running)
			throw new IllegalStateException("AudioService already running");
		running = true;

		Context context = activity.getApplicationContext();
		Intent intent = new Intent(context, activity.getClass());
		contentIntent = PendingIntent.getActivity(context, REQUEST_CONTENT_INTENT, intent, PendingIntent.FLAG_UPDATE_CURRENT);
		AudioService.listener = listener;
		AudioService.resumeOnClick = resumeOnClick;
		AudioService.androidNotificationChannelName = androidNotificationChannelName;
		AudioService.androidNotificationChannelDescription = androidNotificationChannelDescription;
		AudioService.notificationColor = notificationColor;
		AudioService.androidNotificationIcon = androidNotificationIcon;
		AudioService.androidNotificationClickStartsActivity = androidNotificationClickStartsActivity;
		AudioService.androidNotificationOngoing = androidNotificationOngoing;
		AudioService.androidStopForegroundOnPause = androidStopForegroundOnPause;
		AudioService.androidStopOnRemoveTask = androidStopOnRemoveTask;
		AudioService.artDownscaleSize = artDownscaleSize;

		// Get max available VM memory, exceeding this amount will throw an
		// OutOfMemory exception. Stored in kilobytes as LruCache takes an
		// int in its constructor.
		final int maxMemory = (int)(Runtime.getRuntime().maxMemory() / 1024);

		// Use 1/8th of the available memory for this memory cache.
		final int cacheSize = maxMemory / 8;

		artBitmapCache = new LruCache<String, Bitmap>(cacheSize) {
			@Override
			protected int sizeOf(String key, Bitmap bitmap) {
				// The cache size will be measured in kilobytes rather than
				// number of items.
				return bitmap.getByteCount() / 1024;
			}
		};
	}

	public void stop() {
		running = false;
		mediaMetadata = null;
		resumeOnClick = false;
		listener = null;
		androidNotificationChannelName = null;
		androidNotificationChannelDescription = null;
		notificationColor = null;
		androidNotificationIcon = null;
		artDownscaleSize = null;
		queue.clear();
		queueIndex = -1;
		mediaMetadataCache.clear();
		actions.clear();
		artBitmapCache.evictAll();
		compactActionIndices = null;

		mediaSession.setQueue(queue);
		instance.abandonAudioFocus();
		unregisterNoisyReceiver();
		mediaSession.setActive(false);
		if (wakeLock.isHeld()) wakeLock.release();
		stopForeground(true);
		stopSelf();
	}

	public static boolean isRunning() {
		return running;
	}

	private PowerManager.WakeLock wakeLock;
	private BroadcastReceiver noisyReceiver;
	private MediaSessionCompat mediaSession;
	private MediaSessionCallback mediaSessionCallback;
	private AudioManager audioManager;
	private MediaMetadataCompat preparedMedia;
	private List<NotificationCompat.Action> actions = new ArrayList<NotificationCompat.Action>();
	private int[] compactActionIndices;
	private MediaMetadataCompat mediaMetadata;
	private Object audioFocusRequest;
	private String notificationChannelId;
	private Handler handler = new Handler(Looper.getMainLooper());

	int getResourceId(String resource) {
		String[] parts = resource.split("/");
		String resourceType = parts[0];
		String resourceName = parts[1];
		return getResources().getIdentifier(resourceName, resourceType, getApplicationContext().getPackageName());
	}

	NotificationCompat.Action action(String resource, String label, long actionCode) {
		int iconId = getResourceId(resource);
		return new NotificationCompat.Action(iconId, label,
				buildMediaButtonPendingIntent(actionCode));
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
		return PendingIntent.getBroadcast(this, keyCode, intent, 0);
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

	void setState(List<NotificationCompat.Action> actions, int actionBits, int[] compactActionIndices, int playbackState, long position, float speed, long updateTime) {
		this.actions = actions;
		this.compactActionIndices = compactActionIndices;

		PlaybackStateCompat.Builder stateBuilder = new PlaybackStateCompat.Builder()
				.setActions(PlaybackStateCompat.ACTION_PLAY_PAUSE | actionBits)
				.setState(playbackState, position, speed, updateTime);
		mediaSession.setPlaybackState(stateBuilder.build());

		if (playbackState == PlaybackStateCompat.STATE_PAUSED) stopForegroundOnPause();
		if (androidStopForegroundOnPause && !isForeground && (playbackState == PlaybackStateCompat.STATE_BUFFERING || playbackState == PlaybackStateCompat.STATE_PLAYING)) {
			mediaSessionCallback.play(new Runnable() {
				@Override
				public void run() {

				}
			});
		} else
			updateNotification();
	}

	private Notification buildNotification() {
		int[] compactActionIndices = this.compactActionIndices;
		if (compactActionIndices == null) {
			compactActionIndices = new int[Math.min(MAX_COMPACT_ACTIONS, actions.size())];
			for (int i = 0; i < compactActionIndices.length; i++) compactActionIndices[i] = i;
		}
		String contentTitle = "";
		String contentText = "";
		CharSequence subText = null;
		Bitmap artBitmap = null;
		if (mediaMetadata != null) {
			MediaDescriptionCompat description = mediaMetadata.getDescription();
			contentTitle = description.getTitle().toString();
			contentText = description.getSubtitle().toString();
			artBitmap = description.getIconBitmap();
			subText = description.getDescription();
		}
		NotificationCompat.Builder builder = getNotificationBuilder()
				.setContentTitle(contentTitle)
				.setContentText(contentText)
				.setSubText(subText);
		if (androidNotificationClickStartsActivity)
			builder.setContentIntent(mediaSession.getController().getSessionActivity());
		if (notificationColor != null)
			builder.setColor(notificationColor);
		for (NotificationCompat.Action action : actions) {
			builder.addAction(action);
		}
		if (artBitmap != null)
			builder.setLargeIcon(artBitmap);
		builder.setStyle(new MediaStyle()
				.setMediaSession(mediaSession.getSessionToken())
				.setShowActionsInCompactView(compactActionIndices)
				.setShowCancelButton(true)
				.setCancelButtonIntent(buildMediaButtonPendingIntent(PlaybackStateCompat.ACTION_STOP))
		);
		if (androidNotificationOngoing)
			builder.setOngoing(true);
		Notification notification = builder.build();
		return notification;
	}

	private NotificationCompat.Builder getNotificationBuilder() {
		NotificationCompat.Builder notificationBuilder = null;
		if (notificationBuilder == null) {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
				createChannel();
			int iconId = getResourceId(androidNotificationIcon);
			notificationBuilder = new NotificationCompat.Builder(this, notificationChannelId)
					.setSmallIcon(iconId)
					.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
					.setShowWhen(false)
					.setDeleteIntent(buildMediaButtonPendingIntent(PlaybackStateCompat.ACTION_STOP))
			;
		}
		return notificationBuilder;
	}

	private int requestAudioFocus() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
			return requestAudioFocusO();
		else
			return audioManager.requestAudioFocus(this,
					AudioManager.STREAM_MUSIC,
					AudioManager.AUDIOFOCUS_GAIN);
	}

	@RequiresApi(Build.VERSION_CODES.O)
	private int requestAudioFocusO() {
		AudioAttributes audioAttributes = new AudioAttributes.Builder()
				.setUsage(AudioAttributes.USAGE_MEDIA)
				.setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
				.build();
		audioFocusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
				.setAudioAttributes(audioAttributes)
				.setWillPauseWhenDucked(true)
				.setOnAudioFocusChangeListener(this)
				.build();
		return audioManager.requestAudioFocus((AudioFocusRequest)audioFocusRequest);
	}

	private void abandonAudioFocus() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
			abandonAudioFocusO();
		else
			audioManager.abandonAudioFocus(this);
	}

	@RequiresApi(Build.VERSION_CODES.O)
	private void abandonAudioFocusO() {
		audioManager.abandonAudioFocusRequest((AudioFocusRequest)audioFocusRequest);
	}

	@RequiresApi(Build.VERSION_CODES.O)
	private void createChannel() {
		NotificationManager notificationManager = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
		NotificationChannel channel = notificationManager.getNotificationChannel(notificationChannelId);
		if (channel == null) {
			channel = new NotificationChannel(notificationChannelId, androidNotificationChannelName, NotificationManager.IMPORTANCE_LOW);
			if (androidNotificationChannelDescription != null)
				channel.setDescription(androidNotificationChannelDescription);
			notificationManager.createNotificationChannel(channel);
		}
	}

	private void updateNotification() {
		NotificationManager notificationManager = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.notify(NOTIFICATION_ID, buildNotification());
	}

	private void registerNoisyReceiver() {
		if (noisyReceiver != null) return;
		noisyReceiver = new BroadcastReceiver() {
			@Override
			public void onReceive(Context context, Intent intent) {
				if (AudioManager.ACTION_AUDIO_BECOMING_NOISY.equals(intent.getAction())) {
					listener.onAudioBecomingNoisy();
				}
			}
		};
		registerReceiver(noisyReceiver, new IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY));
	}

	private void unregisterNoisyReceiver() {
		if (noisyReceiver == null) return;
		unregisterReceiver(noisyReceiver);
		noisyReceiver = null;
	}

	private void stopForegroundOnPause() {
		unregisterNoisyReceiver();
		if (androidStopForegroundOnPause && isForeground) {
			stopForeground(false);
			isForeground = false;
		}
	}

	static MediaMetadataCompat createMediaMetadata(String mediaId, String album, String title, String artist, String genre, Long duration, String artUri, String displayTitle, String displaySubtitle, String displayDescription, RatingCompat rating, Map<?, ?> extras) {
		MediaMetadataCompat.Builder builder = new MediaMetadataCompat.Builder()
				.putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, mediaId)
				.putString(MediaMetadataCompat.METADATA_KEY_ALBUM, album)
				.putString(MediaMetadataCompat.METADATA_KEY_TITLE, title);
		if (artist != null)
			builder.putString(MediaMetadataCompat.METADATA_KEY_ARTIST, artist);
		if (genre != null)
			builder.putString(MediaMetadataCompat.METADATA_KEY_GENRE, genre);
		if (duration != null)
			builder.putLong(MediaMetadataCompat.METADATA_KEY_DURATION, duration);
		if (artUri != null) {
			builder.putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_ICON_URI, artUri);
			String artCacheFilePath = null;
			if (extras != null) {
				artCacheFilePath = (String)extras.get("artCacheFile");
			}
			if (artCacheFilePath != null) {
				Bitmap bitmap = loadArtBitmapFromFile(artCacheFilePath);
				if (bitmap != null) {
					builder.putBitmap(MediaMetadataCompat.METADATA_KEY_ALBUM_ART, bitmap);
					builder.putBitmap(MediaMetadataCompat.METADATA_KEY_DISPLAY_ICON, bitmap);
				}
			}
		}
		if (displayTitle != null)
			builder.putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE, displayTitle);
		if (displaySubtitle != null)
			builder.putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE, displaySubtitle);
		if (displayDescription != null)
			builder.putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_DESCRIPTION, displayDescription);
		if (rating != null) {
			builder.putRating(MediaMetadataCompat.METADATA_KEY_RATING, rating);
		}
		if (extras != null) {
			for (Object o : extras.keySet()) {
				String key = (String)o;
				Object value = extras.get(key);
				if (value instanceof Long) {
					builder.putLong("extra_long_" + key, (Long)value);
				} else if (value instanceof Integer) {
					builder.putLong("extra_long_" + key, (Integer)value);
				} else if (value instanceof String) {
					builder.putString("extra_string_" + key, (String)value);
				}
			}
		}
		MediaMetadataCompat mediaMetadata = builder.build();
		mediaMetadataCache.put(mediaId, mediaMetadata);
		return mediaMetadata;
	}

	static MediaMetadataCompat getMediaMetadata(String mediaId) {
		return mediaMetadataCache.get(mediaId);
	}

	@Override
	public void onCreate() {
		super.onCreate();
		instance = this;
		notificationChannelId = getApplication().getPackageName() + ".channel";
		audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);

		mediaSession = new MediaSessionCompat(this, "media-session");
		mediaSession.setMediaButtonReceiver(null); // TODO: Make this configurable
		mediaSession.setFlags(MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS | MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS);
		PlaybackStateCompat.Builder stateBuilder = new PlaybackStateCompat.Builder()
				.setActions(PlaybackStateCompat.ACTION_PLAY);
		mediaSession.setPlaybackState(stateBuilder.build());
		mediaSession.setCallback(mediaSessionCallback = new MediaSessionCallback());
		setSessionToken(mediaSession.getSessionToken());
		mediaSession.setQueue(queue);

		PowerManager pm = (PowerManager)getSystemService(Context.POWER_SERVICE);
		wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, AudioService.class.getName());
	}

	void enableQueue() {
		mediaSession.setFlags(MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS | MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS | MediaSessionCompat.FLAG_HANDLES_QUEUE_COMMANDS);
	}

	void setQueue(List<MediaSessionCompat.QueueItem> queue) {
		this.queue = queue;
		mediaSession.setQueue(queue);
	}

	void playMediaItem(MediaDescriptionCompat description) {
		mediaSessionCallback.onPlayMediaItem(description);
	}

	void setMetadata(final MediaMetadataCompat mediaMetadata) {
		this.mediaMetadata = mediaMetadata;
		mediaSession.setMetadata(mediaMetadata);
		updateNotification();
	}

	static Bitmap loadArtBitmapFromFile(String path) {
		Bitmap bitmap = artBitmapCache.get(path);
		if (bitmap != null) return bitmap;
		try {
			if (artDownscaleSize != null) {
				BitmapFactory.Options options = new BitmapFactory.Options();
				options.inJustDecodeBounds = true;
				BitmapFactory.decodeFile(path, options);
				int imageHeight = options.outHeight;
				int imageWidth = options.outWidth;
				options.inSampleSize = calculateInSampleSize(options, artDownscaleSize.width, artDownscaleSize.height);
				options.inJustDecodeBounds = false;

				bitmap = BitmapFactory.decodeFile(path, options);
			} else {
				bitmap = BitmapFactory.decodeFile(path);
			}
			artBitmapCache.put(path, bitmap);
			return bitmap;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	private static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
		final int height = options.outHeight;
		final int width = options.outWidth;
		int inSampleSize = 1;

		if (height > reqHeight || width > reqWidth) {
			final int halfHeight = height / 2;
			final int halfWidth = width / 2;
			while ((halfHeight / inSampleSize) >= reqHeight
					&& (halfWidth / inSampleSize) >= reqWidth) {
				inSampleSize *= 2;
			}
		}

		return inSampleSize;
	}

	@Override
	public BrowserRoot onGetRoot(String clientPackageName, int clientUid, Bundle rootHints) {
		return new BrowserRoot(MEDIA_ROOT_ID, null);
	}

	@Override
	public void onLoadChildren(final String parentMediaId, final Result<List<MediaBrowserCompat.MediaItem>> result) {
		if (listener == null) {
			result.sendResult(new ArrayList<MediaBrowserCompat.MediaItem>());
			return;
		}
		listener.onLoadChildren(parentMediaId, result);
	}

	@Override
	public int onStartCommand(final Intent intent, int flags, int startId) {
		MediaButtonReceiver.handleIntent(mediaSession, intent);
		return START_NOT_STICKY;
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		if (listener != null) {
			listener.onDestroy();
		}
		instance = null;
	}

	@Override
	public void onTaskRemoved(Intent rootIntent) {
		MediaControllerCompat controller = mediaSession.getController();
		if (androidStopOnRemoveTask || (androidStopForegroundOnPause && controller.getPlaybackState().getState() == PlaybackStateCompat.STATE_PAUSED)) {
			listener.onStop();
		}
		super.onTaskRemoved(rootIntent);
	}

	@Override
	public void onAudioFocusChange(int focusChange) {
		switch (focusChange) {
		case AudioManager.AUDIOFOCUS_GAIN:
			listener.onAudioFocusGained();
			break;
		case AudioManager.AUDIOFOCUS_LOSS:
			listener.onAudioFocusLost();
			break;
		case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
			listener.onAudioFocusLostTransient();
			break;
		case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
			listener.onAudioFocusLostTransientCanDuck();
			break;
		default:
			break;
		}
	}

	public class MediaSessionCallback extends MediaSessionCompat.Callback {
		@Override
		public void onAddQueueItem(MediaDescriptionCompat description) {
			if (listener == null) return;
			listener.onAddQueueItem(getMediaMetadata(description.getMediaId()));
		}

		@Override
		public void onAddQueueItem(MediaDescriptionCompat description, int index) {
			if (listener == null) return;
			listener.onAddQueueItemAt(getMediaMetadata(description.getMediaId()), index);
		}

		@Override
		public void onRemoveQueueItem(MediaDescriptionCompat description) {
			if (listener == null) return;
			listener.onRemoveQueueItem(getMediaMetadata(description.getMediaId()));
		}

		@Override
		public void onPrepare() {
			if (listener == null) return;
			if (!mediaSession.isActive())
				mediaSession.setActive(true);
			listener.onPrepare();
		}

		@Override
		public void onPlay() {
			if (listener == null) return;
			play(new Runnable() {
				public void run() {
					listener.onPlay();
				}
			});
		}

		private void play(Runnable runner) {
			int result = requestAudioFocus();
			if (result != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
				// Don't play audio
				return;
			}

			startService(new Intent(AudioService.this, AudioService.class));
			if (!mediaSession.isActive())
				mediaSession.setActive(true);

			runner.run();

			acquireWakeLock();
			registerNoisyReceiver();
			mediaSession.setSessionActivity(contentIntent);
			startForeground(NOTIFICATION_ID, buildNotification());
			isForeground = true;
		}

		@Override
		public void onPrepareFromMediaId(String mediaId, Bundle extras) {
			if (listener == null) return;
			if (!mediaSession.isActive())
				mediaSession.setActive(true);
			listener.onPrepareFromMediaId(mediaId);
		}

		@Override
		public void onPlayFromMediaId(final String mediaId, final Bundle extras) {
			if (listener == null) return;
			play(new Runnable() {
				public void run() {
					listener.onPlayFromMediaId(mediaId);
				}
			});
		}

		private void acquireWakeLock() {
			if (!wakeLock.isHeld())
				wakeLock.acquire();
		}

		@Override
		public boolean onMediaButtonEvent(Intent mediaButtonEvent) {
			if (listener == null) return false;
			final KeyEvent event = (KeyEvent)mediaButtonEvent.getExtras().get(Intent.EXTRA_KEY_EVENT);
			if (event.getAction() == KeyEvent.ACTION_DOWN) {
				switch (event.getKeyCode()) {
				case KEYCODE_BYPASS_PLAY:
					onPlay();
					break;
				case KEYCODE_BYPASS_PAUSE:
					onPause();
					break;
				case KeyEvent.KEYCODE_MEDIA_NEXT:
					onSkipToNext();
					break;
				case KeyEvent.KEYCODE_MEDIA_PREVIOUS:
					onSkipToPrevious();
					break;
				case KeyEvent.KEYCODE_MEDIA_STOP:
					onStop();
					break;
				case KeyEvent.KEYCODE_MEDIA_FAST_FORWARD:
					onFastForward();
					break;
				case KeyEvent.KEYCODE_MEDIA_REWIND:
					onRewind();
					break;
				// Android unfortunately reroutes media button clicks to
				// KEYCODE_MEDIA_PLAY/PAUSE instead of the expected KEYCODE_HEADSETHOOK
				// or KEYCODE_MEDIA_PLAY_PAUSE. As a result, we can't genuinely tell if
				// onMediaButtonEvent was called because a media button was actually
				// pressed or because a PLAY/PAUSE action was pressed instead! To get
				// around this, we make PLAY and PAUSE actions use different keycodes:
				// KEYCODE_BYPASS_PLAY/PAUSE. Now if we get KEYCODE_MEDIA_PLAY/PUASE
				// we know it is actually a media button press.
				case KeyEvent.KEYCODE_MEDIA_PLAY:
				case KeyEvent.KEYCODE_MEDIA_PAUSE:
					// These are the "genuine" media button click events
				case KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE:
				case KeyEvent.KEYCODE_HEADSETHOOK:
					MediaControllerCompat controller = mediaSession.getController();
					// If you press the media button while in the pause state, we reactivate the media session.
					if (resumeOnClick && controller.getPlaybackState().getState() == PlaybackStateCompat.STATE_PAUSED) {
						play(new Runnable() {
							public void run() {
								listener.onClick(mediaControl(event));
							}
						});
					} else {
						listener.onClick(mediaControl(event));
					}
					break;
				}
			}
			return true;
		}

		private MediaControl mediaControl(KeyEvent event) {
			switch (event.getKeyCode()) {
			case KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE:
			case KeyEvent.KEYCODE_HEADSETHOOK:
				return MediaControl.media;
			case KeyEvent.KEYCODE_MEDIA_NEXT:
				return MediaControl.next;
			case KeyEvent.KEYCODE_MEDIA_PREVIOUS:
				return MediaControl.previous;
			default:
				return MediaControl.media;
			}
		}

		@Override
		public void onPause() {
			if (listener == null) return;
			listener.onPause();
		}

		@Override
		public void onStop() {
			if (listener == null) return;
			listener.onStop();
		}

		@Override
		public void onSkipToNext() {
			if (listener == null) return;
			listener.onSkipToNext();
		}

		@Override
		public void onSkipToPrevious() {
			if (listener == null) return;
			listener.onSkipToPrevious();
		}

		@Override
		public void onFastForward() {
			if (listener == null) return;
			listener.onFastForward();
		}

		@Override
		public void onRewind() {
			if (listener == null) return;
			listener.onRewind();
		}

		@Override
		public void onSkipToQueueItem(long id) {
			if (listener == null) return;
			listener.onSkipToQueueItem(id);
		}

		@Override
		public void onSeekTo(long pos) {
			if (listener == null) return;
			listener.onSeekTo(pos);
		}

		@Override
		public void onSetRating(RatingCompat rating) {
			if (listener == null) return;
			listener.onSetRating(rating);
		}

		@Override
		public void onSetRating(RatingCompat rating, Bundle extras) {
			if (listener == null) return;
			listener.onSetRating(rating, extras);
		}

		//
		// NON-STANDARD METHODS
		//

		public void onPlayMediaItem(final MediaDescriptionCompat description) {
			if (listener == null) return;
			play(new Runnable() {
				public void run() {
					listener.onPlayMediaItem(getMediaMetadata(description.getMediaId()));
				}
			});
		}
	}

	public static interface ServiceListener {
		void onLoadChildren(String parentMediaId, Result<List<MediaBrowserCompat.MediaItem>> result);

		void onAudioFocusGained();

		void onAudioFocusLost();

		void onAudioFocusLostTransient();

		void onAudioFocusLostTransientCanDuck();

		void onAudioBecomingNoisy();

		void onClick(MediaControl mediaControl);

		void onPrepare();

		void onPrepareFromMediaId(String mediaId);

		//void onPrepareFromSearch(String query);
		//void onPrepareFromUri(String uri);
		void onPlay();

		void onPlayFromMediaId(String mediaId);

		//void onPlayFromSearch(String query, Map<?,?> extras);
		//void onPlayFromUri(String uri, Map<?,?> extras);
		void onSkipToQueueItem(long id);

		void onPause();

		void onSkipToNext();

		void onSkipToPrevious();

		void onFastForward();

		void onRewind();

		void onStop();

		void onDestroy();

		void onSeekTo(long pos);

		void onSetRating(RatingCompat rating);

		void onSetRating(RatingCompat rating, Bundle extras);

		//void onSetRepeatMode(@PlaybackStateCompat.RepeatMode int repeatMode)
		//void onSetShuffleModeEnabled(boolean enabled);
		//void onSetShuffleMode(@PlaybackStateCompat.ShuffleMode int shuffleMode);
		//void onCustomAction(String action, Bundle extras);
		void onAddQueueItem(MediaMetadataCompat metadata);

		void onAddQueueItemAt(MediaMetadataCompat metadata, int index);

		void onRemoveQueueItem(MediaMetadataCompat metadata);

		//
		// NON-STANDARD METHODS
		//

		void onPlayMediaItem(MediaMetadataCompat metadata);
	}
}
