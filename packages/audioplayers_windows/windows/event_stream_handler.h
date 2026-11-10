#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter_windows.h>

#include <functional>
#include <memory>
#include <mutex>

using namespace flutter;

template <typename T = EncodableValue>
class EventStreamHandler : public StreamHandler<T> {
 public:
  explicit EventStreamHandler(PluginRegistrarWindows* registrar)
      : registrar(registrar) {}

  virtual ~EventStreamHandler() = default;

  void Success(std::unique_ptr<T> _data) {
    // Use a shared_ptr so the value can be captured by a copyable
    // std::function when the task has to be posted to the platform thread.
    std::shared_ptr<T> data = std::move(_data);
    RunOnPlatformThread([this, data]() {
      std::unique_lock<std::mutex> _ul(m_mtx);
      if (m_sink) {
        m_sink->Success(*data);
      }
    });
  }

  void Error(const std::string& error_code,
             const std::string& error_message,
             const T* error_details = nullptr) {
    // Copy the details eagerly: `error_details` may point to a value (e.g. a
    // temporary in the caller) that is no longer alive by the time a posted
    // task runs on the platform thread.
    std::shared_ptr<T> details =
        error_details != nullptr ? std::make_shared<T>(*error_details) : nullptr;
    RunOnPlatformThread([this, error_code, error_message, details]() {
      std::unique_lock<std::mutex> _ul(m_mtx);
      if (m_sink) {
        if (details) {
          m_sink->Error(error_code, error_message, *details);
        } else {
          m_sink->Error(error_code, error_message);
        }
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
    m_sink.reset();
    return nullptr;
  }

 private:
  // Runs `task` immediately if already on the platform thread; otherwise
  // posts it to the platform thread. `Success`/`Error` may be called from
  // any thread, but the event sink must only ever be touched on the
  // platform thread.
  void RunOnPlatformThread(std::function<void()> task) {
    if (registrar->IsPlatformThread()) {
      task();
    } else {
      registrar->PostPlatformThreadTask(std::move(task));
    }
  }

  PluginRegistrarWindows* registrar;
  std::mutex m_mtx;
  std::unique_ptr<EventSink<T>> m_sink;
};
