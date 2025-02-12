package xyz.luan.audioplayers.source

import android.os.Build
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.M)
data class BytesSource(
    val data: ByteArray,
) : Source
