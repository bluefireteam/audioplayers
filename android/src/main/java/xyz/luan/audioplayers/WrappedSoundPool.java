package xyz.luan.audioplayers;

import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Build;
import android.os.StrictMode;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.logging.Logger;

import static java.io.File.createTempFile;

public class WrappedSoundPool extends Player implements SoundPool.OnLoadCompleteListener {

    private static final Logger LOGGER = Logger.getLogger(WrappedSoundPool.class.getCanonicalName());

    private static SoundPool soundPool = createSoundPool();

    private final AudioplayersPlugin ref;

    private final String playerId;

    private String url;

    private double volume;

    private Integer soundId;

    private Integer streamId;

    private boolean playing = false;

    private boolean loading = false;

    WrappedSoundPool(AudioplayersPlugin ref, String playerId) {
        this.ref = ref;
        this.playerId = playerId;
    }

    @Override
    String getPlayerId() {
        return null;
    }

    @Override
    void play() {
        if (this.playing) {
            return;
        }
        if (!this.loading) {
            start();
        }
        this.playing = true;
    }

    @Override
    void stop() {

    }

    @Override
    void release() {

    }

    @Override
    void pause() {

    }

    @Override
    void setUrl(final String url) {
        if (this.url != null && this.url.equals(url)) {
            return;
        }
        if (this.soundId != null) {
            soundPool.unload(this.soundId);
        } else {
            soundPool.setOnLoadCompleteListener(this);
        }
        this.url = url;
        this.loading = true;

        final WrappedSoundPool self = this;

        new Thread(new Runnable() {
            @Override
            public void run() {
                self.soundId = soundPool.load(getAudioPath(url), 1);
            }
        }).start();
    }

    @Override
    void setVolume(double volume) {
        this.volume = volume;
    }

    @Override
    void configAttributes(boolean respectSilence) {

    }

    @Override
    void setReleaseMode(ReleaseMode releaseMode) {

    }

    @Override
    int getDuration() {
        return 0;
    }

    @Override
    int getCurrentPosition() {
        return 0;
    }

    @Override
    boolean isActuallyPlaying() {
        return this.playing;
    }

    @Override
    void seek(double position) {

    }

    private static SoundPool createSoundPool() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            AudioAttributes attrs = new AudioAttributes.Builder().setLegacyStreamType(AudioManager.STREAM_MUSIC)
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .build();
            return new SoundPool.Builder().setAudioAttributes(attrs).build();
        }
        return new SoundPool(1, AudioManager.STREAM_MUSIC, 1);
    }

    private void start() {
        this.streamId = soundPool.play(soundId,
                (float) this.volume,
                (float) this.volume,
                0,
                0,
                1.0f);

    }

    private String getAudioPath(String url) {
        if (url.startsWith("/")) {
            return url;
        }
        return loadTempFileFromNetwork(url).getAbsolutePath();
    }

    private File loadTempFileFromNetwork(String url) {
        StrictMode.ThreadPolicy policy =
                new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        FileOutputStream fileOutputStream = null;
        try {
            byte[] bytes = downloadUrl(URI.create(url).toURL());
            File tempFile = createTempFile("sound", "");
            fileOutputStream = new FileOutputStream(tempFile);
            fileOutputStream.write(bytes);
            tempFile.deleteOnExit();
            return tempFile;
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            try {
                if (fileOutputStream != null) {
                    fileOutputStream.close();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private byte[] downloadUrl(URL url) {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        InputStream stream = null;
        try {
            byte[] chunk = new byte[4096];
            int bytesRead;
            stream = url.openStream();

            while ((bytesRead = stream.read(chunk)) > 0) {
                outputStream.write(chunk, 0, bytesRead);
            }

        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            try {
                stream.close();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        return outputStream.toByteArray();
    }


    @Override
    public void onLoadComplete(SoundPool soundPool, int sampleId, int status) {
        if (this.playing && soundId == sampleId) {
            this.loading = false;
            start();
        }
    }
}
