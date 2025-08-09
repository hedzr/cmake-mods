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

# see:
#   1. https://stackoverflow.com/questions/45125516/possible-values-for-uname-m/45125525#45125525
#   2. https://stackoverflow.com/questions/70475665/what-are-the-possible-values-of-cmake-system-processor
set(CPU_NAME ${CMAKE_HOST_SYSTEM_PROCESSOR} CACHE STRING "CPU name, eg: arm64/amd64/...")
debug_print_value(CPU_NAME) # eg: arm64
debug_print_value(CPU_ARCH) # eg: 64

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
