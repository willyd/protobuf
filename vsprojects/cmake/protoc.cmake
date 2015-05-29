set(protoc_files
  ${protobuf_source_dir}/src/google/protobuf/compiler/main.cc
)

add_executable(protoc ${protoc_files})
target_link_libraries(protoc libprotobuf libprotoc)

set(_target_name protoc)
foreach(_config Debug Release)
    install(TARGETS ${_target_name} DESTINATION vsprojects/${_config} CONFIGURATIONS ${_config})
endforeach()