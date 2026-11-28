# See: https://github.com/flutter/flutter/blob/bc0ec85717de14677a0253814faead368ac2abe8/packages/flutter_tools/templates/app_shared/linux.tmpl/CMakeLists.txt.tmpl
cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "audioplayers_linux")
project(${PROJECT_NAME} LANGUAGES CXX)
include(FetchContent)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

list(APPEND PLUGIN_SOURCES
  "audioplayers_linux_plugin.cc"
  "audio_player.h"
  "audio_player.cc"
)

add_library(${PLUGIN_NAME} SHARED
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_17)

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
pkg_search_module(GLIB REQUIRED glib-2.0)
pkg_check_modules(GSTREAMER REQUIRED gstreamer-1.0)
pkg_check_modules(GST_APP REQUIRED gstreamer-app-1.0)
pkg_check_modules(GSTREAMER-AUDIO REQUIRED gstreamer-audio-1.0)
include_directories(
  ${GLIB_INCLUDE_DIRS}
  ${GSTREAMER_INCLUDE_DIRS}
  ${GSTREAMER-APP_INCLUDE_DIRS}
  ${GSTREAMER-AUDIO_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}
)
link_directories(
  ${GLIB_LIBRARY_DIRS}
  ${GSTREAMER_LIBRARY_DIRS}
  ${GSTREAMER-APP_LIBRARY_DIRS}
  ${GSTREAMER-AUDIO_LIBRARY_DIRS}
)
target_include_directories(${PLUGIN_NAME} PRIVATE ${GST_INCLUDE_DIRS} ${GLIB_INCLUDE_DIRS})
target_link_libraries(${PLUGIN_NAME} PRIVATE ${GST_APP_LIBRARIES} ${GLIB_LIBRARIES})

target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# === Tests ===
# These unit tests can be run from a terminal after building the example:
# build/linux/x64/debug/plugins/audioplayers_linux/audioplayers_linux_test

# Only enable test builds when building the example (which sets this variable)
# so that plugin clients aren't building the tests.
if (${include_${PROJECT_NAME}_tests})
  set(TEST_RUNNER "${PROJECT_NAME}_test")
  enable_testing()

  # Add the Google Test dependency.
  FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.17.0.zip
  )
  # Prevent overriding the parent project's compiler/linker settings
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  # Disable install commands for gtest so it doesn't end up in the bundle.
  set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
  FetchContent_MakeAvailable(googletest)

  # The plugin's exported API is not very useful for unit testing, so build the
  # sources directly into the test binary rather than using the shared library.
  add_executable(${TEST_RUNNER}
    test/audio_player_test.cc
    ${PLUGIN_SOURCES}
  )
  apply_standard_settings(${TEST_RUNNER})
  target_compile_features(${TEST_RUNNER} PRIVATE cxx_std_17)
  target_link_libraries(${TEST_RUNNER} PRIVATE ${GST_APP_LIBRARIES})
  target_link_libraries(${TEST_RUNNER} PRIVATE flutter)
  target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::GTK)
  target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main)

  # Enable automatic test discovery.
  include(GoogleTest)
  gtest_discover_tests(${TEST_RUNNER})
endif()

# List of absolute paths to libraries that should be bundled with the plugin
set(audioplayers_linux_bundled_libraries
  ""
  PARENT_SCOPE
)
