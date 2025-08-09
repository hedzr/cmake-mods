set(CMAKE_SCRIPTS_DIR ${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS})
get_filename_component(CMAKE_ROOT_DIR ${CMAKE_SCRIPTS_DIR} DIRECTORY)

# debug_print_value(CMAKE_ROOT_DIR)
# debug_print_value(CMAKE_SCRIPTS_DIR)

# debug_print_value(LIBRARY_OUTPUT_PATH)
# debug_print_value(ARCHIVE_OUTPUT_PATH)
# debug_print_value(CMAKE_RUNTIME_OUTPUT_DIRECTORY)

# set(EXECUTABLE_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/bin")
# set(LIBRARY_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/bin/lib")
# set(ARCHIVE_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/bin/lib")
# #set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test)
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")
#
# #link_directories(BEFORE ${LIBRARY_OUTPUT_PATH} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
if(${USE_DEBUG})
    # set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/debug)
    get_target_property(_exe_outdir ${PROJECT_NAME} RUNTIME_OUTPUT_DIRECTORY)
    if(NOT _exe_outdir)
        get_target_property(_exe_outdir ${PROJECT_NAME} RUNTIME_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE})
    endif()
    # debug_print_value(_exe_outdir)
else()
    # if(is_multi_config)
    #     set(EXECUTABLE_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/bin")
    # else()
    #     set(EXECUTABLE_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/bin/${CMAKE_BUILD_NAME}")
    # endif()
    # set(LIBRARY_OUTPUT_PATH "${EXECUTABLE_OUTPUT_PATH}/lib")
    # set(ARCHIVE_OUTPUT_PATH "${EXECUTABLE_OUTPUT_PATH}/lib")
endif()
set(CMAKE_GENERATED_DIR "${CMAKE_BINARY_DIR}/generated") # Note that CMAKE_GENERATED_DIR is NOT a cmake builtin variable.
set(CMAKE_BIN_OUTPUT_DIR "${CMAKE_ROOT_DIR}/bin") # specially for debug/bin/* # Note that CMAKE_BIN_OUTPUT_DIR is NOT a cmake builtin variable.
if(is_multi_config)
    set(EXECUTABLE_OUTPUT_PATH "${CMAKE_BIN_OUTPUT_DIR}")
    set(LIBRARY_OUTPUT_PATH "${CMAKE_BIN_OUTPUT_DIR}/lib")
    set(ARCHIVE_OUTPUT_PATH "${CMAKE_BIN_OUTPUT_DIR}/lib")
    set(CMAKE_SHARE_OUTPUT_DIR "${CMAKE_BIN_OUTPUT_DIR}/share") # Note that CMAKE_SHARE_OUTPUT_DIR is NOT a cmake builtin variable.
else()
    set(EXECUTABLE_OUTPUT_PATH "${CMAKE_BIN_OUTPUT_DIR}/${CMAKE_BUILD_TYPE}/bin")
    set(LIBRARY_OUTPUT_PATH "${CMAKE_BIN_OUTPUT_DIR}/${CMAKE_BUILD_TYPE}/lib")
    set(ARCHIVE_OUTPUT_PATH "${CMAKE_BIN_OUTPUT_DIR}/${CMAKE_BUILD_TYPE}/lib")
    set(CMAKE_SHARE_OUTPUT_DIR "${CMAKE_BIN_OUTPUT_DIR}/${CMAKE_BUILD_TYPE}/share") # Note that CMAKE_SHARE_OUTPUT_DIR is NOT a cmake builtin variable.
endif()

# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${EXECUTABLE_OUTPUT_PATH}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${ARCHIVE_OUTPUT_PATH}")

mark_as_advanced(CMAKE_GENERATED_DIR)
mark_as_advanced(CMAKE_SHARE_OUTPUT_PATH)
mark_as_advanced(CMAKE_BIN_OUTPUT_PATH)
mark_as_advanced(CMAKE_SCRIPTS_DIR)
mark_as_advanced(CMAKE_ROOT_DIR)

# message(STATUS "            CMAKE_CACHEFILE_DIR = ${CMAKE_CACHEFILE_DIR} ...")


message(STATUS "   ./cmake/target-dirs.cmake:41 : ")
message(STATUS "           CMAKE_BIN_OUTPUT_DIR = ${CMAKE_BIN_OUTPUT_DIR}")
message(STATUS "         EXECUTABLE_OUTPUT_PATH = ${EXECUTABLE_OUTPUT_PATH} / = CMAKE_RUNTIME_OUTPUT_DIRECTORY ...")
message(STATUS "            LIBRARY_OUTPUT_PATH = ${LIBRARY_OUTPUT_PATH} / = ARCHIVE_OUTPUT_PATH ...")
message(STATUS "         CMAKE_SHARE_OUTPUT_DIR = ${CMAKE_SHARE_OUTPUT_DIR}")
# message(STATUS "            ARCHIVE_OUTPUT_PATH = ${ARCHIVE_OUTPUT_PATH} ...")
# message(STATUS " CMAKE_RUNTIME_OUTPUT_DIRECTORY = ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ...")
# message(STATUS "               CMAKE_SOURCE_DIR = ${CMAKE_SOURCE_DIR}")
# message(STATUS "               CMAKE_BINARY_DIR = ${CMAKE_BINARY_DIR}")
message(STATUS "                            And,")
message(STATUS "              CMAKE_SCRIPTS_DIR = ${CMAKE_SCRIPTS_DIR}")
message(STATUS "                 CMAKE_ROOT_DIR = ${CMAKE_ROOT_DIR}")
message(STATUS "            CMAKE_GENERATED_DIR = ${CMAKE_GENERATED_DIR}")

debug_print_value(CMAKE_SHARED_LIBRARY_PREFIX)
debug_print_value(CMAKE_SHARED_LIBRARY_SUFFIX)
debug_print_value(CMAKE_SHARED_LIBRARY_ARCHIVE_SUFFIX)
debug_print_value(CMAKE_EXTRA_SHARED_LIBRARY_SUFFIXES)
debug_print_value(CMAKE_STATIC_LIBRARY_PREFIX)
debug_print_value(CMAKE_STATIC_LIBRARY_SUFFIX)
# debug_print_value(CMAKE_EXTRA_STATIC_LIBRARY_SUFFIXES)
debug_print_value(CMAKE_EXECUTABLE_SUFFIX)
# CMAKE_SHARED_MODULE_PREFIX
# CMAKE_SHARED_MODULE_SUFFIX

# set(EXECUTABLE_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/bin")
# set(LIBRARY_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/sm-lib")
# link_directories(BEFORE "${CMAKE_SOURCE_DIR}/sm-lib")

# set(V alpha beta gamma)
# message(${V})
#
# foreach(i ${V})
# message(${i})
# endforeach()

# create symbolic link at `<project-root>/bin` to target executable file
macro(target_add_post_copy_action target)
    # set_target_properties(${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ~/.local/bin)
    add_custom_command(TARGET ${target}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E create_symlink $<TARGET_FILE:${target}> ${CMAKE_BIN_OUTPUT_DIR}/${target}
    )
endmacro()
