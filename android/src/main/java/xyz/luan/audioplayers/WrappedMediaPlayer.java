package xyz.luan.audioplayers;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.AudioAttributes;
import android.os.Build;
import android.os.Handler;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class WrappedMediaPlayer implements MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener {

    private String playerId;

    private String url;
    private double volume = 1.0;
    private ReleaseMode releaseMode = ReleaseMode.RELEASE;

    private boolean released = true;
    private boolean prepared = false;
    private boolean playing = false;

    private MediaPlayer player;
    private AudioplayersPlugin ref;

    public WrappedMediaPlayer(AudioplayersPlugin ref, String playerId) {
        this.ref = ref;
        this.playerId = playerId;
    }

    public void setUrl(String url) {
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

    public String getUrl() {
        return this.url;
    }

    public void setVolume(double volume) {
        if (this.volume != volume) {
            this.volume = volume;
            if (!this.released) {
                this.player.setVolume((float) volume, (float) volume);
            }
        }
    }

    public double getVolume() {
        return this.volume;
    }

    public boolean isPlaying() {
        return this.playing;
    }

    public boolean isActuallyPlaying() {
        return this.playing && this.prepared;
    }

    public void play() {
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
            }
        }
    }

    public void stop() {
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

    public void release() {
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

    public void pause() {
        if (this.playing) {
            this.playing = false;
            this.player.pause();
        }
    }

    private void setSource(String url) {
        try {
            this.player.setDataSource(url);
        } catch (IOException ex) {
            throw new RuntimeException("Unable to access resource", ex);
        }
    }

    public void seek(double position) {
        this.player.seekTo((int) (position * 1000));
    }

    public int getDuration() {
        return this.player.getDuration();
    }

    public int getCurrentPosition() {
        return this.player.getCurrentPosition();
    }

    public String getPlayerId() {
        return this.playerId;
    }

    public void setReleaseMode(ReleaseMode releaseMode) {
        if (this.releaseMode != releaseMode) {
            this.releaseMode = releaseMode;
            if (!this.released) {
                this.player.setLooping(releaseMode == ReleaseMode.LOOP);
            }
        }
    }

    public ReleaseMode getReleaseMode() {
        return this.releaseMode;
    }

    @Override
    public void onPrepared(final MediaPlayer mediaPlayer) {
        this.prepared = true;
        if (this.playing) {
            this.player.start();
            ref.handleIsPlaying(this);
        }
    }

    @Override
    public void onCompletion(final MediaPlayer mediaPlayer) {
        if (releaseMode != ReleaseMode.LOOP) {
            this.stop();
        }
        ref.handleCompletion(this);
    }

    private MediaPlayer createPlayer() {
        MediaPlayer player = new MediaPlayer();
        player.setOnPreparedListener(this);
        player.setOnCompletionListener(this);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            player.setAudioAttributes(new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            );
        } else {
            player.setAudioStreamType(AudioManager.STREAM_MUSIC);
        }
        player.setVolume((float) volume, (float) volume);
        player.setLooping(this.releaseMode == ReleaseMode.LOOP);
        return player;
    }

    private static boolean objectEquals(Object o1, Object o2) {
        return o1 == null && o2 == null || o1 != null && o1.equals(o2);
    }
}
