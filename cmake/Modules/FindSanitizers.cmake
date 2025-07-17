# The MIT License (MIT)
#
# Copyright (c)
#   2013 Matthew Arsenault
#   2015-2016 RWTH Aachen University, Federal Republic of Germany
#.  2025-2030 hedzr repacked as a single file, made it work for darwin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



# cmake_minimum_required(VERSION 3.13)	# target_link_options()


#
# USAGE:
#
#    set(SANITIZE_ADDRESS TRUE)
#    set(SANITIZE_MEMORY TRUE)
#    set(SANITIZE_THREAD TRUE)
#    set(SANITIZE_UNDEFINED TRUE)
#
#    #
#    # search for sanitizers
#    #
#    find_package(Sanitizers)
#
#    # for your target:
#    set(TESTNAME "test-1")
#    set(SOURCEFILES test-1.cc common.cc)
#    add_executable(${TESTNAME} ${SOURCEFILES})
#    add_test(${TESTNAME} ${TESTNAME})
#    add_sanitizers(${TESTNAME})
#
# ASAN ------------------
#
# AddressSanitizer (ASan) is a fast compiler-based tool for detecting memory bugs in native code.
#
# ASan detects:
#
#   - Stack and heap buffer overflow/underflow
#   - Heap use after free
#   - Stack use outside scope
#   - Double free/wild free
#
# When using param detect_leaks=1, ASan can detect memory leak at same time:
#
#   $ ASAN_OPTIONS=detect_leaks=1 ./bin/demo2
#
# MSAN ------------------
#
# MemorySanitizer (MSan) is a detector of uninitialized memory reads in C/C++ programs.
#
# TSAN ------------------
#
# ThreadSanitizer is a fast data race detector for C/C++ and Go.
#
# USAN / UBSan ------------------
#
# UndefinedBehaviorSanitizer (UBSan) is a fast undefined behavior detector.
# UBSan modifies the program at compile-time to catch various kinds of
# undefined behavior during program execution, for example:
#   
#   - Array subscript out of bounds, where the bounds can be statically determined
#   - Bitwise shifts that are out of bounds for their data type
#   - Dereferencing misaligned or null pointers
#   - Signed integer overflow
#   - Conversion to, from, or between floating-point types which would overflow the destination
#
#
# See also:
#   - https://github.com/google/sanitizers
#   - https://github.com/google/sanitizers/wiki/addresssanitizer
#   - https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
#   - https://clang.llvm.org/docs/DataFlowSanitizer.html
#     - https://clang.llvm.org/docs/DataFlowSanitizerDesign.html
#   - https://clang.llvm.org/docs/ThreadSanitizer.html
#   - https://clang.llvm.org/docs/MemorySanitizer.html
#   - https://clang.llvm.org/docs/AddressSanitizer.html
#
# extras:
#   - https://github.com/LouisBrunner/valgrind-macos
#   - https://github.com/Toxe/cpp-sanitizers
#


# If any of the used compiler is a GNU compiler, add a second option to static
# link against the sanitizers.
option(SANITIZE_LINK_STATIC "Try to link static against sanitizers." Off)

# Highlight this module has been loaded.
set(Sanitizers_FOUND TRUE)

set(FIND_QUIETLY_FLAG "")
if(DEFINED Sanitizers_FIND_QUIETLY)
    set(FIND_QUIETLY_FLAG "QUIET")
endif()


##

## HELPERS

##

