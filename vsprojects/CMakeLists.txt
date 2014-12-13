cmake_minimum_required(VERSION 2.6)

project(protobuf CXX)

get_filename_component(protobuf_source_dir ${protobuf_SOURCE_DIR} DIRECTORY)

option(BUILD_SHARED_LIBS "Build Shared Libraries" OFF)
option(ZLIB "Build with zlib support" OFF)

if (ZLIB)
  set(HAVE_ZLIB 1)
else (ZLIB)
  set(HAVE_ZLIB 0)
endif (ZLIB)
configure_file(config.h.in config.h)

if (BUILD_SHARED_LIBS)
  add_definitions(-DPROTOBUF_USE_DLLS)
endif (BUILD_SHARED_LIBS)

add_definitions(/wd4244 /wd4267 /wd4018 /wd4355 /wd4800 /wd4251 /wd4996 /wd4146 /wd4305)
include_directories(${protobuf_BINARY_DIR})
include_directories(${protobuf_source_dir}/src ${protobuf_source_dir}/vsprojects)
include_directories(${protobuf_source_dir}/gtest/include ${protobuf_source_dir}/gtest)

include(cmake/libprotobuf-lite.cmake)
include(cmake/libprotobuf.cmake)
include(cmake/libprotoc.cmake)
include(cmake/protoc.cmake)
include(cmake/tests.cmake)

if (ZLIB)
  find_path(zlib_include zlib.h ${protobuf_SOURCE_DIR})
  find_library(zlib_lib zdll ${protobuf_SOURCE_DIR})
  include_directories(${zlib_include})
  target_link_libraries(libprotobuf ${zlib_lib})
endif (ZLIB)
