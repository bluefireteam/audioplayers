package xyz.luan.audioplayers

import android.media.MediaDataSource
import java.io.IOException
import kotlin.jvm.Throws

class ByteDataSource(
        private val data: ByteArray,
) : MediaDataSource() {
    @Synchronized
    @Throws(IOException::class)
    override fun getSize(): Long {
        return data.size.toLong()
    }

    @Synchronized
    @Throws(IOException::class)
    override fun close() {
    }

    @Synchronized
    override fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int {
        if (position >= data.size) {
            return -1
        }

        var remainingSize = size
        if (position + remainingSize > data.size) {
            remainingSize -= position.toInt() + remainingSize - data.size
        }
        System.arraycopy(data, position.toInt(), buffer, offset, remainingSize)
        return remainingSize
    }

}