#pragma once

#include <windows.h>
#include <functional>
#include <queue>
#include <mutex>
#include <memory>
#include <atomic>

namespace audioplayers {

// Custom window message for dispatching callbacks to platform thread
#define WM_AUDIOPLAYERS_CALLBACK (WM_USER + 100)

/**
 * PlatformThreadHandler - ensures callbacks are executed on the Flutter platform thread.
 * 
 * This class creates a hidden window to receive Windows messages, allowing callbacks
 * from MTA threads (MediaFoundation) to be safely dispatched to the platform thread.
 * 
 * Usage:
 *   1. Initialize once during plugin registration: PlatformThreadHandler::Initialize()
 *   2. Use RunOnPlatformThread() from any thread to execute code on platform thread
 *   3. Shutdown when plugin is destroyed: PlatformThreadHandler::Shutdown()
 */
class PlatformThreadHandler {
 public:
  using Callback = std::function<void()>;

  /**
   * Initialize the handler. Must be called from the platform thread.
   * Creates a hidden window for message dispatching.
   */
  static bool Initialize() {
    if (s_instance) {
      return true;  // Already initialized
    }
    
    s_instance = std::make_unique<PlatformThreadHandler>();
    return s_instance->CreateMessageWindow();
  }

  /**
   * Shutdown and cleanup. Should be called when plugin is destroyed.
   */
  static void Shutdown() {
    if (s_instance) {
      s_instance->DestroyMessageWindow();
      s_instance.reset();
    }
  }

  /**
   * Check if the handler is initialized.
   */
  static bool IsInitialized() {
    return s_instance != nullptr && s_instance->m_hwnd != nullptr;
  }

  /**
   * Execute a callback on the platform thread.
   * If already on the platform thread, executes immediately.
   * Otherwise, posts a message to the hidden window.
   * 
   * @param callback The function to execute on the platform thread.
   * @param synchronous If true, blocks until callback completes. Default is false (async).
   */
  static void RunOnPlatformThread(Callback callback, bool synchronous = false) {
    if (!s_instance || !s_instance->m_hwnd) {
      // Fallback: execute directly (not ideal, but prevents crash)
      // Log warning in debug builds
#ifdef _DEBUG
      OutputDebugStringA("[AudioPlayers] Warning: PlatformThreadHandler not initialized, executing callback directly\n");
#endif
      callback();
      return;
    }

    // Check if we're already on the platform thread
    if (GetCurrentThreadId() == s_instance->m_platformThreadId) {
      callback();
      return;
    }

    // Dispatch to platform thread via message queue
    s_instance->PostCallback(std::move(callback), synchronous);
  }

  /**
   * Get the platform thread ID.
   */
  static DWORD GetPlatformThreadId() {
    return s_instance ? s_instance->m_platformThreadId : 0;
  }

 private:
  PlatformThreadHandler() 
      : m_hwnd(nullptr), 
        m_platformThreadId(GetCurrentThreadId()) {}

  ~PlatformThreadHandler() {
    DestroyMessageWindow();
  }

  // Non-copyable
  PlatformThreadHandler(const PlatformThreadHandler&) = delete;
  PlatformThreadHandler& operator=(const PlatformThreadHandler&) = delete;

  bool CreateMessageWindow() {
    // Register window class
    WNDCLASSEXW wc = {};
    wc.cbSize = sizeof(WNDCLASSEXW);
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = GetModuleHandle(nullptr);
    wc.lpszClassName = L"AudioPlayersMessageWindow";

    if (!RegisterClassExW(&wc)) {
      DWORD error = GetLastError();
      if (error != ERROR_CLASS_ALREADY_EXISTS) {
        return false;
      }
    }

    // Create hidden message-only window
    m_hwnd = CreateWindowExW(
        0,
        L"AudioPlayersMessageWindow",
        L"",
        0,
        0, 0, 0, 0,
        HWND_MESSAGE,  // Message-only window
        nullptr,
        GetModuleHandle(nullptr),
        this  // Pass this pointer for use in WindowProc
    );

    if (!m_hwnd) {
      return false;
    }

    // Store this pointer in window user data
    SetWindowLongPtrW(m_hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(this));

    return true;
  }

  void DestroyMessageWindow() {
    if (m_hwnd) {
      DestroyWindow(m_hwnd);
      m_hwnd = nullptr;
    }
  }

  void PostCallback(Callback callback, bool synchronous) {
    // Create callback wrapper on heap
    auto* callbackPtr = new CallbackWrapper{std::move(callback), synchronous};
    
    if (synchronous) {
      // Use SendMessage for synchronous execution (blocks until processed)
      SendMessageW(m_hwnd, WM_AUDIOPLAYERS_CALLBACK, 
                   reinterpret_cast<WPARAM>(callbackPtr), 0);
    } else {
      // Use PostMessage for asynchronous execution
      if (!PostMessageW(m_hwnd, WM_AUDIOPLAYERS_CALLBACK, 
                        reinterpret_cast<WPARAM>(callbackPtr), 0)) {
        // PostMessage failed, cleanup and execute directly as fallback
        delete callbackPtr;
#ifdef _DEBUG
        OutputDebugStringA("[AudioPlayers] Warning: PostMessage failed\n");
#endif
      }
    }
  }

  static LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (msg == WM_AUDIOPLAYERS_CALLBACK) {
      auto* wrapper = reinterpret_cast<CallbackWrapper*>(wParam);
      if (wrapper) {
        try {
          wrapper->callback();
        } catch (...) {
#ifdef _DEBUG
          OutputDebugStringA("[AudioPlayers] Exception in callback\n");
#endif
        }
        delete wrapper;
      }
      return 0;
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam);
  }

  struct CallbackWrapper {
    Callback callback;
    bool synchronous;
  };

  HWND m_hwnd;
  DWORD m_platformThreadId;

  static inline std::unique_ptr<PlatformThreadHandler> s_instance;
};

}  // namespace audioplayers
