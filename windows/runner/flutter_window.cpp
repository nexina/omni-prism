#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  window_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "omni_prism/window",
          &flutter::StandardMethodCodec::GetInstance());

  window_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "setFullScreen") {
          if (call.arguments()) {
            bool full_screen = false;
            if (std::holds_alternative<bool>(*call.arguments())) {
              full_screen = std::get<bool>(*call.arguments());
            } else if (std::holds_alternative<int32_t>(*call.arguments())) {
              full_screen = std::get<int32_t>(*call.arguments()) != 0;
            } else if (std::holds_alternative<int64_t>(*call.arguments())) {
              full_screen = std::get<int64_t>(*call.arguments()) != 0;
            } else {
              result->Error("BAD_ARGS", "Expected a boolean argument for setFullScreen");
              return;
            }
            SetFullScreen(full_screen);
            result->Success();
          } else {
            result->Error("BAD_ARGS", "Arguments cannot be null for setFullScreen");
          }
        } else if (call.method_name() == "close") {
          HWND hwnd = GetHandle();
          if (hwnd) {
            PostMessage(hwnd, WM_CLOSE, 0, 0);
          }
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (window_channel_) {
    window_channel_ = nullptr;
  }

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::SetFullScreen(bool fullscreen) {
  if (fullscreen == is_fullscreen_) {
    return;
  }
  HWND hwnd = GetHandle();
  if (!hwnd) {
    return;
  }

  DWORD style = GetWindowLong(hwnd, GWL_STYLE);
  if (fullscreen) {
    MONITORINFO mi = {sizeof(mi)};
    saved_window_placement_.length = sizeof(saved_window_placement_);
    if (GetWindowPlacement(hwnd, &saved_window_placement_) &&
        GetMonitorInfo(MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST), &mi)) {
      is_fullscreen_ = true;
      SetWindowLong(hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
      SetWindowPos(hwnd, HWND_TOP,
                   mi.rcMonitor.left, mi.rcMonitor.top,
                   mi.rcMonitor.right - mi.rcMonitor.left,
                   mi.rcMonitor.bottom - mi.rcMonitor.top,
                   SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
    }
  } else {
    is_fullscreen_ = false;
    SetWindowLong(hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
    if (saved_window_placement_.showCmd == SW_SHOWMINIMIZED) {
      saved_window_placement_.showCmd = SW_SHOWNORMAL;
    }
    SetWindowPlacement(hwnd, &saved_window_placement_);
    SetWindowPos(hwnd, nullptr, 0, 0, 0, 0,
                 SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER |
                 SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
  }
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_GETMINMAXINFO:
      if (is_fullscreen_) {
        auto min_max_info = reinterpret_cast<MINMAXINFO*>(lparam);
        HMONITOR monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
        MONITORINFO mi = {sizeof(mi)};
        if (GetMonitorInfo(monitor, &mi)) {
          min_max_info->ptMaxPosition.x = mi.rcMonitor.left;
          min_max_info->ptMaxPosition.y = mi.rcMonitor.top;
          min_max_info->ptMaxSize.x = mi.rcMonitor.right - mi.rcMonitor.left;
          min_max_info->ptMaxSize.y = mi.rcMonitor.bottom - mi.rcMonitor.top;
          min_max_info->ptMaxTrackSize.x = min_max_info->ptMaxSize.x;
          min_max_info->ptMaxTrackSize.y = min_max_info->ptMaxSize.y;
          return 0;
        }
      }
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
