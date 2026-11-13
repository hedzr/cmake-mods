
set(CMAKE_CXX_STANDARD 23) # or 20
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF) # Optional: enforce strict C++23
message(NOTICE "......................................")




# Enable the experimental C++ standard library module support in CMake
# The exact GUID value for CMAKE_EXPERIMENTAL_CXX_IMPORT_STD may change
# with experimental CMake versions. The one below works with the 3.30
# release.
#
# for CMake 4.2.1, extract this uuid from
#   https://github.com/Kitware/CMake/blob/v3.30/Help/dev/experimental.rst
#   https://github.com/Kitware/CMake/blob/v4.1.2/Help/dev/experimental.rst
#   https://github.com/Kitware/CMake/blob/v4.2.1/Help/dev/experimental.rst
#   https://github.com/Kitware/CMake/blob/v4.3.0/Help/dev/experimental.rst
#   https://github.com/Kitware/CMake/blob/v4.4.0/Help/dev/experimental.rst
#   https://github.com/Kitware/CMake/blob/v4.5.0/Help/dev/experimental.rst
# both cmake 4.x using the same uuid for experimental std import:
if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.5)
    # 1. CMake/Help/release/4.5.rst
    #    https://github.com/Kitware/CMake/blob/1cb197d4cd44b85555b48b22e879533e634f9d3e/Help/release/4.5.rst#L111
    #    import std is now available for all C++ 20 and later code with :prop_tgt:`CXX_SCAN_FOR_MODULES` enabled.
    #
    # 2, CMake/Help/manual/cmake-cxxmodules.7.rst
    #    https://github.com/Kitware/CMake/blob/1cb197d4cd44b85555b48b22e879533e634f9d3e/Help/manual/cmake-cxxmodules.7.rst#L87
    #    import std Support
    #
    # set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "f35a9ac6-8463-4d38-8eec-5d6008153e7d")
    # set(CMAKE_EXPERIMENTAL_SYCL "c0d1fb10-2ece-420e-9d29-7d7f2b300f25")
    # set(CMAKE_EXPERIMENTAL_RUST "b6fdddce-bf66-41a5-bc5f-077f6fa4d2a1")
    # set(CMAKE_EXPERIMENTAL_EXPORT_BUILD_DATABASE "70ef007e-b743-492d-9407-e35eeac03a40")
elseif(CMAKE_VERSION VERSION_GREATER_EQUAL 4.4)
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "f35a9ac6-8463-4d38-8eec-5d6008153e7d")
elseif(CMAKE_VERSION VERSION_GREATER_EQUAL 4.3)
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "451f2fe2-a8a2-47c3-bc32-94786d8fc91b")
elseif(CMAKE_VERSION VERSION_GREATER_EQUAL 4.2)
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
elseif(CMAKE_VERSION VERSION_GREATER_EQUAL 3.30)
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "0e5b6991-d74f-4b3d-a41c-cf096e0b2508")
else()
    message(FATAL_ERROR " .   CMake is too old to support cxx-modules (at least 3.30 needed).")
endif()
message(NOTICE " .   Using CMAKE_EXPERIMENTAL_CXX_IMPORT_STD = ${CMAKE_EXPERIMENTAL_CXX_IMPORT_STD}")
set(CMAKE_EXPERIMENTAL_CXX_MODULE_DYNDEP ON)
# # Tell CMake that you explicitly want 'import std' for all subsequent targets by default.
#debug_print_value(CMAKE_VERSION)






######## dummy project to generate version/config files ################
set(new_target dummy)
project(${new_target}
    DESCRIPTION "${new_target}-project for sizeof_void_p detection and more."
    LANGUAGES CXX)









# Determine support for the C++ module scanning and CXX_MODULE File_Sets
# Requires C++20, CMake >= 3.28 and 
# Generators(Ninja >= 1.11 OR Visual Studio >= 17.4).
# Compilers GCC>=14, Clang>=16 or MSVC >= 17.4
# Source: https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html
set(_USE_CMAKE_MODULES OFF)
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.28 AND CMAKE_CXX_STANDARD GREATER_EQUAL 20)
    if(CMAKE_GENERATOR MATCHES "Ninja( Multi-Config)?")
        # message(NOTICE " . | CMAKE_GENERATOR: ${CMAKE_GENERATOR} (matched)")
        execute_process(COMMAND "${CMAKE_MAKE_PROGRAM}" "--version"
            OUTPUT_VARIABLE NINJA_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(NINJA_VERSION VERSION_GREATER_EQUAL 1.11)
            message(NOTICE " . | NINJA_VERSION: ${NINJA_VERSION} (matched)")
            message(NOTICE " . | CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID} (matched)")
            if((CMAKE_CXX_COMPILER_ID STREQUAL "GNU"
                     AND CMAKE_CXX_COMPILER_VERSION GREATER_EQUAL 14)
                OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
                     AND CMAKE_CXX_COMPILER_VERSION GREATER_EQUAL 16)
                OR (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC"
                     AND MSVC_VERSION GREATER_EQUAL 1934)
            )
                set(_USE_CMAKE_MODULES ON)
            endif()
        endif()
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio" AND MSVC_VERSION GREATER_EQUAL 1934)
        message(NOTICE " . | CMAKE_GENERATOR: ${CMAKE_GENERATOR} (msvc)")
        set(_USE_CMAKE_MODULES ON)
    else()
        message(NOTICE " . | CMAKE_GENERATOR: ${CMAKE_GENERATOR} (unmatched)")
    endif()
