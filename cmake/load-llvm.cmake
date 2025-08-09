# DON'T USE THIS FILE PLEASE, it's not a good approach to using LLVM.
# Uses llvm-helpers.macro to integrate your target with LLVM support.


# set LLVM base directory
#     https://llvm.org/docs/CMake.html
if(${MAC})
    if(EXISTS "${LLVM_ROOT}/bin/clang")
    else()
        set(LLVM_ROOT /opt/homebrew/opt/llvm)
        if(EXISTS "${LLVM_ROOT}/bin/clang")
        else()
            set(LLVM_ROOT /usr/local/opt/llvm)
        endif()
        if(EXISTS "${LLVM_ROOT}/bin/clang")
            set(LLVM_DIR "${LLVM_ROOT}/share/cmake/modules")
        endif()
    endif()
elseif(${UNIX})
    if(EXISTS "${LLVM_ROOT}/bin/clang")
    else()
        find_program(LLVM_CLANGXX clang++)
        if(LLVM_CLANGXX_FOUND)
        endif()
    endif()
else()
    #set(LLVM_CMAKE_DIR "/usr/share/llvm-3.6/share/llvm/cmake")
    #set(LLVM_CMAKE_DIR "${LLVM_DIR}/share/llvm/cmake")
endif()

if(EXISTS "${LLVM_ROOT}/bin/clang")
else()
    message(FATAL "CANNOT FOUND LLVM, TRY SPECIFY LLVM_ROOT MANUALLY.")
endif()
set(LLVM_CMAKE_DIR "${LLVM_DIR}")
message("LLVM_CMAKE_DIR = ${LLVM_CMAKE_DIR}")


set(LLVM_TARGETS_TO_BUILD X86)
set(LLVM_BUILD_RUNTIME OFF)
set(LLVM_BUILD_TOOLS OFF)

find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")


set(CMAKE_CXX_COMPILER_ENV_VAR "clang++")
set(CMAKE_CXX_FLAGS "-std=c++11")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_MINSIZEREL "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O4 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")

#set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)

include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

include_directories(${LLVM_INCLUDE_DIRS} Debug Release build include src src/Model src/Utils)
message("LLVM_INCLUDE_DIRS = ${LLVM_INCLUDE_DIRS}")

file(GLOB_RECURSE source_files
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Model/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Macro/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Utils/*.cpp)
add_executable(xxv ${source_files}
    ${BISON_MyParser_OUTPUTS}
    ${FLEX_MyScanner_OUTPUTS})

install(TARGETS xxv RUNTIME DESTINATION bin)

# Find the libraries that correspond to the LLVM components
# that we wish to use
llvm_map_components_to_libnames(llvm_libs
    support core irreader executionengine interpreter
    mc mcjit bitwriter x86codegen target)

# Link against LLVM libraries
target_link_libraries(xxv ${llvm_libs})

#add_executable(xxv main.cpp)
#