# Helper function to get the language of a source file.
function(sanitizer_lang_of_source FILE RETURN_VAR)
    get_filename_component(LONGEST_EXT "${FILE}" EXT)
    # If extension is empty return. This can happen for extensionless headers
    if("${LONGEST_EXT}" STREQUAL "")
        set(${RETURN_VAR} "" PARENT_SCOPE)
        return()
    endif()
    # Get shortest extension as some files can have dot in their names
    string(REGEX REPLACE "^.*(\\.[^.]+)$" "\\1" FILE_EXT ${LONGEST_EXT})
    string(TOLOWER "${FILE_EXT}" FILE_EXT)
    string(SUBSTRING "${FILE_EXT}" 1 -1 FILE_EXT)

    get_property(ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
    foreach(LANG ${ENABLED_LANGUAGES})
        list(FIND CMAKE_${LANG}_SOURCE_FILE_EXTENSIONS "${FILE_EXT}" TEMP)
        if(NOT ${TEMP} EQUAL -1)
            set(${RETURN_VAR} "${LANG}" PARENT_SCOPE)
            return()
        endif()
    endforeach()

    set(${RETURN_VAR} "" PARENT_SCOPE)
endfunction()


# Helper function to get compilers used by a target.
function(sanitizer_target_compilers TARGET RETURN_VAR)
    # Check if all sources for target use the same compiler. If a target uses
    # e.g. C and Fortran mixed and uses different compilers (e.g. clang and
    # gfortran) this can trigger huge problems, because different compilers may
    # use different implementations for sanitizers.
    set(BUFFER "")
    get_target_property(TSOURCES ${TARGET} SOURCES)
    foreach(FILE ${TSOURCES})
        # If expression was found, FILE is a generator-expression for an object
        # library. Object libraries will be ignored.
        string(REGEX MATCH "TARGET_OBJECTS:([^ >]+)" _file ${FILE})
        if("${_file}" STREQUAL "")
            sanitizer_lang_of_source(${FILE} LANG)
            if(LANG)
                list(APPEND BUFFER ${CMAKE_${LANG}_COMPILER_ID})
            endif()
        endif()
    endforeach()

    list(REMOVE_DUPLICATES BUFFER)
    set(${RETURN_VAR} "${BUFFER}" PARENT_SCOPE)
endfunction()


# Helper function to check compiler flags for language compiler.
function(sanitizer_check_compiler_flag FLAG LANG VARIABLE)

    if(${LANG} STREQUAL "C")
        include(CheckCCompilerFlag)
        check_c_compiler_flag("${FLAG}" ${VARIABLE})

    elseif(${LANG} STREQUAL "CXX")
        include(CheckCXXCompilerFlag)
        check_cxx_compiler_flag("${FLAG}" ${VARIABLE})

    elseif(${LANG} STREQUAL "Fortran")
        # CheckFortranCompilerFlag was introduced in CMake 3.x. To be compatible
        # with older Cmake versions, we will check if this module is present
        # before we use it. Otherwise we will define Fortran coverage support as
        # not available.
        include(CheckFortranCompilerFlag OPTIONAL RESULT_VARIABLE INCLUDED)
        if(INCLUDED)
            check_fortran_compiler_flag("${FLAG}" ${VARIABLE})
        elseif(NOT CMAKE_REQUIRED_QUIET)
            message(STATUS "Performing Test ${VARIABLE}")
            message(STATUS "Performing Test ${VARIABLE}"
                " - Failed (Check not supported)")
        endif()
    endif()

endfunction()


# Helper function to test compiler flags.
function(sanitizer_check_compiler_flags FLAG_CANDIDATES NAME PREFIX)
    set(CMAKE_REQUIRED_QUIET ${${PREFIX}_FIND_QUIETLY})

    get_property(ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
    foreach(LANG ${ENABLED_LANGUAGES})
        # Sanitizer flags are not dependend on language, but the used compiler.
        # So instead of searching flags foreach language, search flags foreach
        # compiler used.
        set(COMPILER ${CMAKE_${LANG}_COMPILER_ID})
        if(COMPILER AND NOT DEFINED ${PREFIX}_${COMPILER}_FLAGS)
            foreach(FLAG ${FLAG_CANDIDATES})
                if(NOT CMAKE_REQUIRED_QUIET)
                    message(STATUS "Try ${COMPILER} ${NAME} flag = [${FLAG}]")
                endif()

                set(CMAKE_REQUIRED_FLAGS "${FLAG}")
                unset(${PREFIX}_FLAG_DETECTED CACHE)
                sanitizer_check_compiler_flag("${FLAG}" ${LANG}
                    ${PREFIX}_FLAG_DETECTED)

                if(${PREFIX}_FLAG_DETECTED)
                    # If compiler is a GNU compiler, search for static flag, if
                    # SANITIZE_LINK_STATIC is enabled.
                    if(SANITIZE_LINK_STATIC AND (${COMPILER} STREQUAL "GNU"))
                        string(TOLOWER ${PREFIX} PREFIX_lower)
                        sanitizer_check_compiler_flag(
                            "-static-lib${PREFIX_lower}" ${LANG}
                            ${PREFIX}_STATIC_FLAG_DETECTED)

                        if(${PREFIX}_STATIC_FLAG_DETECTED)
                            set(FLAG "-static-lib${PREFIX_lower} ${FLAG}")
                        endif()
                    endif()

                    set(${PREFIX}_${COMPILER}_FLAGS "${FLAG}" CACHE STRING
                        "${NAME} flags for ${COMPILER} compiler.")
                    mark_as_advanced(${PREFIX}_${COMPILER}_FLAGS)
                    break()
                endif()
            endforeach()

            if(NOT ${PREFIX}_FLAG_DETECTED)
                set(${PREFIX}_${COMPILER}_FLAGS "" CACHE STRING
                    "${NAME} flags for ${COMPILER} compiler.")
                mark_as_advanced(${PREFIX}_${COMPILER}_FLAGS)

                message(WARNING "${NAME} is not available for ${COMPILER} "
                    "compiler. Targets using this compiler will be "
                    "compiled without ${NAME}.")
            endif()
        endif()
    endforeach()
endfunction()


# Helper to assign sanitizer flags for TARGET.
function(sanitizer_add_flags TARGET NAME PREFIX)
    # Get list of compilers used by target and check, if sanitizer is available
    # for this target. Other compiler checks like check for conflicting
    # compilers will be done in add_sanitizers function.
    sanitizer_target_compilers(${TARGET} TARGET_COMPILER)
    list(LENGTH TARGET_COMPILER NUM_COMPILERS)
    if("${${PREFIX}_${TARGET_COMPILER}_FLAGS}" STREQUAL "")
        return()
    endif()

    separate_arguments(flags_list UNIX_COMMAND "${${PREFIX}_${TARGET_COMPILER}_FLAGS} ${SanBlist_${TARGET_COMPILER}_FLAGS}")
    target_compile_options(${TARGET} PUBLIC ${flags_list})

    separate_arguments(flags_list UNIX_COMMAND "${${PREFIX}_${TARGET_COMPILER}_FLAGS}")
    target_link_options(${TARGET} PUBLIC ${flags_list})

endfunction()


##


##


## ASAN - work for darwin


option(SANITIZE_ADDRESS "Enable AddressSanitizer for sanitized targets." Off)

set(FLAG_CANDIDATES
    # MSVC uses
    "/fsanitize=address"

    # Clang 3.2+ use this version. The no-omit-frame-pointer option is optional.
    "-g -fsanitize=address -fno-omit-frame-pointer"
    "-g -fsanitize=address"

    # Older deprecated flag for ASan
    "-g -faddress-sanitizer"
)


if(SANITIZE_ADDRESS AND (SANITIZE_THREAD OR SANITIZE_MEMORY))
    message(FATAL_ERROR "AddressSanitizer is not compatible with "
        "ThreadSanitizer or MemorySanitizer.")
endif()


# include(sanitize-helpers)

if(SANITIZE_ADDRESS)
    sanitizer_check_compiler_flags("${FLAG_CANDIDATES}" "AddressSanitizer"
        "ASan")

    find_program(ASan_WRAPPER "asan-wrapper" PATHS ${CMAKE_MODULE_PATH})
    mark_as_advanced(ASan_WRAPPER)
endif()

function(add_sanitize_address TARGET)
    if(NOT SANITIZE_ADDRESS)
        return()
    endif()

    sanitizer_add_flags(${TARGET} "AddressSanitizer" "ASan")
endfunction()


## MSAN


option(SANITIZE_MEMORY "Enable MemorySanitizer for sanitized targets." Off)

set(FLAG_CANDIDATES
    # MSVC uses
    "/fsanitize=memory"
    # GNU/Clang
    "-g -fsanitize=memory"
)


# include(sanitize-helpers)

if(SANITIZE_MEMORY)
    if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        message(WARNING "MemorySanitizer disabled for target ${TARGET} because "
            "MemorySanitizer is supported for Linux systems only.")
        set(SANITIZE_MEMORY Off CACHE BOOL
            "Enable MemorySanitizer for sanitized targets." FORCE)
    elseif(NOT ${CMAKE_SIZEOF_VOID_P} EQUAL 8)
        message(WARNING "MemorySanitizer disabled for target ${TARGET} because "
            "MemorySanitizer is supported for 64bit systems only.")
        set(SANITIZE_MEMORY Off CACHE BOOL
            "Enable MemorySanitizer for sanitized targets." FORCE)
    else()
        sanitizer_check_compiler_flags("${FLAG_CANDIDATES}" "MemorySanitizer"
            "MSan")
    endif()
endif()

function(add_sanitize_memory TARGET)
    if(NOT SANITIZE_MEMORY)
        return()
    endif()

    sanitizer_add_flags(${TARGET} "MemorySanitizer" "MSan")
endfunction()


## TSAN


option(SANITIZE_THREAD "Enable ThreadSanitizer for sanitized targets." Off)

set(FLAG_CANDIDATES
    # MSVC uses
    "/fsanitize=thread"
    # GNU/Clang
    "-g -fsanitize=thread"
)


# ThreadSanitizer is not compatible with MemorySanitizer.
if(SANITIZE_THREAD AND SANITIZE_MEMORY)
    message(FATAL_ERROR "ThreadSanitizer is not compatible with "
        "MemorySanitizer.")
endif()


# include(sanitize-helpers)

if(SANITIZE_THREAD)
    if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND
        NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        message(WARNING "ThreadSanitizer disabled for target ${TARGET} because "
            "ThreadSanitizer is supported for Linux systems and macOS only.")
        set(SANITIZE_THREAD Off CACHE BOOL
            "Enable ThreadSanitizer for sanitized targets." FORCE)
    elseif(NOT ${CMAKE_SIZEOF_VOID_P} EQUAL 8)
        message(WARNING "ThreadSanitizer disabled for target ${TARGET} because "
            "ThreadSanitizer is supported for 64bit systems only.")
        set(SANITIZE_THREAD Off CACHE BOOL
            "Enable ThreadSanitizer for sanitized targets." FORCE)
    else()
        sanitizer_check_compiler_flags("${FLAG_CANDIDATES}" "ThreadSanitizer"
            "TSan")
    endif()
endif()

function(add_sanitize_thread TARGET)
    if(NOT SANITIZE_THREAD)
        return()
    endif()

    sanitizer_add_flags(${TARGET} "ThreadSanitizer" "TSan")
endfunction()


## USAN


option(SANITIZE_UNDEFINED
    "Enable UndefinedBehaviorSanitizer for sanitized targets." Off)

set(FLAG_CANDIDATES
    # MSVC uses
    "/fsanitize=undefined"
    # GNU/Clang
    "-g -fsanitize=undefined"
)


# include(sanitize-helpers)

if(SANITIZE_UNDEFINED)
    sanitizer_check_compiler_flags("${FLAG_CANDIDATES}"
        "UndefinedBehaviorSanitizer" "UBSan")
endif()

function(add_sanitize_undefined TARGET)
    if(NOT SANITIZE_UNDEFINED)
        return()
    endif()

    sanitizer_add_flags(${TARGET} "UndefinedBehaviorSanitizer" "UBSan")
endfunction()


##

##


########################################################



# # If any of the used compiler is a GNU compiler, add a second option to static
# # link against the sanitizers.
# option(SANITIZE_LINK_STATIC "Try to link static against sanitizers." Off)

# # Highlight this module has been loaded.
# set(Sanitizers_FOUND TRUE)

# set(FIND_QUIETLY_FLAG "")
# if(DEFINED Sanitizers_FIND_QUIETLY)
#     set(FIND_QUIETLY_FLAG "QUIET")
# endif()

# find_package(ASan ${FIND_QUIETLY_FLAG})
# find_package(TSan ${FIND_QUIETLY_FLAG})
# find_package(MSan ${FIND_QUIETLY_FLAG})
# find_package(UBSan ${FIND_QUIETLY_FLAG})

function(sanitizer_add_blacklist_file FILE)
    if(NOT IS_ABSOLUTE ${FILE})
        set(FILE "${CMAKE_CURRENT_SOURCE_DIR}/${FILE}")
    endif()
    get_filename_component(FILE "${FILE}" REALPATH)

    sanitizer_check_compiler_flags("-fsanitize-blacklist=${FILE}"
        "SanitizerBlacklist" "SanBlist")
endfunction()

function(add_sanitizers)
    # If no sanitizer is enabled, return immediately.
    if(NOT (SANITIZE_ADDRESS OR SANITIZE_MEMORY OR SANITIZE_THREAD OR
             SANITIZE_UNDEFINED))
        return()
    endif()

    foreach(TARGET ${ARGV})
        # Check if this target will be compiled by exactly one compiler. Other-
        # wise sanitizers can't be used and a warning should be printed once.
        get_target_property(TARGET_TYPE ${TARGET} TYPE)
        if(TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
            message(WARNING "Can't use any sanitizers for target ${TARGET}, "
                "because it is an interface library and cannot be "
                "compiled directly.")
            return()
        endif()
        sanitizer_target_compilers(${TARGET} TARGET_COMPILER)
        list(LENGTH TARGET_COMPILER NUM_COMPILERS)
        if(NUM_COMPILERS GREATER 1)
            message(WARNING "Can't use any sanitizers for target ${TARGET}, "
                "because it will be compiled by incompatible compilers. "
                "Target will be compiled without sanitizers.")
            return()

        elseif(NUM_COMPILERS EQUAL 0)
            # If the target is compiled by no known compiler, give a warning.
            message(WARNING "Sanitizers for target ${TARGET} may not be"
                " usable, because it uses no or an unknown compiler. "
                "This is a false warning for targets using only "
                "object lib(s) as input.")
        endif()

        # Add sanitizers for target.
        add_sanitize_address(${TARGET})
        add_sanitize_thread(${TARGET})
        add_sanitize_memory(${TARGET})
        add_sanitize_undefined(${TARGET})
    endforeach()
endfunction(add_sanitizers)

