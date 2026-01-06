#pragma once
#include <flutter/encodable_value.h>
#include <functional>
#include <mutex>
#include <queue>

using namespace flutter;

// Helper class to dispatch events to the platform thread
// Uses a thread-safe queue - events are processed on next platform thread call
class PlatformThreadHelper {
 public:
  static PlatformThreadHelper& GetInstance() {
    static PlatformThreadHelper instance;
    return instance;
  }

  // Post an event to be executed on the platform thread
  void PostTask(std::function<void()> task) {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_taskQueue.push(std::move(task));
  }

  // Process all pending tasks - should be called frequently from platform thread
  void ProcessPendingTasks() {
    std::queue<std::function<void()>> tasks;
    {
      std::lock_guard<std::mutex> lock(m_mutex);
      tasks.swap(m_taskQueue);
    }

    while (!tasks.empty()) {
      auto& task = tasks.front();
      try {
        task();
      } catch (...) {
        // Ignore exceptions to prevent crash
      }
      tasks.pop();
    }
  }

 private:
  PlatformThreadHelper() = default;
  ~PlatformThreadHelper() = default;
  PlatformThreadHelper(const PlatformThreadHelper&) = delete;
  PlatformThreadHelper& operator=(const PlatformThreadHelper&) = delete;

  std::mutex m_mutex;
  std::queue<std::function<void()>> m_taskQueue;
};
