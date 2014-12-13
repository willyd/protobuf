cmake_minimum_required(VERSION 2.6)

project(protobuf CXX)

get_filename_component(protobuf_source_dir ${protobuf_SOURCE_DIR} DIRECTORY)

option(BUILD_SHARED_LIBS "Build Shared Libraries" OFF)
if (BUILD_SHARED_LIBS)
  add_definitions(-DPROTOBUF_USE_DLLS)
endif (BUILD_SHARED_LIBS)

add_definitions(/wd4244 /wd4267 /wd4018 /wd4355 /wd4800 /wd4251 /wd4996 /wd4146 /wd4305)

include_directories(${protobuf_source_dir}/src ${protobuf_source_dir}/vsprojects)
include_directories(${protobuf_source_dir}/gtest/include ${protobuf_source_dir}/gtest)

include(cmake/libprotobuf-lite.cmake)
include(cmake/libprotobuf.cmake)
include(cmake/libprotoc.cmake)
include(cmake/protoc.cmake)
include(cmake/tests.cmake)
