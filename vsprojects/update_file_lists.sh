#!/bin/sh

# This script copies source file lists from src/Makefile.am to cmake files.

get_variable_value() {
  FILENAME=$1
  VARNAME=$2
  awk "
    BEGIN { start = 0; }
    /^$VARNAME =/ { start = 1; }
    { if (start) { print \$0; } }
    /\\\\\$/ { next; }
    { start = 0; }
  " $FILENAME \
    | sed "s/^$VARNAME =//" \
    | sed "s/[ \\]//g" \
    | grep -v "^\\$" \
    | grep -v "^$" \
    | LC_ALL=C sort | uniq
}

get_source_files() {
  get_variable_value $@ | grep "cc$"
}

get_proto_files() {
  get_variable_value $@ | grep "pb.cc$" | sed "s/pb.cc/proto/"
}

set_variable_value() {
  FILENAME=$1
  VARNAME=$2
  PREFIX=$3
  shift
  shift
  shift
  awk -v values="$*" -v prefix="$PREFIX" "
    BEGIN { start = 0; }
    /^set\\($VARNAME/ {
      start = 1;
      print \$0;
      split(values, vlist, \" \");
      for (i = 1; i <= length(vlist); ++i) {
        printf(\"  %s%s\\n\", prefix, vlist[i]);
      }
      next;
    }
    start && /^\\)/ {
      start = 0;
    }
    !start {
      print \$0;
    }
  " $FILENAME > /tmp/$$
  cp /tmp/$$ $FILENAME
}

sort_files() {
  for FILE in $@; do
    echo $FILE
  done | sort | uniq
}

# Extract file lists from src/Makefile.am
GZHEADERS=$(get_variable_value ../src/Makefile.am GZHEADERS)
HEADERS=$(get_variable_value ../src/Makefile.am nobase_include_HEADERS)
PUBLIC_HEADERS=$(sort_files $GZHEADERS $HEADERS)
LIBPROTOBUF_LITE_SOURCES=$(get_source_files ../src/Makefile.am libprotobuf_lite_la_SOURCES)
LIBPROTOBUF_SOURCES=$(get_source_files ../src/Makefile.am libprotobuf_la_SOURCES)
LIBPROTOC_SOURCES=$(get_source_files ../src/Makefile.am libprotoc_la_SOURCES)
LITE_PROTOS=$(get_proto_files ../src/Makefile.am protoc_lite_outputs)
PROTOS=$(get_proto_files ../src/Makefile.am protoc_outputs)
COMMON_TEST_SOURCES=$(get_source_files ../src/Makefile.am COMMON_TEST_SOURCES)
TEST_SOURCES=$(get_source_files ../src/Makefile.am protobuf_test_SOURCES)
LITE_TEST_SOURCES=$(get_source_files ../src/Makefile.am protobuf_lite_test_SOURCES)

# Replace file lists in cmake files.
COMMON_PREFIX="\${protobuf_source_dir}/src/"
set_variable_value cmake/libprotobuf-lite.cmake libprotobuf_lite_files $COMMON_PREFIX $LIBPROTOBUF_LITE_SOURCES
set_variable_value cmake/libprotobuf.cmake libprotobuf_files $COMMON_PREFIX $LIBPROTOBUF_SOURCES
set_variable_value cmake/libprotoc.cmake libprotoc_files $COMMON_PREFIX $LIBPROTOC_SOURCES
set_variable_value cmake/tests.cmake lite_test_protos "" $LITE_PROTOS
set_variable_value cmake/tests.cmake tests_protos "" $PROTOS
set_variable_value cmake/tests.cmake common_test_files $COMMON_PREFIX $COMMON_TEST_SOURCES
set_variable_value cmake/tests.cmake tests_files $COMMON_PREFIX $TEST_SOURCES
set_variable_value cmake/tests.cmake lite_tests_files $COMMON_PREFIX $LITE_TEST_SOURCES

# Generate extract_includes.bat
for HEADER in $HEADERS; do
  echo $(dirname $HEADER) | sed "s/\\//\\\\/g"
done | sort | uniq | sed "s/^/mkdir include\\\\/" > extract_includes.bat
for HEADER in $HEADERS; do
  WINPATH=$(echo $HEADER | sed 's;/;\\\\;g')
  echo "copy ..\\src\\$WINPATH include\\$WINPATH" >> extract_includes.bat
done
