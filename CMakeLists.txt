cmake_minimum_required(VERSION 3.21) # FOR `cmake -G "Visual Studio 17 2022" -A ARM64`
# cmake_minimum_required(VERSION 3.0.0)
# cmake_minimum_required(VERSION 3.9..3.25)

# ### INCLUDES ##########################################################
include(${CMAKE_SOURCE_DIR}/cmake/prerequisites.cmake)


# ### DEFINITIONS #######################################################
set(PROJECT_MACRO_NAME cmake-mods)
set(PROJECT_MACRO_SHORT_NAME cm)
set(PROJECT_MACRO_MID_NAME cmake-mods)
set(PROJECT_MACRO_PREFIX "CM")
set_property(GLOBAL PROPERTY PROJECT_MAINTAINER "hedzr <hedzr@duck.com>")
set_property(GLOBAL PROPERTY PROJ_HOMEPAGE "https://github.com/hedzr/cmake-mods")
set_property(GLOBAL PROPERTY PROJ_REPO_URL "https://github.com/hedzr/cmake-mods")


# ### OPTIONS ###########################################################

# option(OK "PL-OK" ON)


# ### PROJECTS PREPARE ##################################################

# find_package(Threads REQUIRED)


# ### PROJECTS ##########################################################
project(${PROJECT_MACRO_NAME}
    VERSION ${VERSION}
    DESCRIPTION "${PROJECT_MACRO_MID_NAME} - cmake module suite for cxx-dev."
    LANGUAGES CXX)
debug_print_project_title()

# Enable C++ Standard 17/20 here. Change it on fist configuring, or update it with new value:
# cmake -S. -Bbuild -DCXX_STANDARD:STRING=20
set(CXX_STANDARD 20 CACHE STRING "Define The C++ Standard, default is 20")
enable_cxx_standard(CXX_STANDARD)

# if(ENABLE_TESTS)
#     include(load-catch2)
# endif()

# when using compiler with cmake multi-config feature, a special build type 'Asan' can be used for sanitizing test.
# enable_sanitizer_for_multi_config()

message(STATUS "---- define ${PROJECT_NAME} / ${PROJECT_MACRO_NAME} ------------")
define_cxx_executable_project(${PROJECT_NAME}
    PREFIX ${PROJECT_MACRO_PREFIX}
    CXXSTANDARD ${CXX_STANDARD}

    INSTALL # installable?
    PACK # CPack?
    GENERATE_CONFIG # generate config.h and version.h

    # BUILD_DOCS    # build docs with doxygen? 

    SOURCES src/main.cc #   driver.cc

    HEADERS
    #   ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_NAME}-all.hh
    ${CMAKE_GENERATED_DIR}/${PROJECT_NAME}-version.hh
    ${CMAKE_GENERATED_DIR}/${PROJECT_NAME}-config.hh
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_MID_NAME}.hh
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_MID_NAME}/${PROJECT_MACRO_SHORT_NAME}-all.hh
)
message(STATUS "---- defined ${PROJECT_NAME} / ${PROJECT_MACRO_NAME} ------------")

# add_subdirectory(src/)


# #### TESTS ############################################################

# if(${${PROJECT_MACRO_PREFIX}_BUILD_TESTS_EXAMPLES} OR (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR))
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    enable_testing()
    # add_subdirectory(examples/)
    add_subdirectory(test/)
endif()


# # TPL ## TAIL ##########
message(STATUS "tail of top level :  Using default C++ Standard ${CXX_STANDARD}")

# apply_all_unit_tests(all_tests)     # invoke CTest unittests automatically.
# dump_feature_summary()              # tail print to cmake-debug/features.log
# env var CTEST_OUTPUT_ON_FAILURE=1 to display ctest error verbosely.
# ctest cmdline options: --verbose or --extra-verbose or --verbose-on-failure
# debug_print_value(DEBUG)
# debug_print_value(BUILD_DOCUMENTATION)
