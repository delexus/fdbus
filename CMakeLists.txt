cmake_minimum_required(VERSION 3.10)

set(ANDROID_SDK_ROOT D:/Android/Sdk/)
set(ANDROID_PLATFORM android-21)
set(ANDROID_NATIVE_API_LEVEL android-21)
set(ANDROID_TOOLCHAIN clang)
set(ANDROID_ABI arm64-v8a)
# set(ANDROID_ABI x86_64)

set(CMAKE_BUILD_TYPE Release)

set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 21) # API level
set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
# set(CMAKE_ANDROID_ARCH_ABI x86_64)
set(NDK_VERSION 29.0.14206865)

set(CMAKE_ANDROID_NDK  D:/Android/Sdk/ndk/${NDK_VERSION}/)
set(CMAKE_ANDROID_STL_TYPE c++_shared)

set(CMAKE_C_COMPILE D:/Android/Sdk/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android21-clang)
set(CMAKE_CXX_COMPILE D:/Android/Sdk/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android21-clang++)
set(CMAKE_TOOLCHAIN_FILE D:/Android/Sdk/ndk/${NDK_VERSION}/build/cmake/android.toolchain.cmake)

set(PROTOBUF_ROOT D:/Android/protobuf-android-install/lib/cmake)

project(fdbus-superbuild)

option(FDBUS_BUILD_EXAMPLES "Build protobuf-based example targets" ON)

# Make helper cmake utilities visible to all subdirectories.
set(RULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(PACKAGE_SOURCE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")

add_subdirectory(cmake)

if(FDBUS_BUILD_EXAMPLES)
    add_subdirectory(cmake/pb-example)
endif()
