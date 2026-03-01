#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/task_runner.h>

#include <mutex>
#include <memory>

using namespace flutter;

template <typename T = EncodableValue>
class EventStreamHandler : public StreamHandler<T> {
 public:
  EventStreamHandler(TaskRunner* task_runner) : m_task_runner(task_runner) {}

  virtual ~EventStreamHandler() = default;

  void Success(std::unique_ptr<T> _data) {
    std::unique_lock<std::mutex> _ul(m_mtx);
    m_task_runner->PostTask([this, data = std::move(_data)]() {
      std::unique_lock<std::mutex> _inner_ul(m_mtx);
      if (m_sink) {
        m_sink->Success(*data);
      }
    });
  }

  void Error(const std::string& error_code,
             const std::string& error_message,
             const T& error_details) {
    std::unique_lock<std::mutex> _ul(m_mtx);
    m_task_runner->PostTask([this, error_code, error_message, error_details]() {
      std::unique_lock<std::mutex> _inner_ul(m_mtx);
      if (m_sink) {
        m_sink->Error(error_code, error_message, error_details);
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
  TaskRunner* m_task_runner;
  std::mutex m_mtx;
  std::unique_ptr<EventSink<T>> m_sink;
};
