package xyz.luan.audioplayers

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaDataSource
import android.media.SoundPool
import android.util.Log
import java.io.*
import java.net.URI
import java.net.URL
import java.util.*

class WrappedSoundPool internal constructor(override val playerId: String) : Player() {
    companion object {
        private val soundPool = createSoundPool()

        /** For the onLoadComplete listener, track which sound id is associated with which player. An entry only exists until
         * it has been loaded.
         */
        private val soundIdToPlayer = Collections.synchronizedMap(HashMap<Int, WrappedSoundPool>())

        /** This is to keep track of the players which share the same sound id, referenced by url. When a player release()s, it
         * is removed from the associated player list. The last player to be removed actually unloads() the sound id and then
         * the url is removed from this map.
         */
        private val urlToPlayers = Collections.synchronizedMap(mapOf<String, MutableList<WrappedSoundPool>>())

        private fun createSoundPool(): SoundPool {
            val attrs = AudioAttributes.Builder().setLegacyStreamType(AudioManager.USE_DEFAULT_STREAM_TYPE)
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .build()
            return SoundPool.Builder()
                    .setAudioAttributes(attrs)
                    .setMaxStreams(100)
                    .build()
        }

        init {
            soundPool.setOnLoadCompleteListener { _, sampleId, _ ->
                Log.d("WSP", "Loaded $sampleId")
                val loadingPlayer = soundIdToPlayer[sampleId]
                if (loadingPlayer != null) {
                    soundIdToPlayer.remove(loadingPlayer.soundId)
                    // Now mark all players using this sound as not loading and start them if necessary
                    synchronized(urlToPlayers) {
                        val urlPlayers: List<WrappedSoundPool>? = urlToPlayers[loadingPlayer.url]
                        for (player: WrappedSoundPool in urlPlayers!!) {
                            Log.d("WSP", "Marking $player as loaded")
                            player.loading = false
                            if (player.playing) {
                                Log.d("WSP", "Delayed start of $player")
                                player.start()
                            }
                        }
                    }
                }
            }
        }
    }

    private var url: String? = null
    private var volume = 1.0f
    private var rate = 1.0f
    private var soundId: Int? = null
    private var streamId: Int? = null
    private var playing = false
    private var paused = false
    private var looping = false
    private var loading = false

    override fun play(context: Context) {
        if (!loading) {
            start()
        }
        playing = true
    }

    override fun stop() {
        if (playing) {
            soundPool.stop((streamId)!!)
            playing = false
        }
        paused = false
    }

    override fun release() {
        stop()
        if (soundId != null && url != null) {
            synchronized<Unit>(urlToPlayers) {
                val playersForSoundId = urlToPlayers[url] ?: return
                if (playersForSoundId.singleOrNull() === this) {
                    urlToPlayers.remove(url)
                    soundPool.unload(soundId!!)
                    soundIdToPlayer.remove(soundId)
                    soundId = null
                    Log.d("WSP", "Unloaded soundId $soundId")
                } else {
                    // This is not the last player using the soundId, just remove it from the list.
                    playersForSoundId.remove(this)
                }
            }
        }
    }

    override fun pause() {
        if (playing) {
            soundPool.pause((streamId)!!)
            playing = false
            paused = true
        }
    }

    override fun setDataSource(mediaDataSource: MediaDataSource?, context: Context) {
        throw unsupportedOperation("setDataSource")
    }

    override fun setUrl(url: String?, isLocal: Boolean, context: Context) {
        if (this.url != null && (this.url == url)) {
            return
        }
        if (soundId != null) {
            release()
        }
        synchronized(urlToPlayers) {
            this.url = url
            var urlPlayers = urlToPlayers[url]
            if (urlPlayers != null) {
                // Sound has already been loaded - reuse the soundId.
                val originalPlayer = urlPlayers.first()
                soundId = originalPlayer.soundId
                loading = originalPlayer.loading
                urlPlayers.add(this)
                Log.d("WSP", "Reusing soundId$soundId for $url is loading=$loading $this")
                return
            }

            // First one for this URL - load it.
            loading = true
            val start = System.currentTimeMillis()
            soundId = soundPool.load(getAudioPath(url, isLocal), 1)
            Log.d("WSP", "time to call load() for $url: ${System.currentTimeMillis() - start} player=$this")
            soundIdToPlayer[soundId] = this
            urlPlayers = ArrayList()
            urlPlayers.add(this)
            urlToPlayers.put(url, urlPlayers)
        }
    }

    override fun setVolume(volume: Double) {
        this.volume = volume.toFloat()
        if (playing) {
            soundPool.setVolume((streamId)!!, this.volume, this.volume)
        }
    }

    override fun setRate(rate: Double): Int {
        this.rate = rate.toFloat()
        if (streamId != null) {
            soundPool.setRate(streamId!!, this.rate)
            return 1
        }
        return 0
    }

    override fun configAttributes(
            respectSilence: Boolean,
            stayAwake: Boolean,
            duckAudio: Boolean,
            context: Context,
    ) {}

    override fun setReleaseMode(releaseMode: ReleaseMode) {
        looping = releaseMode === ReleaseMode.LOOP
        if (playing) {
            soundPool.setLoop(streamId!!, if (looping) -1 else 0)
        }
    }

    override val duration: Int
        get() = throw unsupportedOperation("getDuration")

    override val currentPosition: Int
        get() = throw unsupportedOperation("getCurrentPosition")

    override val isActuallyPlaying: Boolean
        get() = false

    override fun setPlayingRoute(playingRoute: String, context: Context) {
        throw unsupportedOperation("setPlayingRoute")
    }

    override fun seek(position: Int) {
        throw unsupportedOperation("seek")
    }

    private fun start() {
        setRate(rate.toDouble())
        if (paused) {
            soundPool.resume((streamId)!!)
            paused = false
        } else {
            streamId = soundPool.play(
                    soundId!!,
                    volume,
                    volume,
                    0,
                    if (looping) -1 else 0,
                    1.0f,
            )
        }
    }

    private fun getAudioPath(url: String?, isLocal: Boolean): String? {
        return if (isLocal) url else loadTempFileFromNetwork(url).absolutePath
    }

    private fun loadTempFileFromNetwork(url: String?): File {
        var fileOutputStream: FileOutputStream? = null
        try {
            val bytes = downloadUrl(URI.create(url).toURL())
            val tempFile = File.createTempFile("sound", "")
            fileOutputStream = FileOutputStream(tempFile)
            fileOutputStream.write(bytes)
            tempFile.deleteOnExit()
            return tempFile
        } catch (e: IOException) {
            throw RuntimeException(e)
        } finally {
            try {
                fileOutputStream?.close()
            } catch (e: IOException) {
                throw RuntimeException(e)
            }
        }
    }

    private fun downloadUrl(url: URL): ByteArray {
        val outputStream = ByteArrayOutputStream()
        var stream: InputStream? = null
        try {
            val chunk = ByteArray(4096)
            var bytesRead: Int
            stream = url.openStream()
            while ((stream.read(chunk).also { bytesRead = it }) > 0) {
                outputStream.write(chunk, 0, bytesRead)
            }
        } catch (e: IOException) {
            throw RuntimeException(e)
        } finally {
            try {
                stream!!.close()
            } catch (e: IOException) {
                throw RuntimeException(e)
            }
        }
        return outputStream.toByteArray()
    }

    private fun unsupportedOperation(message: String): UnsupportedOperationException {
        return UnsupportedOperationException("LOW_LATENCY mode does not support: $message")
    }
}