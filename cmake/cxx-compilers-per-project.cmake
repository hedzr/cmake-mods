


### PER COMPILERS ######################################

if(ARCH_AMD64)
    option(TIFLASH_ENABLE_AVX_SUPPORT "enable AVX and AVX2 support" ON)
    option(TIFLASH_ENABLE_AVX512_SUPPORT "enable AVX512 support" ON)
endif()

if(ARCH_AARCH64)
    option(TIFLASH_ENABLE_ASIMD_SUPPORT "enable Advanced SIMD support" ON)
    option(TIFLASH_ENABLE_SVE_SUPPORT "enable Scalable Vector Extension support" OFF)
endif()

if(ENABLE_AVX_SUPPORT)
    add_definitions(-DGLOBAL_ENABLE_AVX_SUPPORT=1)
endif()

if(ENABLE_AVX512_SUPPORT)
    add_definitions(-DGLOBAL_ENABLE_AVX512_SUPPORT=1)
endif()

if(ENABLE_ASIMD_SUPPORT)
    add_definitions(-DGLOBAL_ENABLE_ASIMD_SUPPORT=1)
endif()

if(ENABLE_SVE_SUPPORT)
    add_definitions(-DGLOBAL_ENABLE_SVE_SUPPORT=1)
endif()

if(NOT MSVC)
    set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wall") # -Werror is also added inside directories with our own code.
endif()

if(COMPILER_GCC OR COMPILER_CLANG)
    set(CXX_WARNING_FLAGS "${CXX_WARNING_FLAGS} -Wnon-virtual-dtor")
endif()

if(COMPILER_CLANG)
    # Clang doesn't have int128 predefined macros, workaround by manually defining them
    # Reference: https://stackoverflow.com/questions/41198673/uint128-t-not-working-with-clang-and-libstdc
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__GLIBCXX_BITSIZE_INT_N_0=128 -D__GLIBCXX_TYPE_INT_N_0=__int128")

    option(ENABLE_TIME_TRACES "Enable clang feature time traces" ON)
    if(ENABLE_TIME_TRACES)
        message(STATUS "ENABLE_TIME_TRACES is ON")
        set(CLANG_TIME_TRACES_FLAGS "-ftime-trace")
        message(STATUS "Using clang time traces flag `${CLANG_TIME_TRACES_FLAGS}`. Generates JSON file based on output filename. Results can be analyzed with chrome://tracing or https://www.speedscope.app for flamegraph visualization.")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CLANG_TIME_TRACES_FLAGS}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CLANG_TIME_TRACES_FLAGS}")
    endif()

    # https://clang.llvm.org/docs/ThinLTO.html
    # Applies to clang only.
    option(ENABLE_THINLTO "Clang-specific link time optimization" OFF)

    if(ENABLE_THINLTO AND NOT ENABLE_TESTS)
        # Link time optimization
        set(THINLTO_JOBS "0" CACHE STRING "ThinLTO compilation parallelism")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -flto=thin -fvisibility=hidden -fvisibility-inlines-hidden -fsplit-lto-unit")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -flto=thin -fvisibility=hidden -fvisibility-inlines-hidden -fwhole-program-vtables -fsplit-lto-unit")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto=thin -flto-jobs=${THINLTO_JOBS} -fvisibility=hidden -fvisibility-inlines-hidden -fwhole-program-vtables -fsplit-lto-unit")
    elseif(ENABLE_THINLTO)
        message(WARNING "Cannot enable ThinLTO")
    endif()
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # clang: warning: argument unused during compilation: '-stdlib=libc++'
    # clang: warning: argument unused during compilation: '-specs=/usr/share/dpkg/no-pie-compile.specs' [-Wunused-command-line-argument]
    set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wno-unused-command-line-argument")
endif()

if(ARCH_LINUX)
    set(CXX11_ABI "ENABLE" CACHE STRING "Use C++11 ABI: DEFAULT, ENABLE, DISABLE")
endif()
