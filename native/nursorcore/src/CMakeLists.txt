cmake_minimum_required(VERSION 3.10)
project(nursorcore_library VERSION 0.0.1 LANGUAGES C)

# set(nursorcore,"${CMAKE_CURRENT_BINARY_DIR}/Debug/nursor-core-amd64.dll")

# 复制头文件到构建输出目录，以便 ffigen 使用
# file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/nursor-core-amd64.h
#      DESTINATION ${CMAKE_BINARY_DIR}/include)

# 根据平台复制预编译库到构建输出目录
if(WIN32)
  # 原始目标目录
  set(debug_dir "${CMAKE_BINARY_DIR}/Debug")
  set(release_dir "${CMAKE_BINARY_DIR}/Release")

  # 实际运行时的可执行文件所在目录
  set(runner_debug_dir "${CMAKE_BINARY_DIR}/runner/Debug")
  set(runner_release_dir "${CMAKE_BINARY_DIR}/runner/Release")

  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/nursor-core-amd64.dll
       DESTINATION ${debug_dir})
  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/nursor-core-amd64.dll
       DESTINATION ${release_dir})
  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/nursor-core-amd64.dll
       DESTINATION ${runner_debug_dir})
  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/nursor-core-amd64.dll
       DESTINATION ${runner_release_dir})

  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/wintun.dll
       DESTINATION ${debug_dir})
  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/wintun.dll
       DESTINATION ${release_dir})
  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/wintun.dll
       DESTINATION ${runner_debug_dir})
  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../native/wintun.dll
       DESTINATION ${runner_release_dir})

  set(nursorcore_bundled_libraries
    "${debug_dir}/nursor-core-amd64.dll"
    "${release_dir}/nursor-core-amd64.dll"
    "${runner_debug_dir}/nursor-core-amd64.dll"
    "${runner_release_dir}/nursor-core-amd64.dll"

    PARENT_SCOPE)

endif()
