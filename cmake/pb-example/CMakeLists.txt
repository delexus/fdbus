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

set(PROTOBUF_ROOT D:/Android/protobuf-android-install)
set(PROTOBUF_INCLUDE_DIR D:/Android/protobuf-android-install/include)

project(fdbus-example C CXX)

option(fdbus_LOG_TO_STDOUT "Log to stdout" OFF)
option(fdbus_ENABLE_LOG "Enable log" ON)
option(fdbus_NORMAL_TEST "build test for normal lib test" ON)
option(fdbus_CLIB_TEST "build test for clib" ON)
option(fdbus_SEC_USING_SSL "Using SSL for security" OFF)
option(fdbus_LINK_PTHREAD_LIB "specify -lpthread to link" ON)

# Path to a protobuf installation that provides both headers and libraries.
# This is useful for cross-compiling, such as Android builds, where the
# default system search paths do not contain protobuf artifacts.
set(PROTOBUF_ROOT "" CACHE PATH "Root directory of protobuf installation")

find_path(
    PROTOBUF_INCLUDE_DIR
    NAMES
        google/protobuf/runtime_version.h
        google/protobuf/descriptor.h
    PATHS ${PROTOBUF_ROOT}
    PATH_SUFFIXES include
)

# Try to discover protobuf via the CMake config files when no root hint is
# provided. If the config is available, reuse the include and library hints
# from the package.
if(NOT PROTOBUF_INCLUDE_DIR)
    find_package(Protobuf QUIET)
    if(Protobuf_INCLUDE_DIRS)
        set(PROTOBUF_INCLUDE_DIR ${Protobuf_INCLUDE_DIRS})
    endif()
endif()

if(NOT PROTOBUF_INCLUDE_DIR)
    message(FATAL_ERROR "Protobuf headers not found. Set PROTOBUF_ROOT to a valid installation or ensure Protobuf is discoverable.")
endif()

find_library(
    PROTOBUF_LIBRARY
    NAMES protobuf libprotobuf
    PATHS ${PROTOBUF_ROOT}
    PATH_SUFFIXES lib
)

if(NOT PROTOBUF_LIBRARY AND Protobuf_LIBRARIES)
    set(PROTOBUF_LIBRARY ${Protobuf_LIBRARIES})
endif()

if (fdbus_LOG_TO_STDOUT)
    add_definitions("-DCONFIG_LOG_TO_STDOUT")
endif()
if (fdbus_ENABLE_LOG)
    add_definitions("-DCONFIG_DEBUG_LOG")
endif()

if (MSVC)
    add_definitions("-D__WIN32__")
elseif(fdbus_ANDROID)
    add_definitions("-D__LINUX__")
else()
    if(CMAKE_COMPILER_IS_GNUCXX)
        set(CMAKE_CXX_FLAGS "-std=gnu++11 -Wall ${CMAKE_CXX_FLAGS}")
    endif()
    #add_compile_options(-g -O0)
    add_definitions("-D__LINUX__")
endif()

if(DEFINED RULE_DIR)
    include(${RULE_DIR}/rule_base.cmake)
else()
    set(RULE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    include(rule_base.cmake)
endif()
add_definitions("-DCONFIG_PROTOBUF_4_0_X")

if (NOT DEFINED PACKAGE_SOURCE_ROOT)
    get_filename_component(PACKAGE_SOURCE_ROOT ${CMAKE_CURRENT_SOURCE_DIR} PATH)
    get_filename_component(PACKAGE_SOURCE_ROOT ${PACKAGE_SOURCE_ROOT} PATH)
endif()

set(IDL_GEN_ROOT ${CMAKE_CURRENT_BINARY_DIR})

include_directories(
    ${PACKAGE_SOURCE_ROOT}/public
    ${IDL_GEN_ROOT}
    ${PROTOBUF_INCLUDE_DIR}
    )
link_libraries(fdbus)

if (MSVC)
    foreach(flag_var
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
        if(${flag_var} MATCHES "/MD")
            string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
        endif(${flag_var} MATCHES "/MD")
    endforeach(flag_var)

    if (PROTOBUF_LIBRARY)
        link_libraries(${PROTOBUF_LIBRARY})
    else()
        link_libraries(libprotobufd)
    endif()
    link_libraries(ws2_32.lib)
    if (fdbus_SEC_USING_SSL)
        link_libraries(libssl libcrypto)
    endif()
    set(LIB_BUILD_TYPE "STATIC")
else()
    if (PROTOBUF_LIBRARY)
        link_libraries(${PROTOBUF_LIBRARY})
    else()
        link_libraries(protobuf)
    endif()
    if (fdbus_LINK_PTHREAD_LIB)
        link_libraries(pthread)
    endif()
    set(LIB_BUILD_TYPE "SHARED")
endif()

if (fdbus_LINK_SOCKET_LIB)
    link_libraries(socket)
endif()

if (fdbus_NORMAL_TEST)
    include(example.cmake)
    include(idl-gen.cmake)
endif()

if (fdbus_CLIB_TEST)
    include(clib-test.cmake)
endif()

#set( CMAKE_VERBOSE_MAKEFILE on )

print_variable(fdbus_ENABLE_LOG)
print_variable(fdbus_LOG_TO_STDOUT)
print_variable(fdbus_ANDROID)
print_variable(fdbus_CLIB_TEST)
