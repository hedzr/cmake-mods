#
# cxx-modules.cmake
#
#   This file provides several useful functions, such as
#   create_cxx_dual_libs, define_lite_cxx_module, and
#   add_cxx_modules_support.
#   At the end of this file, we detect cmake's cxx-modules
#   abilities and complete the most of initials and setups.
#

# define_lite_cxx_module
# create_cxx_dual_libs
#
# these two functions will define dual libraries: a module lib and a header-only lib.
#
# For instance,
#
#     message(STATUS "** defining cxx module '${MAIN_MOD_NAME}' and '${MAIN_LIB_NAME}'.")
#     create_cxx_dual_libs(${MAIN_MOD_NAME}
#       MAIN
#       DUAL
#       LIB_NAME ${MAIN_LIB_NAME}
#       LIB_ALIAS ${MAIN_LIB_ALIAS}
#       GRAB_AT ${CMAKE_CURRENT_SOURCE_DIR}/modules/cui
#     )
#     message(STATUS "** cxx module '${MAIN_MOD_NAME}' and '${MAIN_LIB_NAME}' defined.")
#
# If 'MAIN' specified, the module would be treated as a main
# module, and its headers would be expected in <root>/include/<mod>/,
# and would be included in install list.
# A 'MAIN' module would also get some extra features, such as
# versioning support. Which means a .build_serial file will be
# increased once build passed.
#
# And you can specify 'LIB_ALIAS' to define alias for the header-only lib,
# and 'MOD_ALIAS' for the module lib. If 'LIB_ALIAS' or 'MOD_ALIAS' not
# specified, we would define 'libs::<libname>' or 'mods::<modname>' alias
# by default.
#
function(define_lite_cxx_module modname)
    set(__cdlxx_PARAM_OPTIONS
        VERBOSE
        AUTOSCAN # if AUTOSCAN or GRAB_AT defined, we try grabbing module files if necessary
        MAIN # if this is a main module, its headers are in <root>/include/<mod>/
        DUAL # also define a headers-only INTERFACE library
        SHARED
        STATIC
        INTERFACE
        USE_HEADERS
        VERSIONING # enable versioning support, which means a .build_serial file will be increased once build passed.
        PACK # enable cpack support, which means a <modname>-<version>-<platform>.tar.gz would be generated in build dir after install.
        INSTALL # enable install support, which means the module's headers would be included in install list.
    )
    set(__cdlxx_PARAM_ONE_VALUE_KEYWORDS
        PROJ_NAME
        PROJ_SHORT_NAME
        MACRO_PREFIX
        CMAKE_GENERATED_DIR
        LIB_NAME
        GRAB_AT # Grab source files from this directory, or CMAKE_CURRENT_SOURCE_DIR
        FOLDER # specify parent folder name, or "Main Libraries"
        CXXSTANDARD # the minimum C++ standard required for this headers-only library (C++23 for modules)
        MOD_CXXSTANDARD
        INCLUDE_DIR_NAME # the include dir name under <root>/include, default is modname
    )
    set(__cdlxx_PARAM_MULTI_VALUE_KEYWORDS
        LIB_ALIAS
        MOD_ALIAS
        CXXFLAGS # cxx compiler options
        CXXDEFINITIONS # cxx compiler definitions, eg: "YY=1 ZZ=ok"
        INCLUDE_DIRS
        LINK_DIRS
        LIBRARIES
        BASE_DIRS # module's BASE_DIRS, or CMAKE_CURRENT_SOURCE_DIR
        FILES # module's files (*.ixx *.cppm)
        IMPL_FILES # module's impl files (*.cc)
        HEADERS
        DETAILED_HEADERS
    )
    cmake_parse_arguments(
        cdlxx_ARG # Prefix
        "${__cdlxx_PARAM_OPTIONS}" # Options (keywords with no value, set to TRUE/FALSE)
        "${__cdlxx_PARAM_ONE_VALUE_KEYWORDS}" # One-value keywords (e.g., SINGLE_KW value)
        "${__cdlxx_PARAM_MULTI_VALUE_KEYWORDS}" # Multi-value keywords (e.g., MULTI_KW value1 value2 ...)
        ${ARGN} # Arguments to parse (all arguments passed to the macro)
    )
    list(JOIN ARGV " " argv_string)
    set(define_cdlxx_usage "define_lite_cxx_module(<your-module-name>
      [PROJ_NAME <name>]                    # eg: 'format', default is \${CMAKE_PROJECT_NAME}
      [PROJ_SHORT_NAME <name>]              # short name for project, eg: 'fmt', default is \${PROJ_NAME}
      [MACRO_PREFIX <prefix>]               # eg: 'FMT_', default is PROJ_NAME + '_'
      [CMAKE_GENERATED_DIR <dir>]           # eg: \${CMAKE_BINARY_DIR}/generated
      [FOLDER <parent_folder>]              # eg: 'Main Libraries'
      [GRAB_AT <dir>]                       # Grab source files from here, or CMAKE_CURRENT_SOURCE_DIR
      [CXXSTANDARD 20|23|...]               # the minimum C++ standard required for this headers-only library (C++23 for modules)
      [MOD_CXXSTANDARD 20|23|...]           # for module library
      [INCLUDE_DIR_NAME <name>]             # the include dir name under <root>/include, default is modname
      
      [LIB_ALIAS <alias1;alias2;...>]       # header-only lib's aliases
      [MOD_ALIAS <alias1;alias2;...>]       # cxx-modules lib's aliases
      [CXXFLAGS <opt1>;<opt2>;...]          # eg: '-Wno-reserved-macro-identifier -Wno-reserved-identifier'
      [CXXDEFINITIONS <def1>;<def2>;...]    # eg: 'YY=1 ZZ=ok'
      [INCLUDE_DIRS <dir1>;<dir2>;...]      # eg: '\${CMAKE_SOURCE_DIR}/include;./include'
      [LINK_DIRS <dir1>;<dir2>;...]         # eg: '\${CMAKE_SOURCE_DIR}/lib;./lib'
      [LIBRARIES <lib1>;<lib2>;...]         # eg: 'std;std::compat'
      [HEADERS <a.hh>;<b.hh>;...]           # eg: 'a.hh;b.hh'
      [DETAILED_HEADERS <a.hh>;<b.hh>;...]  # eg: 'a.hh;b.hh', and these headers would be included in install list.
      
      [BASE_DIRS <dir1;dir2;...>]           # module's base dirctories
      
      [FILES ...]                           # module's files (*.ixx *.cppm)
        # FILES can be omitted. If so (and AUTOSCAN), we would grab
        # *.cppm and *.ixx filesfrom CMAKE_CURRENT_SOURCE_DIR
        # (Or dir specified by GRAB_AT)
      
      [IMPL_FILES ...]                      # module's private impl files (*.cc *.cpp)
        # IMPL_FILES can be omitted. If so (and AUTOSCAN), we would
        # grab *.cc and *.cpp files from CMAKE_CURRENT_SOURCE_DIR
        # (Or dir specified by GRAB_AT)
      
      # when AUTOSCAN enabled, we'll grab files for FILES/IMPL_FILES
      # if they're undefined.
      [AUTOSCAN]
      
      # if this is a main module, its headers are in <root>/include/<mod>/...
      # identify it by MAIN so that we could include the headers file into
      # install list.
      # You must specify AUTOSCAN for grabbing the header files.
      [MAIN]
      
      [DUAL]                         # if DUAL, a module library and a legacy(non-module) lib will be defined.
      [SHARED]|[STATIC]|[INTERFACE]  # if DUAL, the cxx legacy(non-module) lib would be specified to SHARED, STATIC or INTERFACE.
      
      # NOTICE: if DUAL and no IMPL_FILES specified, a cxx headers-only
      # lib (CMake INTERFACE lib) will be defined.
      
      [USE_HEADERS]      # set to TRUE if the module target need header files present, and those files will be installed to target system.
      [VERSIONING]       # enable versioning support, which means a .build_serial file will be increased once build passed.
      [PACK]             # enable cpack support, which means a <modname>-<version>-<platform>.tar.gz would be generated in build dir after install.
      [INSTALL]          # enable install support, which means the module's headers would be included in install list.
      )
      
      The given arguments are:
        ${argv_string}
      Unparsed Params are: ${cdlxx_ARG_UNPARSED_ARGUMENTS}
      Keywords missing values are: ${cdlxx_ARG_KEYWORDS_MISSING_VALUES}")
    if(cdlxx_ARG_UNPARSED_ARGUMENTS)
        # message(WARNING "Unrecognized arguments: ${cdlxx_ARG_UNPARSED_ARGUMENTS}")
        # message(WARNING "")
        message(WARNING ${define_cdlxx_usage})
    endif()

    # set default values for some parameters

    getval(_PROJ_NAME cdlxx_ARG_PROJ_NAME ${CMAKE_PROJECT_NAME})
    getval(_PROJ_SHORT_NAME cdlxx_ARG_PROJ_SHORT_NAME ${_PROJ_NAME})
    getval(_MACRO_PREFIX cdlxx_ARG_MACRO_PREFIX ${_PROJ_NAME}_)
    getval(_CMAKE_GENERATED_DIR cdlxx_ARG_CMAKE_GENERATED_DIR ${CMAKE_BINARY_DIR}/generated)
    getval(_LIB_NAME cdlxx_ARG_LIB_NAME lib${modname})
    getval(_cxx_standard cdlxx_ARG_CXXSTANDARD 23)
    getval(_cxx_standard_mod cdlxx_ARG_MOD_CXXSTANDARD 23)
    getval(_cdlxx_definitions cdlxx_ARG_CXXDEFINITIONS "")
    getval(_dir cdlxx_ARG_GRAB_AT ${CMAKE_CURRENT_SOURCE_DIR})
    getval(_base_dir cdlxx_ARG_BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})

    set(_enable_use_import_std ON)

    if(cdlxx_ARG_CXXFLAGS)
        set(_cdlxx_options "${cdlxx_ARG_CXXFLAGS}")
    else()
        set(_cdlxx_options
            -Wall
            -Wextra
            -pedantic
            -pedantic-errors
            -Wconversion
            -Wundef
            -Wdeprecated
            # -Wdeprecated-declarations
            # -Wweak-vtables
            -Wshadow

            -Wcast-qual
            -Wconversion-null
            -Wmissing-declarations
            -Woverlength-strings
            -Wpointer-arith
            -Wunused-local-typedefs
            -Wunused-result
            -Wvarargs
            -Wvla
            -Wwrite-strings

            -Wredundant-decls
            -Wformat=2
            -Wmissing-include-dirs
            -Wcast-align
            -Wctor-dtor-privacy
            -Wdisabled-optimization
            -Winvalid-pch
            -Woverloaded-virtual
            # -fsafe-buffer-usage-suggestions
            -Wno-double-promotion
            -Wno-float-conversion
            -Wno-old-style-cast
            -Wno-ctor-dtor-privacy
            -Wno-format-nonliteral
        )
        if(CMAKE_COMPILER_IS_GNUCXX)
            set(_cdlxx_options
                # -pthread
                ${_cdlxx_options}
                -Wno-missing-declarations
                # -Wno-gnu-zero-variadic-macro-arguments
            )
            check_cxx_compiler_flag(-Wzero-as-null-pointer-constant HAS_NULLPTR_WARNING)
            if(HAS_NULLPTR_WARNING)
                set(_cdlxx_options ${_cdlxx_options}
                    -Wzero-as-null-pointer-constant)
            endif()
            set(_cdlxx_options ${_cdlxx_options}
                -Wdeprecated-declarations
                # ignore decl in codes such as '[[clang::always_destroy]]' / CLANG_ALWAYS_DESTROY
                -Wno-attributes
            )
            set(_WERROR_FLAG -Werror)
        elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            set(_cdlxx_options
                # -pthread
                ${_cdlxx_options}
                # -Wweak-vtables
                -fsafe-buffer-usage-suggestions

                -Wno-predefined-identifier-outside-function
                -Wno-reserved-macro-identifier
                -Wno-reserved-identifier
                -Wno-reserved-module-identifier
                -Wno-unused-command-line-argument
                -Wno-c++98-compat
                -Wno-c++98-compat-pedantic
            )
            set(_WERROR_FLAG -Werror)
        elseif(MSVC)
            set(_cdlxx_options /W3)
            set(_WERROR_FLAG /WX)
        endif()
    endif()

    # debug_print_hbar()
    # debug_print_value(_PROJ_NAME)
    # debug_print_value(_PROJ_SHORT_NAME)
    # debug_print_value(_MACRO_PREFIX)
    # debug_print_value(_CMAKE_GENERATED_DIR)
    # debug_print_value(_LIB_NAME)
    # debug_print_value(modname)
    # debug_print_value(_cxx_standard)
    # debug_print_value(_cxx_standard_mod)
    # debug_print_hbar()

    message("    * using _PROJ_NAME = ${_PROJ_NAME}")
    message("    * using _PROJ_SHORT_NAME = ${_PROJ_SHORT_NAME}")
    message("    * using _MACRO_PREFIX = ${_MACRO_PREFIX}")

    if(_CMAKE_GENERATED_DIR AND NOT EXISTS ${_CMAKE_GENERATED_DIR})
        file(MAKE_DIRECTORY ${_CMAKE_GENERATED_DIR})
    endif()

    getval(_main_inc_dirname cdlxx_ARG_INCLUDE_DIR_NAME ${modname})
    set(_MAIN_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
    set(_MOD_INCLUDE_DIR ${_MAIN_INCLUDE_DIR}/${modname})
    # debug_print_value(_main_inc_dirname)

    if(cdlxx_ARG_AUTOSCAN)
        # file(GLOB_RECURSE _SRCS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${_dir}/*.cppm ${_dir}/*.cc)
        file(GLOB_RECURSE _HEADERS RELATIVE ${CMAKE_SOURCE_DIR}
            ${_MOD_INCLUDE_DIR}/*.hh ${_MOD_INCLUDE_DIR}/*.inl)
        # debug_print_value(_MAIN_INCLUDE_DIR)
        # debug_print_list_value(_SRCS)
        # debug_print_list_value(_HEADERS)
    else()
        set(_HEADERS "")
    endif()

    # debug_print_value(ENABLE_CXX_MODULES)
    if(ENABLE_CXX_MODULES)
        message(STATUS ".. Building target '${modname}' as C++ module (SRC='')")
        set(SRCS "")
    else()
        file(GLOB_RECURSE SRCS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.cc *.cpp *.c++)
        message(STATUS ".. Building target '${modname}' as regular C++ source (SRC='${SRC}')")
    endif()

    #-------------------------------------------------------
    #    define CXX Module
    #-------------------------------------------------------
    add_library(${modname} STATIC ${SRCS})
    message(STATUS ">> defined cxx module '${modname}'.")

    if(cdlxx_ARG_MOD_ALIAS)
        foreach(alias ${cdlxx_ARG_MOD_ALIAS})
            add_library(${alias} ALIAS ${modname})
        endforeach()
        add_library(mods::${modname} ALIAS ${modname})
        message(STATUS "   defined mod alias 'mods::${modname}' & ${cdlxx_ARG_MOD_ALIAS}.")
    elseif(MAIN_MOD_ALIAS)
        add_library(${MAIN_MOD_ALIAS} ALIAS ${modname})
        add_library(mods::${modname} ALIAS ${modname})
        message(STATUS "   defined mod alias 'mods::${modname}' & '${MAIN_MOD_ALIAS}'.")
    endif()

    getval(_folder cdlxx_ARG_FOLDER "Mods")
    set_target_properties(${modname} PROPERTIES FOLDER "${_folder}")

    if(MSVC)
        if(NOT CMAKE_GENERATOR STREQUAL "Ninja")
            set(BMI_DIR "${CMAKE_CURRENT_BINARY_DIR}")
            file(TO_NATIVE_PATH "${BMI_DIR}/${modname}.ifc" BMI)
            target_compile_options(
                ${modname}
                PRIVATE /interface /ifcOutput ${BMI}
                INTERFACE /reference fmt=${BMI})
            set_target_properties(${modname} PROPERTIES ADDITIONAL_CLEAN_FILES ${BMI})
            set_source_files_properties(${BMI} PROPERTIES GENERATED ON)
        endif()
    endif()

    target_compile_features(${modname} PUBLIC cxx_std_${_cxx_standard_mod})
    add_cxx_standard_to(${modname} ${_cxx_standard_mod})
    set_target_properties(${modname} PROPERTIES CXX_MODULE_STD ${ENABLE_CXX_MODULES})
    target_compile_options(${modname} PUBLIC ${_cdlxx_options})
    target_compile_definitions(${modname} PUBLIC ${_cdlxx_definitions})
    if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_DEV_MODE=")
        target_compile_definitions(${modname} PRIVATE ENABLE_DEV_MODE=$<BOOL:${ENABLE_DEV_MODE}>)
    endif()
    if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_CXX_MODULES=")
        target_compile_definitions(${modname} PRIVATE ENABLE_CXX_MODULES=$<BOOL:${ENABLE_CXX_MODULES}>)
    endif()
    if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_HEADERS_ONLY=")
        target_compile_definitions(${modname} PRIVATE ENABLE_HEADERS_ONLY=$<BOOL:${cdlxx_ARG_USE_HEADERS}>)
    endif()
    if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_IMPORT_STD=")
        target_compile_definitions(${modname} PRIVATE ENABLE_IMPORT_STD=$<BOOL:${_enable_use_import_std}>)
    endif()
    if(NOT "${_cdlxx_definitions}" MATCHES "LOGX_ENABLED=")
        target_compile_definitions(${modname} PRIVATE ${_MACRO_PREFIX}LOGX_ENABLED=$<BOOL:${${_MACRO_PREFIX}LOGX_ENABLED}>)
    endif()
    if(NOT "${_cdlxx_definitions}" MATCHES "LOGX_AUTO_FLUSH=")
        target_compile_definitions(${modname} PRIVATE ${_MACRO_PREFIX}LOGX_AUTO_FLUSH=$<BOOL:${${_MACRO_PREFIX}LOGX_AUTO_FLUSH}>)
    endif()
    if(NOT "${_cdlxx_definitions}" MATCHES "LOGX_ENABLE_VERBOSE=")
        target_compile_definitions(${modname} PRIVATE ${_MACRO_PREFIX}LOGX_ENABLE_VERBOSE=$<BOOL:${${_MACRO_PREFIX}LOGX_ENABLE_VERBOSE}>)
    endif()

    target_compile_definitions(${modname}
        PRIVATE
        -D${_MACRO_PREFIX}LOGX_ENABLED=$<BOOL:${${_MACRO_PREFIX}LOGX_ENABLED}>
        -D${_MACRO_PREFIX}LOGX_AUTO_FLUSH=$<BOOL:${${_MACRO_PREFIX}LOGX_AUTO_FLUSH}>
        -D${_MACRO_PREFIX}LOGX_ENABLE_VERBOSE=$<BOOL:${${_MACRO_PREFIX}LOGX_ENABLE_VERBOSE}>
    )

    if(CMAKE_COMPILER_IS_GNUCXX)
        target_compile_options(${modname} PUBLIC
            -fmodules

            # -fsearch-include-path bits/std.cc

            # ignore decl in codes such as '[[clang::always_destroy]]'
            # -Wno-attributes
        )
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options(${modname} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>)
        target_link_options(${modname} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>)

        target_compile_options(${modname} PUBLIC
            $<$<COMPILE_LANGUAGE:CXX>:-Wno-import-implementation-partition-unit-in-interface-unit>
        )

        if(CMAKE_CXX_COMPILER_VERSION GREATER 16)
            target_compile_options(${modname} PUBLIC
                # Misnomer warning on module partitions
                # $<$<COMPILE_LANGUAGE:CXX>:-Wno-read-modules-implicitly>
            )
        endif()
    endif()

    if(cdlxx_ARG_INCLUDE_DIRS)
        target_include_directories(${modname}
            PUBLIC ${cdlxx_ARG_INCLUDE_DIRS}
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:$<CMAKE_CURRENT_BINARY_DIR>>
        )
    endif()
    target_include_directories(${modname}
        PUBLIC
        $<BUILD_INTERFACE:${_MAIN_INCLUDE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_GENERATED_DIR}>
        PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        # SYSTEM PRIVATE
        $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>
    )

    if(cdlxx_ARG_LIBRARIES)
        target_link_libraries(${modname} PRIVATE ${cdlxx_ARG_LIBRARIES})
    endif()
    if(cdlxx_ARG_LINK_DIRS)
        target_link_directories(${modname} PRIVATE ${cdlxx_ARG_LINK_DIRS})
    endif()

    if(ENABLE_CXX_MODULES)
        set(_cdlxx_base_dirs ${_base_dir})
        # debug_print_value(cdlxx_ARG_GRAB_AT)

        if(EXISTS ${_cdlxx_base_dirs}/modules)
            set(_cdlxx_mod_dir ${_cdlxx_base_dirs}/modules)
        else()
            set(_cdlxx_mod_dir ${_cdlxx_base_dirs})
        endif()
        if(cdlxx_ARG_FILES)
            # message("cdlxx_ARG_FILES = (${cdlxx_ARG_FILES})")
            set(_cdlxx_module_files ${cdlxx_ARG_FILES})
        elseif(cdlxx_ARG_AUTOSCAN OR cdlxx_ARG_GRAB_AT)
            file(GLOB_RECURSE _cdlxx_module_files
                # RELATIVE ${_cdlxx_mod_dir}
                ${_dir}/*.ccm ${_dir}/*.cppm ${_dir}/*.cxxm ${_dir}/*.c++m
                ${_dir}/*.ixx
            )
            # debug_print_list_value(_cdlxx_module_files)
        endif()

        if(cdlxx_ARG_IMPL_FILES)
            # message("cdlxx_ARG_IMPL_FILES = (${cdlxx_ARG_IMPL_FILES})")
            set(_cdlxx_impl_files ${cdlxx_ARG_IMPL_FILES})
            # debug_print_list_value(_cdlxx_impl_files)
        elseif(cdlxx_ARG_AUTOSCAN OR cdlxx_ARG_GRAB_AT)
            file(GLOB_RECURSE _cdlxx_impl_files
                # RELATIVE ${CMAKE_SOURCE_DIR}
                ${_dir}/*.cc ${_dir}/*.cpp ${_dir}/*.cxx ${_dir}/*.c++
            )
            # debug_print_list_value(_cdlxx_impl_files)
        endif()

        if(cdlxx_ARG_HEADERS)
            # message("cdlxx_ARG_HEADERS = (${cdlxx_ARG_HEADERS})")
            set(_cdlxx_header_files ${cdlxx_ARG_HEADERS})
        elseif(cdlxx_ARG_AUTOSCAN OR cdlxx_ARG_GRAB_AT)
            set(_inc_dir ${_MAIN_INCLUDE_DIR}/${_main_inc_dirname})
            file(GLOB_RECURSE _cdlxx_header_files # RELATIVE ${CMAKE_SOURCE_DIR}
                ${_inc_dir}/*.h ${_inc_dir}/*.hh
                ${_inc_dir}/*.hpp ${_inc_dir}/*.hxx
                ${_inc_dir}/*.inl
            )

            if(cdlxx_ARG_MAIN)
                set(_generated_headers ${GEN_VERSIONS_HEADERS})
            endif()

            foreach(item ${_PROJ_NAME}.hh ${_PROJ_SHORT_NAME}.hh ${_PROJ_SHORT_NAME}all.hh ${_PROJ_SHORT_NAME}-cxx.hh)
                if(EXISTS ${_MAIN_INCLUDE_DIR}/${item})
                    message(STATUS "   header file collected: ${item}")
                    list(APPEND _cdlxx_header_files ${_MAIN_INCLUDE_DIR}/${item})
                endif()
            endforeach()
            # debug_print_list_value(_cdlxx_header_files)
        endif()

        if(${modname} MATCHES "^[A-Z].*")
            set(_fileset_name "mod_${modname}_CXX_MODULES")
            # debug_print_value(_fileset_name)
        else()
            set(_fileset_name "${modname}_CXX_MODULES")
        endif()

        if(cdlxx_ARG_VERBOSE)
            debug_print_list_value(_cdlxx_module_files)
            debug_print_list_value(_cdlxx_impl_files)
            # debug_print_value(_dir)
            # debug_print_value(_cdlxx_base_dirs)
            debug_print_list_value(_cdlxx_header_files)
        endif()

        target_sources(${modname}
            PUBLIC
            FILE_SET CXX_MODULES TYPE CXX_MODULES
            BASE_DIRS ${_cdlxx_mod_dir}
            FILES ${_cdlxx_module_files}
        )

        if(cdlxx_ARG_USE_HEADERS)
            if(_generated_headers)
                target_sources(${modname}
                    PUBLIC
                    FILE_SET HEADERS TYPE HEADERS
                    BASE_DIRS ${GEN_VERSIONS_DIR}
                    FILES ${_generated_headers}
                )
            endif()

            if(_cdlxx_header_files)
                target_sources(${modname}
                    PUBLIC
                    FILE_SET HEADERS TYPE HEADERS
                    BASE_DIRS ${_MAIN_INCLUDE_DIR}
                    FILES ${_cdlxx_header_files}
                )
            endif()
        endif()

        if(_cdlxx_impl_files)
            # if(cdlxx_ARG_VERBOSE)
            #     debug_print_list_value(_cdlxx_impl_files)
            # endif()
            target_sources(${modname}
                PRIVATE
                ${_cdlxx_impl_files}
            )
        endif()

        if(cdlxx_ARG_MAIN OR cdlxx_ARG_VERSIONING)
            enable_versioning_for(
                ${modname}
                ${_PROJ_NAME}
                ${_PROJ_SHORT_NAME}
                ${_MACRO_PREFIX}
            )
        endif()
        if(cdlxx_ARG_PACK)
            enable_cpack(${modname})
        endif()
        if(cdlxx_ARG_INSTALL)
            # install(DIRECTORY ${_MOD_INCLUDE_DIR}/
            # 	DESTINATION include/${modname}
            # 	FILES_MATCHING PATTERN "*.hh" PATTERN "*.inl"
            # )
            install_library_targets(
                MAIN ${modname}
                MODULE
                PROJ_NAME ${_PROJ_NAME}
                PROJ_SHORT_NAME ${_PROJ_SHORT_NAME}
                MACRO_PREFIX ${_MACRO_PREFIX}
                INCLUDE_DIR ${_MAIN_INCLUDE_DIR}
                INCLUDE_DIR_NAME "${_main_inc_dirname}"
                # FIRST_INCLUDE_FILENAME ${_PROJ_NAME}.hh
            )
        endif()
    endif()

    if(cdlxx_ARG_DUAL)
        if(NOT _cdlxx_impl_files)
            if(cdlxx_ARG_IMPL_FILES)
                # message("cdlxx_ARG_IMPL_FILES = (${cdlxx_ARG_IMPL_FILES})")
                set(_cdlxx_impl_files ${cdlxx_ARG_IMPL_FILES})
            elseif(cdlxx_ARG_AUTOSCAN OR cdlxx_ARG_GRAB_AT)
                file(GLOB_RECURSE _cdlxx_impl_files RELATIVE ${CMAKE_SOURCE_DIR}
                    ${_dir}/*.cc ${_dir}/*.cpp ${_dir}/*.cxx ${_dir}/*.c++
                )
            endif()
        endif()

        #-------------------------------------------------------
        #  define xxx::xxx headers-only or static library
        #-------------------------------------------------------
        # message(STATUS "defining cxx headers-only lib '${_LIB_NAME}'.")
        if(_cdlxx_impl_files)
            if(cdlxx_ARG_SHARED)
                message(STATUS ">> defined shared cxx lib '${_LIB_NAME}'.")
                add_library(${_LIB_NAME} SHARED ${_cdlxx_impl_files})
            elseif(cdlxx_ARG_STATIC)
                message(STATUS ">> defined static cxx lib '${_LIB_NAME}' (files: ${_cdlxx_impl_files}).")
                add_library(${_LIB_NAME} STATIC ${_cdlxx_impl_files})
            elseif(cdlxx_ARG_INTERFACE)
                message(STATUS ">> defined interface cxx lib '${_LIB_NAME}'.")
                add_library(${_LIB_NAME} INTERFACE)
            else()
                add_library(${_LIB_NAME} ${_cdlxx_impl_files})
                message(STATUS ">> defined static cxx lib '${_LIB_NAME}'.")
            endif()
        else()
            add_library(${_LIB_NAME} INTERFACE ${_HEADERS})
            message(STATUS ">> defined cxx headers-only lib '${_LIB_NAME}' with ${_HEADERS}.")
        endif()

        getval(_folder cdlxx_ARG_FOLDER "Libs")
        set_target_properties(${_LIB_NAME} PROPERTIES FOLDER "${_folder}")
        # message(STATUS ">> ${_LIB_NAME}: folder '${_folder}'.")

        if(cdlxx_ARG_LIB_ALIAS)
            foreach(alias ${cdlxx_ARG_LIB_ALIAS})
                add_library(${alias} ALIAS ${_LIB_NAME})
            endforeach()
            add_library(libs::${_LIB_NAME} ALIAS ${_LIB_NAME})
            message(STATUS ".   defined lib alias 'libs::${_LIB_NAME}' & ${cdlxx_ARG_LIB_ALIAS}.")
            # elseif(MAIN_LIB_ALIAS)
            #     add_library(${MAIN_LIB_ALIAS} ALIAS ${_LIB_NAME})
            #     add_library(libs::${_LIB_NAME} ALIAS ${_LIB_NAME})
            #     message(STATUS ".   defined lib alias 'libs::${_LIB_NAME}' & '${MAIN_LIB_ALIAS}'.")
        endif()

        if(_cdlxx_impl_files AND NOT cdlxx_ARG_USE_HEADERS)
            set(key PRIVATE)
            set(keypub PUBLIC)
        else()
            set(key INTERFACE)
            set(keypub INTERFACE)
        endif()

        add_cxx_standard_to(${_LIB_NAME} ${_cxx_standard})

        target_compile_features(${_LIB_NAME} ${key} cxx_std_${_cxx_standard})

        target_compile_definitions(${_LIB_NAME} ${keypub} ${_cdlxx_definitions})
        if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_DEV_MODE=")
            target_compile_definitions(${_LIB_NAME} ${key} ENABLE_DEV_MODE=$<BOOL:${ENABLE_DEV_MODE}>)
        endif()
        if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_CXX_MODULES=")
            target_compile_definitions(${_LIB_NAME} ${key} ENABLE_CXX_MODULES=0)
        endif()
        if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_HEADERS_ONLY=")
            target_compile_definitions(${_LIB_NAME} ${key} ENABLE_HEADERS_ONLY=$<BOOL:${cdlxx_ARG_USE_HEADERS}>)
        endif()
        if(NOT "${_cdlxx_definitions}" MATCHES "ENABLE_IMPORT_STD=")
            target_compile_definitions(${_LIB_NAME} ${key} ENABLE_IMPORT_STD=$<BOOL:${_enable_use_import_std}>)
        endif()
        if(NOT "${_cdlxx_definitions}" MATCHES "LOGX_ENABLED=")
            target_compile_definitions(${_LIB_NAME} ${key} ${_MACRO_PREFIX}LOGX_ENABLED=$<BOOL:${${_MACRO_PREFIX}LOGX_ENABLED}>)
        endif()
        if(NOT "${_cdlxx_definitions}" MATCHES "LOGX_AUTO_FLUSH=")
            target_compile_definitions(${_LIB_NAME} ${key} ${_MACRO_PREFIX}LOGX_AUTO_FLUSH=$<BOOL:${${_MACRO_PREFIX}LOGX_AUTO_FLUSH}>)
        endif()
        if(NOT "${_cdlxx_definitions}" MATCHES "LOGX_ENABLE_VERBOSE=")
            target_compile_definitions(${_LIB_NAME} ${key} ${_MACRO_PREFIX}LOGX_ENABLE_VERBOSE=$<BOOL:${${_MACRO_PREFIX}LOGX_ENABLE_VERBOSE}>)
        endif()

        target_compile_options(${_LIB_NAME} ${keypub} ${_cdlxx_options})

        if(_cdlxx_impl_files AND NOT cdlxx_ARG_USE_HEADERS)
            target_include_directories(${_LIB_NAME}
                PUBLIC
                $<BUILD_INTERFACE:${_MAIN_INCLUDE_DIR}>
                $<BUILD_INTERFACE:${CMAKE_GENERATED_DIR}>
                PRIVATE
                $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                # SYSTEM PRIVATE
                $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>
            )
        else()
            target_include_directories(${_LIB_NAME}
                INTERFACE
                $<BUILD_INTERFACE:${_MAIN_INCLUDE_DIR}>
                $<BUILD_INTERFACE:${CMAKE_GENERATED_DIR}>
                $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                # SYSTEM PRIVATE
                $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>
            )
            target_sources(${PROJ_NAME} INTERFACE
                "$<BUILD_INTERFACE:${cdlxx_ARG_HEADERS};${cdlxx_ARG_DETAILED_HEADERS};${_generated_headers}>")
        endif()

        if(cdlxx_ARG_PACK)
            enable_cpack(${_LIB_NAME})
        endif()
        if(cdlxx_ARG_INSTALL)
            # install_library_targets(TARGETS ${_LIB_NAME})
            install_library_targets(
                MAIN ${_LIB_NAME}
                PROJ_NAME ${_PROJ_NAME}
                PROJ_SHORT_NAME ${_PROJ_SHORT_NAME}
                MACRO_PREFIX ${_MACRO_PREFIX}
                INCLUDE_DIR ${_MAIN_INCLUDE_DIR}
                INCLUDE_DIR_NAME "${_main_inc_dirname}"
                # FIRST_INCLUDE_FILENAME ${_PROJ_NAME}.hh
            )
        endif()
    endif()


    # if(${${PROJECT_MACRO_PREFIX}_ASAN_TEST} OR ${${PROJECT_MACRO_PREFIX}_TSAN_TEST})
    #     find_package(Sanitizers)
    #     add_sanitizers(${PROJ_NAME})
    # endif()

    # if(NOT diclp_ARG_FLEX AND NOT diclp_ARG_BISON)
    # else()
    #     debug_print_value(diclp_ARG_FLEX)
    #     debug_print_value(diclp_ARG_BISON)
    #     add_lexer_targets_to(${PROJ_NAME}
    #         FLEX ${diclp_ARG_FLEX}
    #         BISON ${diclp_ARG_BISON}
    #         ${diclp_ARG_UNPARSED_ARGUMENTS}
    #     )
    # endif()
endfunction()




#
# create dual libraries: a module lib and a header-only lib
#
function(create_cxx_dual_libs modname)
    define_lite_cxx_module(${ARGV})
endfunction()




#
# add_cxx_modules_support: for your target whom wanna
# consume a module library, this function would give
# you a more simple wrapping mechanism.
#
# For a instance,
#
#     add_cxx_modules_support(your_target
#         LIBRARIES our_module1 our_module2
#         # INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include
#     )
#
function(add_cxx_modules_support target)
    if(NOT TARGET ${target})
        return()
    endif()

    get_target_property(_xx_TARGET_TYPE ${target} TYPE)

    set(__acmsxx_PARAM_OPTIONS)
    set(__acmsxx_PARAM_ONE_VALUE_KEYWORDS
        PROJ_NAME
        CMAKE_GENERATED_DIR
        FOLDER
    )
    set(__acmsxx_PARAM_MULTI_VALUE_KEYWORDS
        CXXFLAGS # cxx compiler options
        CXXDEFINITIONS
        INCLUDE_DIRS
        LINK_DIRS
        LIBRARIES
        BASE_DIRS
        FILES
    )
    cmake_parse_arguments(
        acmsxx_ARG # Prefix
        "${__acmsxx_PARAM_OPTIONS}" # Options (keywords with no value, set to TRUE/FALSE)
        "${__acmsxx_PARAM_ONE_VALUE_KEYWORDS}" # One-value keywords (e.g., SINGLE_KW value)
        "${__acmsxx_PARAM_MULTI_VALUE_KEYWORDS}" # Multi-value keywords (e.g., MULTI_KW value1 value2 ...)
        ${ARGN} # Arguments to parse (all arguments passed to the macro)
    )
    set(define_cdlxx_usage "add_cxx_modules_support(<your-module-name>
     [PROJ_NAME <name>]                 # eg: cui, default is \${CMAKE_PROJECT_NAME}
     [CMAKE_GENERATED_DIR <dir>]        # eg: \${CMAKE_BINARY_DIR}/generated

     [CXXFLAGS <opt1>;<opt2>;...]       # eg: '-Wno-reserved-macro-identifier -Wno-reserved-identifier'
     [CXXDEFINITIONS <def1>;<def2>;...] # eg: 'DEBUG=1 NDEBUG=0'
     [INCLUDE_DIRS <dir1>;<dir2>;...]   # eg: '\${CMAKE_SOURCE_DIR}/include;./include'
     [LINK_DIRS <dir1>;<dir2>;...]      # eg: '\${CMAKE_SOURCE_DIR}/lib;./lib'
     [LIBRARIES <lib1>;<lib2>;...]      # eg: 'std;std::compat'
     [BASE_DIRS <dir1;dir2;...>]        # module's base dirctories
     [FILES ...]                        # module's files
     )
     
     Unparsed Params Are:
     ${acmsxx_ARG_UNPARSED_ARGUMENTS}")

    set(_PROJ_NAME ${acmsxx_ARG_PROJ_NAME})
    set(_CMAKE_GENERATED_DIR ${acmsxx_ARG_CMAKE_GENERATED_DIR})

    if(_CMAKE_GENERATED_DIR AND NOT _CMAKE_GENERATED_DIR STREQUAL "")
        set(CMAKE_GENERATED_DIR "${_CMAKE_GENERATED_DIR}")
        file(MAKE_DIRECTORY ${_CMAKE_GENERATED_DIR})
    else()
        set(_CMAKE_GENERATED_DIR "${CMAKE_BINARY_DIR}/generated")
        set(CMAKE_GENERATED_DIR "${_CMAKE_GENERATED_DIR}")
        file(MAKE_DIRECTORY ${_CMAKE_GENERATED_DIR})
    endif()

    if(acmsxx_ARG_CXXFLAGS)
        set(_acmsxx_options "${acmsxx_ARG_CXXFLAGS}")
    else()
        if(CMAKE_COMPILER_IS_GNUCXX)
            set(_cdlxx_options
                -pedantic -Wall -Wextra -Wshadow -Werror -pthread
                -Wdeprecated-declarations
            )
        else()
            set(_cdlxx_options
                -fsafe-buffer-usage-suggestions
                -Wno-reserved-macro-identifier
                -Wno-reserved-identifier
                -Wno-c++98-compat-pedantic
            )
        endif()
    endif()
    if(acmsxx_ARG_CXXDEFINITIONS)
        target_compile_definitions(${target}
            PRIVATE ${acmsxx_ARG_CXXDEFINITIONS}
        )
    endif()

    target_compile_features(${target} PUBLIC cxx_std_23)
    add_cxx_standard_to(${target} 23)

    if(ENABLE_CXX_MODULES)
        # set_target_properties(${target} PROPERTIES
        #     CXX_MODULE_STD ${ENABLE_CXX_MODULES}
        # )

        # if(_xx_TARGET_TYPE STREQUAL "EXECUTABLE")

        if(CMAKE_COMPILER_IS_GNUCXX)
            target_compile_options(${target} PUBLIC
                -fmodules
                # -fsearch-include-path bits/std.cc

                # ignore decl in codes such as '[[clang::always_destroy]]'
                -Wno-attributes
                ${_acmsxx_options}
            )
            # target_compile_options(${target} PUBLIC -fmodules-ts)
        elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            target_compile_options(${target} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>)
            target_link_options(${target} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>)

            if(CMAKE_CXX_COMPILER_VERSION GREATER 16)
                target_compile_options(${target} PUBLIC
                    # Misnomer warning on module partitions
                    # $<$<COMPILE_LANGUAGE:CXX>:-Wno-read-modules-implicitly>
                    ${_acmsxx_options}
                )
            endif()
        endif()

        # if(TARGET dummy_std_target)
        #     add_dependencies(${target} dummy_std_target)
        #     message(NOTICE ". add deps 'dummy_std_target' to target ${target}.")
        # endif()
    endif()
    # target_compile_options(${target} PUBLIC ${_acmsxx_options})

    if(acmsxx_ARG_INCLUDE_DIRS)
        target_include_directories(${target}
            PRIVATE ${acmsxx_ARG_INCLUDE_DIRS}
        )
    else()
        target_include_directories(${target}
            PUBLIC
            ${CMAKE_SOURCE_DIR}/include
            ${CMAKE_GENERATED_DIR}
            PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}/include
        )
    endif()
    if(acmsxx_ARG_LIBRARIES)
        target_link_libraries(${target}
            PRIVATE ${acmsxx_ARG_LIBRARIES}
        )
    endif()
    if(acmsxx_ARG_LINK_DIRS)
        target_link_directories(${target}
            PRIVATE ${acmsxx_ARG_LINK_DIRS}
        )
    endif()


    # Check if the retrieved type is "EXECUTABLE"
    if(_xx_TARGET_TYPE STREQUAL "EXECUTABLE")
        if(acmsxx_ARG_FOLDER)
            set_target_properties(${target} PROPERTIES FOLDER "${acmsxx_ARG_FOLDER}")
        else()
            set_target_properties(${target} PROPERTIES FOLDER "Tests")
        endif()
        if(acmsxx_ARG_TEST)
            add_test(NAME ${target}
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                COMMAND $<TARGET_FILE:${target}>)
        endif()
    else()
        set_target_properties(${target} PROPERTIES FOLDER "Libs")
        if(acmsxx_ARG_BASE_DIRS)
            set(_acmsxx_base_dirs ${acmsxx_ARG_BASE_DIRS})
        else()
            set(_acmsx_base_dirs ${CMAKE_SOURCE_DIR})
        endif()

        if(acmsxx_ARG_FILES)
            set(_acmsxx_base_files ${acmsxx_ARG_FILES})
            set(_acmsxx_impl_files "")
        else()
            set(_dir ${CMAKE_CURRENT_SOURCE_DIR})
            file(GLOB_RECURSE _acmsxx_base_files
                RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
                ${_dir}/*.ccm ${_dir}/*.cppm ${_dir}/*.cxxm ${_dir}/*.c++m
                ${_dir}/*.ixx
            )
            file(GLOB_RECURSE _acmsxx_impl_files
                ${_dir}/*.cc
            )
        endif()

        target_sources(${target} PUBLIC
            FILE_SET ${target}_CXX_MODULES TYPE CXX_MODULES
            BASE_DIRS
            ${_acmsxx_base_dirs}
            FILES
            ${_acmsxx_base_files}
            PRIVATE
            ${_acmsxx_impl_files}
        )
    endif()
endfunction()

#
#
#
#
#
#

######## setup enable-cxx-modules ######################################

#message(NOTICE "......................................")
#cmake_path(GET CMAKE_CXX_COMPILER PARENT_PATH CXX_BIN_DIR)
#cmake_path(GET CXX_BIN_DIR PARENT_PATH CXX_DIR)
#message(NOTICE " . Using CMake ${CMAKE_VERSION}")
#message(NOTICE " . Using C++ Compiler: ${CMAKE_CXX_COMPILER_ID} / ${CMAKE_CXX_COMPILER_VERSION}")
#message(NOTICE " .               path: ${CMAKE_CXX_COMPILER}")
#message(NOTICE " .               root: ${CXX_DIR}")

# set(_enable_cxx_module OFF)
# if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.30 OR CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
#     message(NOTICE " . CMake version ${CMAKE_VERSION} >= 3.30, cxx-modules enabled (${CMAKE_CXX_COMPILER_ID}).")
#     if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
#         # using llvm, work for cxx-modules but clion has a little matter
#         set(_enable_cxx_module ON)
#     elseif(CMAKE_COMPILER_IS_GNUCXX) # (CMAKE_CXX_COMPILER_ID MATCHES "GNU|GCC")
#         # GCC 15+: std module enabled
#         set(_enable_cxx_module ON)
#     endif()
# else()
#     message(NOTICE " . CMake version ${CMAKE_VERSION} < 3.30, cxx-modules disabled.")
# endif()
# option(ENABLE_CXX_MODULES "enable cxx module building ${_enable_cxx_module} for cmake ${CMAKE_VERSION} + ${CMAKE_CXX_COMPILER_ID}" ${_enable_cxx_module})
# message(NOTICE " .  ENABLE_CXX_MODULES: ${ENABLE_CXX_MODULES}    # for cmake ${CMAKE_VERSION} + ${CMAKE_CXX_COMPILER_ID}")
# message(NOTICE "......................................")
# #message(NOTICE "| ENABLE_CXX_MODULES             = ${ENABLE_CXX_MODULES}")

########

if(ENABLE_CXX_MODULES)


    set(CMAKE_CXX_SCAN_FOR_MODULES ${ENABLE_CXX_MODULES})


    #set(CMAKE_CXX_SCAN_FOR_MODULES ON)
    set(CMAKE_CXX_STANDARD 23) # or 20
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF) # Optional: enforce strict C++23
    #set_property(TARGET ${PROJ_NAME} PROPERTY CXX_EXTENSIONS OFF) # Optional: enforce strict C++23
    set(CMAKE_CXX_MODULE_STD ${ENABLE_CXX_MODULES}) # Requires CMake 3.30+
    # # Turning off extensions avoids an issue with the clang 16 compiler
    # # clang 17 and greater can avoid this setting
    # set(CMAKE_CXX_EXTENSIONS OFF)
    # set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${CXX_DIR}/bin/clang-scan-deps")




    # for macOS and brew LLVM compiler, fixing CMAKE_CXX_STDLIB_MODULES_JSON
    # for macOS and LLVM Compiler, fix `import std` error on cmake configuring:
    #
    #     set CMAKE_CXX_STDLIB_MODULES_JSON to "${CXX_DIR}/lib/c++/libc++.modules.json" from command line:
    #
    # A sample command line:
    #
    #     # /opt/homebrew/bin/cmake -DCMAKE_BUILD_TYPE:STRING=Debug \
    #          -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    #          -DCMAKE_C_COMPILER:FILEPATH=/opt/homebrew/opt/llvm@21/bin/clang \
    #          -DCMAKE_CC_COMPILER:FILEPATH=/opt/homebrew/opt/llvm@21/bin/clang \
    #          -DCMAKE_CXX_COMPILER:FILEPATH=/opt/homebrew/opt/llvm@21/bin/clang++ \
    #          -DCMAKE_CXX_STDLIB_MODULES_JSON:STRING=/opt/homebrew/opt/llvm@21/lib/c++/libc++.modules.json \
    #          --no-warn-unused-cli \
    #          -Wno-unused-cli \
    #          -S ../cuilib -B ../cuilib/build \
    #          -G "Ninja Multi-Config"
    #
    # NOTE that it cannot take effect if set here in CMakeLists.txt, has to be set from command line or cmake-gui or vscode cmake-kits.json
    #
    # if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    #   # set(CMAKE_CXX_STANDARD_LIBRARIES "-L/opt/homebrew/opt/llvm@21/lib -lc++ -lc++abi")
    #   # set(CMAKE_CXX_STANDARD_LIBRARIES "-L/opt/homebrew/opt/llvm@21/lib -lc++ -lc++abi -lm")
    #   set(CMAKE_CXX_STDLIB_MODULES_JSON "${CXX_DIR}/lib/c++/libc++.modules.json" CACHE FILEPATH "" FORCE)
    #   message(NOTICE " . Using custom CMAKE_CXX_STDLIB_MODULES_JSON: ${CMAKE_CXX_STDLIB_MODULES_JSON}")
    # endif()
    #
    #
    # Specially for CLion, add the following args to your CMake Options (if you're using default homebrew llvm copy):
    #   -DCMAKE_CXX_STDLIB_MODULES_JSON="/opt/homebrew/opt/llvm/lib/c++/libc++.modules.json"
    # 如果在 CLion 环境遇到找不到 libc++.modules.json 的错误，则应在 CMake Config 设置
    # 中添加上面所示的参数到附加 Options 中（CLion 没有正确处理 brew-llvm env file 中预
    # 设的 CMAKE_CXX_STDLIB_MODULES_JSON 值）。
    #
    message(NOTICE " . Using CMAKE_CXX_STDLIB_MODULES_JSON: ${CMAKE_CXX_STDLIB_MODULES_JSON}")

    # for macOS and LLVM Conpiler, fix `import std` error on cmake configuring:
    #
    #     ln -s $(brew --prefix)/etc/clang ~/.config/clang
    #
    # It has no effect for cmake 4.2.2.

    # # macOS LLVM needs to specify libc++
    # if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    #   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ ")
    # endif()

    if(${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin" OR APPLE)
        message(" . Darwin/Apple/macOS detected.")
        set(DEFAULT_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
    endif()

endif()
