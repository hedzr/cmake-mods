# cmake-1

```bash
git submodule add https://github.com/free2w/cmake-1.git cmake/cmake-mods
```

```cmake title="CMakeLists.txt"
cmake_minimum_required(VERSION 3.21) # FOR `cmake -G "Visual Studio 17 2022" -A ARM64`

# ### INCLUDES ##########################################################
include(${CMAKE_SOURCE_DIR}/cmake/cmake-mods/cmake/prerequisites.cmake)
# ### DEFINITIONS #######################################################
# ### OPTIONS #######################################################
# ### PREPARATIONS #######################################################
# ### PROJECTS #######################################################
project(${PROJECT_MACRO_NAME}
    VERSION ${VERSION}
    DESCRIPTION "${PROJECT_MACRO_MID_NAME} - cxx20 common template library."
    LANGUAGES CXX)
debug_print_project_title()

set(CXX_STANDARD 20 CACHE STRING "Define The C++ Standard, default is 20")
enable_cxx_standard(CXX_STANDARD)

define_cxx_library_project(${PROJECT_NAME}
    INTERFACE
    PREFIX ${PROJECT_MACRO_PREFIX}
    INSTALL # installable?
    PACK # CPack?
    GENERATE_CONFIG # generate config.h and version.h

    # BUILD_DOCS    # build docs with doxygen? 
    # CXXSTANDARD 20

    # SOURCES
    #   core.cc
    #   driver.cc

    HEADERS
    #   ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_NAME}-all.hh
    ${CMAKE_GENERATED_DIR}/${PROJECT_NAME}-version.hh
    ${CMAKE_GENERATED_DIR}/${PROJECT_NAME}-config.hh
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_MID_NAME}.hh
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_MID_NAME}/${PROJECT_MACRO_SHORT_NAME}-all.hh
)
message(STATUS "---- defined ${PROJECT_NAME} / ${PROJECT_MACRO_NAME} ------------")
```
