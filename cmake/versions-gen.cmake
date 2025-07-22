# https://github.com/pmirshad/cmake-with-git-metadata/blob/master/CMakeLists.txt

macro(gen_versions PROJ_NAME PROJECT_MACRO_PREFIX VERSION_H_NAME CONFIG_H_NAME ARCHIVE_NAME xVERSION_IN xCONFIG_BASE_IN)
    if(DEFINED PROJ_NAME)
    else()
        set(PROJ_NAME ${CMAKE_PROJECT_NAME})
    endif()

    if(PROJECT_MACRO_PREFIX)
    else()
        set(PROJECT_MACRO_PREFIX ${PROJ_NAME})
    endif()

    if(VERSION_H_NAME)
    else()
        set(VERSION_H_NAME "${PROJ_NAME}-version.hh")
    endif()

    if(CONFIG_H_NAME)
    else()
        set(CONFIG_H_NAME "${PROJ_NAME}-config.hh")
    endif()

    if(ARCHIVE_NAME)
    else()
        set(ARCHIVE_NAME ${PROJ_NAME}-${CMAKE_PROJECT_VERSION})
    endif()

    set(xrversion_in ${xVERSION_IN})
    if(xVERSION_IN)
        # message("xVERSION_IN  = '${xrversion_in}'")
    else()
        set(xrversion_in "${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/version.h.in")
        if(NOT EXISTS ${xrversion_in})
            set(xrversion_in "${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/cmake-mods/${CMAKE_SCRIPTS}/version.h.in")
        else()
            # message("xVERSION_IN => '${xrversion_in}'")
        endif()
        # message("xVERSION_IN := '${xrversion_in}'")
    endif()

    set(xrconfig_in ${xCONFIG_BASE_IN})
    if(xCONFIG_BASE_IN)
    else()
        set(xrconfig_in ${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/config-base.h.in)
        if(NOT EXISTS ${xrconfig_in})
            set(xrconfig_in ${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/cmake-mods/${CMAKE_SCRIPTS}/config-base.h.in)
        endif()
    endif()

    set(xOUT_DIR ${CMAKE_GENERATED_DIR})

    message("||              gen_version() : output-dir -> ${xOUT_DIR}")
    message("||   Using version.hh.in file : ${xrversion_in}, ARCHIVE_NAME = ${ARCHIVE_NAME}, PROJECT_MACRO_PREFIX = ${PROJECT_MACRO_PREFIX}")
    message("||    Using config.hh.in file : ${xrconfig_in}")
    message("||           CMAKE_SOURCE_DIR = ${CMAKE_SOURCE_DIR}")

    if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
        # git describe --tags --abbrev=0   # 0.1.0-dev
        # git describe --tags              # 0.1.0-dev-93-g1416689
        # git describe --abbrev=0          # to get the most recent annotated tag
        execute_process(
            COMMAND git describe --abbrev=0 --tags
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_LAST_TAG
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        execute_process(
            COMMAND git describe --tags
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_LAST_TAG_LONG
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        execute_process(
            COMMAND git rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_BRANCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        execute_process(
            COMMAND git rev-parse HEAD
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_COMMIT_HASH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        execute_process(
            COMMAND git log -1 --format=%h
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_COMMIT_REV
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    else()
        set(GIT_BRANCH "master")
        set(GIT_LAST_TAG "HEAD")
        set(GIT_LAST_TAG_LONG "HEAD")
        set(GIT_COMMIT_HASH "")
        set(GIT_COMMIT_REV "")
    endif()

    # # get_git_head_revision(GIT_REFSPEC GIT_SHA1)
    # string(SUBSTRING "${GIT_COMMIT_HASH}" 0 12 GIT_COMMIT_REV)
    # if (NOT GIT_COMMIT_HASH)
    # set(GIT_COMMIT_REV "0")
    # endif ()
    message("||      Git current branch : ${GIT_BRANCH}")
    message("||           Git last tags : ${GIT_LAST_TAG}, Long: ${GIT_LAST_TAG_LONG}")
    message("||         Git commit hash : ${GIT_COMMIT_HASH}, revision: ${GIT_COMMIT_REV}")

    if(NOT "${xOUT_DIR}")
    else()
        message(FATAL "     >> ERROR: please include target-dirs.cmake at first.")

        # we need CMAKE_GENERATED_DIR at present.
    endif()

    # include(CheckIncludeFile)
    # include(CheckIncludeFiles)
    # set(HAS_UNISTD_H 0)
    # check_include_file("unistd.h" HAS_UNISTD_H)
    # check_include_files("stdio.h;string.h" HAVE_STDIO_AND_STRING_H)
    message("||        unistd.h checked : HAS_UNISTD_H = ${HAS_UNISTD_H}")

    set(_output_dir ${xOUT_DIR})
    # set(_output_dir ${CMAKE_CURRENT_BINARY_DIR})

    if(EXISTS ${xrversion_in})
        message("||    Generating version.h from ${xrversion_in} to ${_output_dir} - Version ${PROJECT_VERSION}...")
        configure_file(
            ${xrversion_in}
            ${_output_dir}/${VERSION_H_NAME}
        )
        message("|| Generated: ${_output_dir}/${VERSION_H_NAME}")
    endif()

    if(EXISTS ${xrconfig_in})
        message("||    Generating ${CONFIG_H_NAME} from ${xrconfig_in} to ${_output_dir} - Version ${PROJECT_VERSION}...")
        configure_file(
            ${xrconfig_in}
            ${_output_dir}/${CONFIG_H_NAME}
        )
        message("|| Generated: ${_output_dir}/${CONFIG_H_NAME}")
    endif()
endmacro()
