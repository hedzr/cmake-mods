#
# check CPU bits
#

set(new_target dummy)
project(${new_target}
    DESCRIPTION "${new_target}-project for sizeof_void_p detection and more."
    LANGUAGES CXX)

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

# when using compiler with cmake multi-config feature, a special build type 'Asan' can be used for sanitizing test.
# enable_sanitizer_for_multi_config()
