package xyz.luan.audioplayers;

import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Build;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;

import static java.io.File.createTempFile;

public class WrappedSoundPool extends Player {

    private static SoundPool soundPool = createSoundPool();

    private final AudioplayersPlugin ref;

    private final String playerId;

    private String url;

    private double volume;

    private Integer soundId;

    private Integer streamId;


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
        this.streamId = soundPool.play(soundId,
                (float) this.volume,
                (float) this.volume,
                0,
                0,
                1.0f);
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
    void setUrl(String url) {
        if (this.url != null && this.url.equals(url)) {
            return;
        }
        if (this.soundId != null) {
            soundPool.unload(this.soundId);
        }
        this.soundId = soundPool.load(getAudioPath(url), 1);
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
        return false;
    }

    @Override
    void seek(double position) {

    }

    private static SoundPool createSoundPool() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            AudioAttributes attrs = new AudioAttributes.Builder().setLegacyStreamType(AudioManager.STREAM_MUSIC)
                    .setUsage(AudioAttributes.USAGE_UNKNOWN)
                    .build();
            return new SoundPool.Builder().setAudioAttributes(attrs).build();
        }
        return new SoundPool(1, AudioManager.STREAM_MUSIC, 1);
    }

    private String getAudioPath(String url) {
        InputStream inputStream = null;
        FileOutputStream fileOutputStream = null;
        try {
            File tempFile = createTempFile("sound", "pool");
            fileOutputStream = new FileOutputStream(tempFile);
            inputStream = URI.create(url).toURL().openStream();
            byte bytes[] = new byte[inputStream.available()];
            BufferedInputStream bis = new BufferedInputStream(inputStream);
            DataInputStream dis = new DataInputStream(bis);
            dis.readFully(bytes);
            fileOutputStream.write(bytes);
            tempFile.deleteOnExit();
            return tempFile.getAbsolutePath();
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            try {
                if (fileOutputStream != null) {
                    fileOutputStream.close();
                }
                if (inputStream != null) {
                    inputStream.close();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }
}
