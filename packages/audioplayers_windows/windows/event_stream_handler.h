#pragma once

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>

#include <mutex>
#include <memory>

#include "platform_thread_handler.h"

using namespace flutter;

/**
 * Thread-safe EventStreamHandler for audioplayers_windows.
 * 
 * This handler ensures that all EventSink calls are made on the platform thread,
 * even when called from MediaFoundation's MTA threads.
 * 
 * IMPORTANT: PlatformThreadHandler::Initialize() must be called before using this handler.
 */
template <typename T = EncodableValue>
class EventStreamHandler : public StreamHandler<T> {
 public:
  EventStreamHandler() = default;

  virtual ~EventStreamHandler() = default;

  /**
   * Send a success event to Flutter.
   * Thread-safe: automatically marshals to platform thread if needed.
   */
  void Success(std::unique_ptr<T> _data) {
    // Capture data by moving into shared_ptr for safe cross-thread transfer
    auto sharedData = std::make_shared<T>(std::move(*_data));
    
    audioplayers::PlatformThreadHandler::RunOnPlatformThread([this, sharedData]() {
      std::unique_lock<std::mutex> _ul(m_mtx);
      if (m_sink.get()) {
        m_sink.get()->Success(*sharedData);
      }
    });
  }

  /**
   * Send an error event to Flutter.
   * Thread-safe: automatically marshals to platform thread if needed.
   */
  void Error(const std::string& error_code,
             const std::string& error_message,
             const T& error_details) {
    // Copy parameters for safe cross-thread transfer
    auto code = error_code;
    auto message = error_message;
    auto details = error_details;
    
    audioplayers::PlatformThreadHandler::RunOnPlatformThread([this, code, message, details]() {
      std::unique_lock<std::mutex> _ul(m_mtx);
      if (m_sink.get()) {
        m_sink.get()->Error(code, message, details);
      }
    });
  }

 protected:
  std::unique_ptr<StreamHandlerError<T>> OnListenInternal(
      const T* arguments,
      std::unique_ptr<EventSink<T>>&& events) override {
    std::unique_lock<std::mutex> _ul(m_mtx);
    m_sink = std::move(events);
    return nullptr;
  }

  std::unique_ptr<StreamHandlerError<T>> OnCancelInternal(
      const T* arguments) override {
    std::unique_lock<std::mutex> _ul(m_mtx);
    m_sink.reset();  // Use reset() instead of release() to properly clean up
    return nullptr;
  }

 private:
  std::mutex m_mtx;
  std::unique_ptr<EventSink<T>> m_sink;
};
