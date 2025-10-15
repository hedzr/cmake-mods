# cmake-mods

cmake-modes includes a couple of cmake modules for our C++ projects.

Some useful features are:

- calculating the prerequisites for the whole workspace - `include .../prerequisites.cmake`
- and specially for per project - `include(cxx-compilers-per-project)`
- debug_print_XXX debug marcos
- cmdr-cxx integrator - see the load-cmdr-cxx.cmake
- versions increaser - `enable_version_increaser()`
- auto generating version.hh and config.hh
- cpack support - `enable_cpack()`
- main target makers:
  - `define_cxx_library_target()`
  - `define_cxx_executable_target()`
  - `define_test_program()`
  - `define_example_program()`
- more macros and functions:
  - `attach_doxygen_to()`
  - ...

## Usage

### download into `./cmake/cmake-mods`

```bash
git submodule add https://github.com/hedzr/cmake-mods.git ./cmake/cmake-mods
```

And modifying the top-level `CMakeLists.txt`, make it looks like:

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
include(cxx-compilers-per-project)
debug_print_project_title()

set(CXX_STANDARD 20 CACHE STRING "Define The C++ Standard, default is 20")
enable_cxx_standard(CXX_STANDARD)

define_cxx_library_target(${PROJECT_NAME}
    INTERFACE
    PREFIX ${PROJECT_MACRO_PREFIX}
    INSTALL # installable?
    PACK # CPack?
    GENERATE_CONFIG # generate config.h and version.h
    # IPO
    # BUILD_DOCS    # build docs with doxygen? 
    # CXXSTANDARD 20

    SOURCES
      main.cc
      # driver.cc

    HEADERS
      #   ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_NAME}-all.hh
      ${CMAKE_GENERATED_DIR}/${PROJECT_NAME}-version.hh
      ${CMAKE_GENERATED_DIR}/${PROJECT_NAME}-config.hh
      ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_MID_NAME}.hh
      ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_MACRO_MID_NAME}/${PROJECT_MACRO_SHORT_NAME}-all.hh
)
enable_version_increaser(${PROJECT_MACRO_NAME} ${PROJECT_MACRO_NAME} ${PROJECT_MACRO_SHORT_NAME} ${PROJECT_MACRO_PREFIX})
message(STATUS "---- defined ${PROJECT_NAME} / ${PROJECT_MACRO_NAME} ------------")
```

### `.version.cmake`

`.version.cmake` should be put into root folder, its content never changed when you needn't modify major.minor.patch fields:

```cmake
file(READ ".build-serial" BUILD_SERIAL)
set(VERSION 0.1.3.${BUILD_SERIAL})
```

And if you would bump the project version, modifying the line 2 in this file.

### `.build-serial`

`.build-serial` should be excluded in `.gitignore` since it has always been changed after a normal building action completed.

## LICENSE

Apache 2.0
