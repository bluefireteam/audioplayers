package xyz.luan.audioplayers.source

data class UrlSource(
    val url: String,
    val isLocal: Boolean,
) : Source
