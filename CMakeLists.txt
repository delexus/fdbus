cmake_minimum_required(VERSION 3.10)
project(fdbus-superbuild)

option(FDBUS_BUILD_EXAMPLES "Build protobuf-based example targets" ON)

# Make helper cmake utilities visible to all subdirectories.
set(RULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(PACKAGE_SOURCE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")

add_subdirectory(cmake)

if(FDBUS_BUILD_EXAMPLES)
    add_subdirectory(cmake/pb-example)
endif()
