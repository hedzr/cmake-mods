## PACKAGING ##################################################

include(detect-systems)

# https://cmake.org/cmake/help/latest/module/CPack.html

# build a CPack driven installer package
include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
# set(CPACK_PACKAGE_DIRECTORY ${CMAKE_SOURCE_DIR}/dist)
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(CPACK_SOURCE_IGNORE_FILES
    ${PROJECT_SOURCE_DIR}/build
    ${PROJECT_SOURCE_DIR}/cmake-build-debug
    ${PROJECT_SOURCE_DIR}/dist
    ${PROJECT_SOURCE_DIR}/.idea
    ${PROJECT_SOURCE_DIR}/.DS_Store
    ${PROJECT_SOURCE_DIR}/.git
    ${PROJECT_SOURCE_DIR}/.gitignore
    ${PROJECT_SOURCE_DIR}/.vscode
    ${PROJECT_SOURCE_DIR}/.PIC
    ${PROJECT_SOURCE_DIR}/ref
    ${PROJECT_SOURCE_DIR}/_assets/*)
#set(CPACK_SOURCE_GENERATOR "TXZ")
#set(CPACK_SOURCE_PACKAGE_FILE_NAME ${ARCHIVE_NAME})
#file(STRINGS "${CMAKE_SOURCE_DIR}/LICENSE" lic)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
# set(CPACK_PACKAGE_DESCRIPTION "A C++17 header-only command-line parser with hierarchical config data manager")
#set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "")
set(CPACK_PACKAGE_CONTACT "hedzr <hedzr@duck.com>")
set(CPACK_PACKAGE_VENDOR "hz OSS Workgroup")
set(CPACK_PACKAGE_HOMEPAGE "https://github.com/hedzr")

if(DISTRO_ID STREQUAL "debian")
    message(STATUS ">>>> Found Debian <<<<")
    include(package-deb)
elseif(DISTRO_ID STREQUAL "ubuntu")
    message(STATUS ">>>> Found Ubuntu <<<<")
    include(package-deb)
    if(target_type STREQUAL "EXECUTABLE")
        # Process executable target
        set(CPACK_DEBIAN_PACKAGE_NAME "${target}")
    else()
        set(CPACK_DEBIAN_PACKAGE_NAME "lib${target}-dev")
    endif()
elseif(DISTRO_ID STREQUAL "fedora")
    message(STATUS ">>>> Found Fedora <<<<")
    include(package-rpm)
elseif(DISTRO_ID STREQUAL "centos") # DISTRO_NAME = CentOS
    message(STATUS ">>>> Found Fedora <<<<")
    include(package-rpm)
elseif(DISTRO_ID STREQUAL "redhat") # DISTRO_NAME = RehHat ?
    message(STATUS ">>>> Found RedHat <<<<")
    include(package-rpm)
elseif(macOS)
    message(STATUS ">>>> Found macOS/Darwin <<<<")
    include(package-dmg)
else()
    message(STATUS ">>>> Found unknown distribution (DISTRO_NAME=${DISTRO_NAME}, ID=${DISTRO_ID}) <<<<")
endif()

message(STATUS ">>>> DISTRO_NAME=${DISTRO_NAME}, ID=${DISTRO_ID} <<<<")

#if (NOT CPack_CMake_INCLUDED)
# #
# # If CMake is run with the Makefile or Ninja generator, then include(CPack) also generates a target package_source. To build a source package, instead of cpack -G TGZ --config CPackSourceConfig.cmake one may call cmake --build . --target package_source, make package_source, or ninja package_source.
# include(CPack)
# # https://cmake.org/cmake/help/latest/module/CPack.html#targets-package-and-package-source
# #
#endif ()
