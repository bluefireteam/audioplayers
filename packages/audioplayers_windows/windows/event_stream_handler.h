#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>

#include <functional>
#include <memory>
#include <mutex>

#include "platform_thread_helper.h"

using namespace flutter;

template <typename T = EncodableValue>
class EventStreamHandler : public StreamHandler<T> {
 public:
  EventStreamHandler() : m_isAlive(std::make_shared<bool>(true)) {}

  virtual ~EventStreamHandler() = default;

  void Success(std::unique_ptr<T> _data) {
    // Copy data immediately to avoid lifetime issues
    auto data_copy = std::make_shared<T>(*_data);
    std::weak_ptr<bool> weak_alive = m_isAlive;

    // Post EVERYTHING to platform thread - do NOT access m_sink here!
    PlatformThreadHelper::GetInstance().PostTask([this, data_copy, weak_alive]() {
      if (weak_alive.expired()) {
        return;
      }
      std::unique_lock<std::mutex> _ul(m_mtx);
      if (m_sink.get()) {
        m_sink.get()->Success(*data_copy);
      }
    });
  }

  void Error(const std::string& error_code,
             const std::string& error_message,
             const T& error_details) {
    // Capture by value for thread safety
    auto code_copy = error_code;
    auto message_copy = error_message;
    auto details_copy = error_details;
    std::weak_ptr<bool> weak_alive = m_isAlive;

    // Post EVERYTHING to platform thread - do NOT access m_sink here!
    PlatformThreadHelper::GetInstance().PostTask(
        [this, code_copy, message_copy, details_copy, weak_alive]() {
          if (weak_alive.expired()) {
            return;
          }
          std::unique_lock<std::mutex> _ul(m_mtx);
          if (m_sink.get()) {
            m_sink.get()->Error(code_copy, message_copy, details_copy);
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
    m_sink.release();
    return nullptr;
  }

 private:
  std::mutex m_mtx;
  std::unique_ptr<EventSink<T>> m_sink;
  std::shared_ptr<bool> m_isAlive;
};
