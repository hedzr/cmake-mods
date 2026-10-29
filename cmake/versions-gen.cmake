
function(gen_versions
    # PROJ_NAME xPROJECT_MACRO_PREFIX
    # VERSION_H_NAME
    # CONFIG_H_NAME
    # ARCHIVE_NAME
    # xVERSION_IN
    # xCONFIG_BASE_IN
)
    set(__gen_versions_PARAM_OPTIONS)
    set(__gen_versions_PARAM_ONE_VALUE_KEYWORDS
        PROJ_NAME
        MACRO_PREFIX
        VERSION_HH_PATH
        CONFIG_HH_PATH
        ARCHIVE_NAME
        CMAKE_SCRIPTS
        CMAKE_GENERATED_DIR
        VERSION_IN
        CONFIG_IN
        OUTPUT_DIR
    )
    set(__gen_versions_PARAM_MULTI_VALUE_KEYWORDS
        # CXXFLAGS # cxx compiler options
    )
    cmake_parse_arguments(
        gen_versions_ARG # Prefix
        "${__gen_versions_PARAM_OPTIONS}" # Options (keywords with no value, set to TRUE/FALSE)
        "${__gen_versions_PARAM_ONE_VALUE_KEYWORDS}" # One-value keywords (e.g., SINGLE_KW value)
        "${__gen_versions_PARAM_MULTI_VALUE_KEYWORDS}" # Multi-value keywords (e.g., MULTI_KW value1 value2 ...)
        ${ARGN} # Arguments to parse (all arguments passed to the macro)
    )
    set(define_gen_versions_usage "gen_versions(
	 [PROJ_NAME <name>]           # eg: cui
     [MACRO_PREFIX <prefix>]      # eg: CUI_
     [VERSION_HH_PATH <PATH>]     # eg: cui-version.hh
	 [CONFIG_HH_PATH <PATH>]      # eg: cui-config.hh
	 [ARCHIVE_NAME <name>]        # eg: cui-1.0.0
     [CMAKE_SCRIPTS <dir>]        # eg: cmake
	 [CMAKE_GENERATED_DIR <dir>]  # eg: \${CMAKE_BINARY_DIR}/generated
	 [VERSION_IN <file>]          # eg: app-version.hh.in
	 [CONFIG_IN <file>]           # eg: config-base.hh.in
	 [OUTPUT_DIR <file>]          # eg: \${CMAKE_GENERATED_DIR}
     [sources...]
     )
     
     Unparsed Params Are:
     ${define_example_program_ARG_UNPARSED_ARGUMENTS}")

    # if(${gen_versions_OPT_OPTION})
    #     message("OPT_OPTION was provided.")
    # endif()

    # if(gen_versions_SINGLE_KW)
    #     message("SINGLE_KW has value: ${gen_versions_SINGLE_KW}")
    # endif()

    # if(gen_versions_MULTI_KW)
    #     message("MULTI_KW has values: ${gen_versions_MULTI_KW}")
    # endif()


    set(PROJ_NAME ${gen_versions_ARG_PROJ_NAME})
    set(_MACRO_PREFIX ${gen_versions_ARG_MACRO_PREFIX})
    set(_VERSION_HH_PATH ${gen_versions_ARG_VERSION_HH_PATH})
    set(_CONFIG_HH_PATH ${gen_versions_ARG_CONFIG_HH_PATH})
    set(_ARCHIVE_NAME ${gen_versions_ARG_ARCHIVE_NAME})
    set(_CMAKE_SCRIPTS ${gen_versions_ARG_CMAKE_SCRIPTS})
    set(_CMAKE_GENERATED_DIR ${gen_versions_ARG_CMAKE_GENERATED_DIR})
    set(_VERSION_IN ${gen_versions_ARG_VERSION_IN})
    set(_CONFIG_IN ${gen_versions_ARG_CONFIG_IN})
    set(_OUTPUT_DIR ${gen_versions_ARG_OUTPUT_DIR})

    if(PROJ_NAME AND NOT PROJ_NAME STREQUAL "")
    else()
        set(PROJ_NAME ${CMAKE_PROJECT_NAME})
    endif()

    if(_MACRO_PREFIX AND NOT _MACRO_PREFIX STREQUAL "")
        set(PROJECT_MACRO_PREFIX ${_MACRO_PREFIX})
        message("|| using PROJECT_MACRO_PREFIX = ${PROJECT_MACRO_PREFIX}")
    else()
        set(PROJECT_MACRO_PREFIX ${PROJ_NAME})
        message("|| using PROJECT_MACRO_PREFIX = ${PROJECT_MACRO_PREFIX}")
    endif()

    if(_VERSION_HH_PATH AND NOT _VERSION_HH_PATH STREQUAL "")
        set(VERSION_H_NAME "${_VERSION_H_NAME}")
    else()
        set(VERSION_H_NAME "${PROJ_NAME}-version.hh")
        message("|| using VERSION_H_NAME = ${VERSION_H_NAME}")
    endif()

    if(_CONFIG_HH_PATH AND NOT _CONFIG_HH_PATH STREQUAL "")
        set(CONFIG_H_NAME "${_CONFIG_HH_PATH}")
        message("|| using CONFIG_H_NAME = ${CONFIG_H_NAME}")
    else()
        set(CONFIG_H_NAME "${PROJ_NAME}-config.hh")
        message("|| using CONFIG_H_NAME = ${CONFIG_H_NAME}")
    endif()

    if(_ARCHIVE_NAME AND NOT _ARCHIVE_NAME STREQUAL "")
        set(ARCHIVE_NAME ${_ARCHIVE_NAME})
    else()
        set(ARCHIVE_NAME ${PROJ_NAME}-${CMAKE_PROJECT_VERSION})
    endif()

    if(_CMAKE_SCRIPTS AND NOT _CMAKE_SCRIPTS STREQUAL "")
        set(CMAKE_SCRIPTS "${_CMAKE_SCRIPTS}")
    else()
        set(CMAKE_SCRIPTS "cmake")
    endif()
    set(CMAKE_GENERATED_DIR "${CMAKE_GENERATED_DIR}")
    if(_CMAKE_GENERATED_DIR AND NOT _CMAKE_GENERATED_DIR STREQUAL "")
        set(CMAKE_GENERATED_DIR "${_CMAKE_GENERATED_DIR}")
        file(MAKE_DIRECTORY ${_CMAKE_GENERATED_DIR})
    else()
        set(_CMAKE_GENERATED_DIR "${CMAKE_BINARY_DIR}/generated")
        set(CMAKE_GENERATED_DIR "${_CMAKE_GENERATED_DIR}")
        file(MAKE_DIRECTORY ${_CMAKE_GENERATED_DIR})
    endif()

    set(xrversion_in ${_VERSION_IN})
    if(xVERSION_IN)
        # message("xVERSION_IN  = '${xrversion_in}'")
        set(xrversion_in ${_VERSION_IN})
    else()
        set(xrversion_in "${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/app-version.hh.in")
        if(NOT EXISTS ${xrversion_in})
            set(xrversion_in "${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/cmake-mods/${CMAKE_SCRIPTS}/app-version.hh.in")
        else()
            # message("xVERSION_IN => '${xrversion_in}'")
        endif()
        # message("xVERSION_IN := '${xrversion_in}'")
    endif()

    set(xrconfig_in ${_CONFIG_IN})
    if(xCONFIG_BASE_IN)
        set(xrconfig_in ${_CONFIG_IN})
    else()
        set(xrconfig_in ${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/config-base.hh.in)
        if(NOT EXISTS ${xrconfig_in})
            set(xrconfig_in ${CMAKE_SOURCE_DIR}/${CMAKE_SCRIPTS}/cmake-mods/${CMAKE_SCRIPTS}/config-base.hh.in)
        endif()
    endif()

    set(xOUT_DIR ${CMAKE_GENERATED_DIR})
    if(_OUTPUT_DIR)
        set(xOUT_DIR ${_OUTPUT_DIR})
    endif()

    message("||              gen_version() : output-dir -> ${xOUT_DIR}")
    message("||   Using version.hh.in file : ${xrversion_in}, ARCHIVE_NAME = ${ARCHIVE_NAME}")
    message("||    Using config.hh.in file : ${xrconfig_in}")
    message("||           CMAKE_SOURCE_DIR = ${CMAKE_SOURCE_DIR}")
    message("||       PROJECT_MACRO_PREFIX = ${_PROJECT_MACRO_PREFIX}")

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
        if(DEFINED GIT_SHA)
            set(GIT_COMMIT_HASH "${GIT_SHA}")
        else()
            execute_process(
                COMMAND git rev-parse HEAD
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE GIT_COMMIT_HASH
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
        endif()
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
        set(GIT_COMMIT_HASH "${GIT_SHA}")
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


    if(NOT PROJECT_VERSION_TWEAK)
        set(PROJECT_VERSION_TWEAK "0")
    endif()

    # include(CheckIncludeFile)
    # include(CheckIncludeFiles)
    # set(HAS_UNISTD_H 0)
    # check_include_file("unistd.h" HAS_UNISTD_H)
    # check_include_files("stdio.h;string.h" HAVE_STDIO_AND_STRING_H)
    message("||        unistd.h checked : HAS_UNISTD_H = ${HAS_UNISTD_H}")

    set(_output_dir ${xOUT_DIR})
    # set(_output_dir ${CMAKE_CURRENT_BINARY_DIR})
    message("||            _output_dir : ${_output_dir}")
    message("||           xrversion_in : ${xrversion_in}")
    message("||            xrconfig_in : ${xrconfig_in}")

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
endfunction()

