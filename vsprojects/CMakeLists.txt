cmake_minimum_required(VERSION 2.6)

project(protobuf C CXX)

option(BUILD_SHARED_LIBS "Build Shared Libraries" OFF)
if (MSVC)
  option(ZLIB "Build with zlib support" OFF)
endif (MSVC)

find_package(Threads REQUIRED)
if (CMAKE_USE_PTHREADS_INIT)
  set(HAVE_PTHREAD 1)
else (CMAKE_USE_PTHREADS_INIT)
  set(HAVE_PTHREAD 0)
endif (CMAKE_USE_PTHREADS_INIT)

if (MSVC)
  if (ZLIB)
    set(HAVE_ZLIB 1)
    find_path(ZLIB_INCLUDE_DIRECTORIES zlib.h ${protobuf_SOURCE_DIR})
    find_library(ZLIB_LIBRARIES zdll ${protobuf_SOURCE_DIR})
  else (ZLIB)
    set(HAVE_ZLIB 0)
  endif (ZLIB)
else (MSVC)
  find_package(ZLIB)
  if (ZLIB_FOUND)
    set(HAVE_ZLIB 1)
  else (ZLIB_FOUND)
    set(HAVE_ZLIB 0)
  endif (ZLIB_FOUND)
endif (MSVC)

configure_file(config.h.in config.h)

if (MSVC)
  if (BUILD_SHARED_LIBS)
    add_definitions(-DPROTOBUF_USE_DLLS)
  endif (BUILD_SHARED_LIBS)
  add_definitions(/wd4244 /wd4267 /wd4018 /wd4355 /wd4800 /wd4251 /wd4996 /wd4146 /wd4305)
endif (MSVC)

get_filename_component(protobuf_source_dir ${protobuf_SOURCE_DIR} DIRECTORY)

include_directories(
  ${ZLIB_INCLUDE_DIRECTORIES}
  ${protobuf_BINARY_DIR}
  ${protobuf_source_dir}/gtest/include
  ${protobuf_source_dir}/gtest
  ${protobuf_source_dir}/src)

include(cmake/libprotobuf-lite.cmake)
include(cmake/libprotobuf.cmake)
include(cmake/libprotoc.cmake)
include(cmake/protoc.cmake)
include(cmake/tests.cmake)
