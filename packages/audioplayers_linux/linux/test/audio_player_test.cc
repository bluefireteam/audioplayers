#include <gtest/gtest.h>

#include "audio_player.h"

namespace audioplayers_linux {
namespace test {

// The player is not connected to Flutter and has no source, so these tests
// do not depend on any timing of the GStreamer pipeline. They call the bus
// handlers directly, to process the messages in a well defined order.
class AudioPlayerTest : public ::testing::Test {
 protected:
  void SetUp() override {
    player = std::make_unique<AudioPlayer>("p1", nullptr, nullptr);
    player->SetReleaseMode(ReleaseMode::loop);
    player->Resume();
    ASSERT_TRUE(player->IsPlaying());
  }

  void TearDown() override { player->Dispose(); }

  std::unique_ptr<AudioPlayer> player;
};

TEST_F(AudioPlayerTest, LoopRestartsAtEndOfStream) {
  player->OnPlaybackEnded();

  EXPECT_TRUE(player->IsPlaying());
}

// The end of stream message can be dispatched after a stop was handled.
TEST_F(AudioPlayerTest, LoopDoesNotRestartAfterStop) {
  player->Stop();
  player->OnPlaybackEnded();

  EXPECT_FALSE(player->IsPlaying());
}

TEST_F(AudioPlayerTest, LoopDoesNotRestartAfterPause) {
  player->Pause();
  player->OnPlaybackEnded();

  EXPECT_FALSE(player->IsPlaying());
}

}  // namespace test
}  // namespace audioplayers_linux
