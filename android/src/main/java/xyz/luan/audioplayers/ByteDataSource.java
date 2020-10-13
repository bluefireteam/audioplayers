package xyz.luan.audioplayers;

import android.media.MediaDataSource;
import android.os.Build;

import java.io.*;

public class ByteDataSource extends MediaDataSource {
    private byte[] data;

    public ByteDataSource(byte[] realData) {
        data = realData;
    }

    @Override
    public synchronized long getSize() throws IOException {
        return data == null ? 0 : data.length;
    } 

    @Override
    public synchronized void close() throws IOException {
    }

    @Override
    public synchronized int readAt(long position, byte[] buffer, int offset, int size) {
        if (position >= data.length) {
            return -1;
        }

        if (position + size > data.length) {
            size -= ((int)position + size) - data.length;
        }
        
        System.arraycopy(data, (int)position, buffer, offset, size);
        return size;
    }
}