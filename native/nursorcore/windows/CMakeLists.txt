# CMake 版本要求
cmake_minimum_required(VERSION 3.14)

# 项目名称，请确保这里是你的插件名称
set(PROJECT_NAME "nursorcore")
project(${PROJECT_NAME} LANGUAGES CXX)

# 显式启用现代 CMake 行为，避免警告
cmake_policy(VERSION 3.14...3.25)

# 这个值用于生成此插件的构建，所以它不能被更改
set(PLUGIN_NAME "${PROJECT_NAME}_plugin") # PLUGIN_NAME 应该基于 PROJECT_NAME

# 将你的 C++ 源文件添加到插件源代码列表
list(APPEND PLUGIN_SOURCES
  "nursorcore_plugin.cpp"        # <-- 你的插件主实现文件
  "nursorcore_plugin.h"          # <-- 你的插件头文件
  "nursorcore_plugin_c_api.cpp"  # <-- 如果这是你 FFI 相关的C API实现，也需要编译
)

# 定义插件库目标。它的名称不能改变。
add_library(${PLUGIN_NAME} SHARED
  # 你可能会有一个公开的 C API 头文件
  # "include/${PROJECT_NAME}/${PROJECT_NAME}_c_api.h"
  ${PLUGIN_SOURCES}
)

# 应用标准构建设置，这些设置在应用级别的 CMakeLists.txt 中配置。
# 对于需要完全控制构建设置的插件，可以删除此项。
apply_standard_settings(${PLUGIN_NAME})

# 默认隐藏符号，以减少插件之间意外冲突的可能性。
# 不应删除此项；任何应导出的符号都应使用 FLUTTER_PLUGIN_EXPORT 宏明确导出。
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# 源文件包含目录和库依赖项。在这里添加任何插件特定的依赖项。
# 这是解决 'flutter/method_channel.h' 找不到问题的关键！
target_include_directories(${PLUGIN_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/include" # 如果你有公开头文件放在 include 子目录
  "${FLUTTER_PLUGIN_IMPL_DIR}/include"
  "${FLUTTER_ROOT}/packages/flutter_tools/lib/src/windows/flutter_desktop_embedding/include"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# --- 你的预编译 DLL 文件复制逻辑 ---
# 假设你的 `nursor-core-amd64.dll` 位于插件根目录下的 `native` 文件夹中。
set(NURSORCORE_DLL_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/../native/nursor-core-amd64.dll")
set(WINTUN_DLL_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/../native/wintun.dll")
set(WINTUN_DLL_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/../native/ca.pem")

if(WIN32)
  set(debug_output_dir "${CMAKE_BINARY_DIR}/Debug")
  set(release_output_dir "${CMAKE_BINARY_DIR}/Release")
  set(profile_output_dir "${CMAKE_BINARY_DIR}/Profile")

  file(MAKE_DIRECTORY "${debug_output_dir}")
  file(MAKE_DIRECTORY "${release_output_dir}")
  file(MAKE_DIRECTORY "${profile_output_dir}")

  file(COPY "${NURSORCORE_DLL_SOURCE}" DESTINATION "${debug_output_dir}")
  file(COPY "${NURSORCORE_DLL_SOURCE}" DESTINATION "${release_output_dir}")
  file(COPY "${NURSORCORE_DLL_SOURCE}" DESTINATION "${profile_output_dir}")
  file(COPY "${NURSORCORE_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Debug")
  file(COPY "${NURSORCORE_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Release")
  file(COPY "${NURSORCORE_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Profile")

  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${debug_output_dir}")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${release_output_dir}")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${profile_output_dir}")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Debug")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Release")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Profile")

  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${debug_output_dir}")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${release_output_dir}")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${profile_output_dir}")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Debug")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Release")
  file(COPY "${WINTUN_DLL_SOURCE}" DESTINATION "${CMAKE_BINARY_DIR}/runner/Profile")

  # 告诉 Flutter 将这些 DLL 打包到最终应用中
  set(${PROJECT_NAME}_bundled_libraries
    "${debug_output_dir}/nursor-core-amd64.dll"
    "${release_output_dir}/nursor-core-amd64.dll"
    "${profile_output_dir}/nursor-core-amd64.dll"
    "${CMAKE_BINARY_DIR}/runner/Debug/nursor-core-amd64.dll"
    "${CMAKE_BINARY_DIR}/runner/Release/nursor-core-amd64.dll"
    "${CMAKE_BINARY_DIR}/runner/Profile/nursor-core-amd64.dll"
    PARENT_SCOPE
  )
else()
  set(${PROJECT_NAME}_bundled_libraries "" PARENT_SCOPE)
endif()

# --- 测试部分 (如果不需要，删除或注释掉) ---
# if (${include_${PROJECT_NAME}_tests})
# ... (从原始模板中复制的测试代码) ...
# endif()