endif()

# ENABLE_CXX_MODULES
#   You can define it from command-line for enforcing cxx-modules building.
#   It will be also transited into app-config.hh as a cxx macro name.
#   If you're using define_lite_cxx_module(), ENABLE_CXX_MODULES will take
#   effects into it.
option(ENABLE_CXX_MODULES "enable cxx module building ${_USE_CMAKE_MODULES} for cmake ${CMAKE_VERSION} + ${CMAKE_CXX_COMPILER_ID}" ${_USE_CMAKE_MODULES})
message(NOTICE " . | CMAKE_VERSION: ${CMAKE_VERSION}          # CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
message(NOTICE " . | ENABLE_CXX_MODULES: ${ENABLE_CXX_MODULES}")
message(NOTICE "......................................")
option(ENABLE_IMPORT_STD "enable import std or #include directive" ${_USE_CMAKE_MODULES})





#debug_print_value(CMAKE_CXX_COMPILER_VERSION)
#debug_print_value(CMAKE_COMPILER_IS_GNUCXX)
if(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++ -Wall ")
else()
    set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++ -Weverything -Wno-c++98-compat -Wreserved-module-identifier -Wno-unused-command-line-argument")
endif()

cmake_path(GET CMAKE_CXX_COMPILER PARENT_PATH CXX_BIN_DIR)
cmake_path(GET CXX_BIN_DIR PARENT_PATH CXX_DIR)
# message(NOTICE " .  Using CMake ${CMAKE_VERSION}")
message(NOTICE " .  Using C++ Compiler: ${CMAKE_CXX_COMPILER_ID} / ${CMAKE_CXX_COMPILER_VERSION}")
message(NOTICE " .                path: ${CMAKE_CXX_COMPILER}")
message(NOTICE " .      root (CXX_DIR): ${CXX_DIR}")
message(NOTICE " .          \$ENV{HOME}: $ENV{HOME} / $ENV{USERPROFILE} ")
#message(NOTICE " .   vcpkg tests 1: env: $ENV{VCPKG_ROOT}; def: ${VCPKG_ROOT}; ")
#message(NOTICE " . CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")







#
# check CPU bits
#
if(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
    # 64 bits
    set(CPU_ARCH "64" CACHE STRING "CPU Arch x86_64/arm64/..." FORCE)

    # set(CPU_ARCH_NAME "amd64" CACHE STRING "ARCH x86_64" FORCE)
    message(STATUS "CPU_ARCH 64bit | ${CMAKE_HOST_SYSTEM_PROCESSOR} ...")
elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
    # 32 bits
    set(CPU_ARCH "32" CACHE STRING "CPU Arch x86 (32bit)" FORCE)

    # set(CPU_ARCH_NAME "x86" CACHE STRING "ARCH x86_64" FORCE)
    message(STATUS "CPU_ARCH 32bit | ${CMAKE_HOST_SYSTEM_PROCESSOR} ...")
else()
    # message(STATUS "Unknown CMAKE_SIZEOF_VOID_P = '${CMAKE_SIZEOF_VOID_P}' ..?")
    if("${CMAKE_HOST_SYSTEM_PROCESSOR}" MATCHES "(amd64)|(AMD64)|(IA64)|(EM64T)|(x86_64)|(arm64)|(aarch64)|(aarch64_be)|(mips64)|(sparc64)")
        set(CPU_ARCH "64" CACHE STRING "CPU Arch x86_64/arm64/aarch64/..." FORCE)

        # set(CPU_ARCH_NAME "x86_64" CACHE STRING "ARCH x86_64" FORCE)
        # set(CPU_ARCH_NAME "amd64" CACHE STRING "ARCH x86_64" FORCE)
        message(STATUS "CPU_ARCH 64bit | ${CMAKE_HOST_SYSTEM_PROCESSOR} ...")
    else()
        set(CPU_ARCH "32" CACHE STRING "CPU Arch x86" FORCE)

        # set(CPU_ARCH_NAME "x86" CACHE STRING "ARCH x86_64" FORCE)
        message(STATUS "CPU_ARCH 32bit | ${CMAKE_HOST_SYSTEM_PROCESSOR} ...")
    endif()
endif()


message(STATUS "")
message(STATUS "PROCESSOR_ARCHITEW6432        = ${PROCESSOR_ARCHITEW6432}")
message(STATUS "PROCESSOR_ARCHITECTURE        = ${PROCESSOR_ARCHITECTURE}")
message(STATUS "CMAKE_APPLE_SILICON_PROCESSOR = ${CMAKE_APPLE_SILICON_PROCESSOR}")
message(STATUS "CMAKE_SYSTEM                  = ${CMAKE_SYSTEM}")
message(STATUS "CMAKE_SYSTEM_NAME             = ${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR        = ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_SYSTEM_VERSION          = ${CMAKE_SYSTEM_VERSION}")
message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR   = ${CMAKE_HOST_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_HOST_SYSTEM_NAME        = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "CMAKE_HOST_SYSTEM_VERSION     = ${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "CMAKE_HOST_APPLE              = ${CMAKE_HOST_APPLE}")
message(STATUS "CMAKE_HOST_LINUX              = ${CMAKE_HOST_LINUX}")
message(STATUS "CMAKE_HOST_UNIX               = ${CMAKE_HOST_UNIX}")
message(STATUS "CMAKE_HOST_WIN32              = ${CMAKE_HOST_WIN32}")
message(STATUS "CMAKE_HOST_SOLARIS            = ${CMAKE_HOST_SOLARIS}")
message(STATUS "CMAKE_HOST_BSD                = ${CMAKE_HOST_BSD}")
message(STATUS "CMAKE_LIBRARY_ARCHITECTURE    = ${CMAKE_LIBRARY_ARCHITECTURE}")
message(STATUS "")
message(STATUS "CMAKE_CXX_COMPILER            = ${CMAKE_CXX_COMPILER}")
message(STATUS "CMAKE_C_COMPILER              = ${CMAKE_C_COMPILER}")
message(STATUS "CMAKE_MAKE_PROGRAM            = ${CMAKE_MAKE_PROGRAM}")
message(STATUS "CMAKE_GENERATOR               = ${CMAKE_GENERATOR}")
message(STATUS "CMAKE_BUILD_TYPE              = ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_TOOLCHAIN_FILE          = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "")


# see:
#   1. https://stackoverflow.com/questions/45125516/possible-values-for-uname-m/45125525#45125525
#   2. https://stackoverflow.com/questions/70475665/what-are-the-possible-values-of-cmake-system-processor
set(CPU_NAME ${CMAKE_HOST_SYSTEM_PROCESSOR} CACHE STRING "CPU name, eg: arm64/amd64/...")
debug_print_value(CPU_NAME) # eg: arm64
debug_print_value(CPU_ARCH) # eg: 64
message(STATUS "")

#
#
# a dummy target here, just for reference if necessary
add_library(${new_target} INTERFACE IMPORTED)

#
#
#
include(target-dirs) # prepare target dirs
include(cxx-detect-compilers) # detect cxx compiler
include(detect-systems) # detect OS, ...
include(cxx-macros) # macros: define_cxx_executable_target, ...
include(version-def) # load .version.cmake
include(versions-gen) # generate config.h and version.hh

include(cxx-compilers-per-project)
#### include(cxx-tools) # define_test_program, define_example_program, define_cxx_library_target, ...
include(cxx-modules) # check if cxx modules need to be enasbled




#message(STATUS "| ENABLE_CXX_MODULES             = ${ENABLE_CXX_MODULES}")
if(CLION_IDE)
    message(STATUS "| INSIDE CLion IDE")
endif()
if(ENABLE_CXX_MODULES)
    #  # a dummy target would help clion get index of std module.
    #  # but, llvm latest + vs-code won't like it and complain
    #  #   Disagreement of the location of the 'std' module ... Location A: ..., Location B: ...
    #  # so we disable it for the case.
    #  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    #    # for CLion and CMake 4.1.2, cannot import std is a known issue:
    #    # and specify cmake commandline args: 
    #    #     -DCMAKE_CXX_STDLIB_MODULES_JSON:STRING=/opt/homebrew/opt/llvm/lib/c++/libc++.modules.json
    #    #     -Wno-dev
    #    add_library(dummy_std_target STATIC)
    #    target_compile_features(dummy_std_target PUBLIC cxx_std_23)
    #    add_cxx_standard_to(dummy_std_target 23)
    #    set_target_properties(dummy_std_target PROPERTIES FOLDER "Supports/dummy_std_target")
    #    #set_target_properties(dummy_std_target PROPERTIES CXX_MODULE_STD ON)
    #    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    #      target_sources(dummy_std_target PRIVATE
    #        FILE_SET unused_files TYPE CXX_MODULES
    #        BASE_DIRS ${CXX_DIR}/share/libc++/v1
    #        FILES ${CXX_DIR}/share/libc++/v1/std.cppm ${CXX_DIR}/share/libc++/v1/std.compat.cppm)
    #      message(NOTICE " . dummy_std_target (ENABLE_CXX_MODULES): using BASE_DIRS ${CXX_DIR}/share/libc++/v1")
    #    endif()
    #  endif()
endif()

message(STATUS "| ENABLE_CXX_MODULES             = ${ENABLE_CXX_MODULES}")



# when using compiler with cmake multi-config feature, a special build type 'Asan' can be used for sanitizing test.
# enable_sanitizer_for_multi_config()

