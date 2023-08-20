#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>

#include <mutex>

using namespace flutter;

template <typename T = EncodableValue>
class EventStreamHandler : public StreamHandler<T> {
 public:
  EventStreamHandler() = default;

  virtual ~EventStreamHandler() = default;

  void Success(std::unique_ptr<T> _data) {
    std::unique_lock<std::mutex> _ul(m_mtx);
    if (m_sink.get())
      m_sink.get()->Success(*_data.get());
  }

  void Error(const std::string& error_code,
             const std::string& error_message,
             const T& error_details) {
    std::unique_lock<std::mutex> _ul(m_mtx);
    if (m_sink.get())
      m_sink.get()->Error(error_code, error_message, error_details);
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
};