package xyz.luan.audioplayers;

public interface AudioPlayerStatusListener {

    void handlePause(Player player);
    void handleIsPlaying(Player player);
    void handleDuration(Player player);
    void handleCompletion(Player player);
    void handleSeekComplete(Player player);
    void handleError(Player player, String message);

}
