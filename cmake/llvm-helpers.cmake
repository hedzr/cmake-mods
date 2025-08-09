# llvm-helper:
#
#    - `add_llvm_target`, `add_llvm_test_target`
#      - `add_llvm_supports`
#        - `define_basics_llvm_target`
#          - `llvm_config`
#

find_package(LLVM REQUIRED CONFIG)
message(STATUS "---- Found LLVM ${LLVM_PACKAGE_VERSION} at ${LLVM_TOOLS_BINARY_DIR}")
message(STATUS "---- Using LLVMConfig.cmake in: ${LLVM_DIR}")
message(STATUS "---- Using LLVM_CMAKE_DIR: ${LLVM_CMAKE_DIR}")
message(STATUS "---- Using LLVM_DEFINITIONS: ${LLVM_DEFINITIONS}")
message(STATUS "---- Using LLVM_ENABLE_EXCEPTION: ${LLVM_ENABLE_EXCEPTION}")
message(STATUS "---- Using LLVM_ENABLE_RTTI: ${LLVM_ENABLE_RTTI}")
list(APPEND CMAKE_MODULE_PATH ${LLVM_CMAKE_DIR})

# use a llvm macro/function, including its cmake components at first
include(AddLLVM)

#llvm-config --cxxflags
# add_compile_options(-I/opt/homebrew/opt/llvm/include -I./llvm/build/include -std=c++17
# -fno-exceptions -fno-rtti -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS)

#llvm-config --ldflags
# LINK_LIBRARIES(-L/opt/homebrew/opt/llvm/lib -Wl,-search_paths_first -Wl,-headerpad_max_install_names)

#llvm-config --system-libs
# LINK_LIBRARIES(-lz -lcurses -lm -lxml2)

#llvm-config --libs
# LINK_LIBRARIES(-lLLVMSymbolize -lLLVMDebugInfoPDB -lLLVMCoverage
#         -lLLVMDlltoolDriver -lLLVMOrcJIT -lLLVMTestingSupport
#         -lLLVMMCA -lLLVMWindowsManifest -lLLVMTextAPI -lLLVMFuzzMutate
#         -lLLVMMCJIT -lLLVMCoroutines -lLLVMRemarks -lLLVMLTO
#         -lLLVMPasses -lLLVMObjCARCOpts -lLLVMTableGen -lLLVMXRay
#         -lLLVMXCoreDisassembler -lLLVMXCoreCodeGen -lLLVMXCoreDesc
#         -lLLVMXCoreInfo -lLLVMXCoreAsmPrinter -lLLVMX86Disassembler
#         -lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMX86Desc -lLLVMX86Info
#         -lLLVMX86AsmPrinter -lLLVMX86Utils -lLLVMWebAssemblyDisassembler
#         -lLLVMWebAssemblyCodeGen -lLLVMWebAssemblyDesc
#         -lLLVMWebAssemblyAsmPrinter -lLLVMWebAssemblyAsmParser -lLLVMWebAssemblyInfo
#         -lLLVMSystemZDisassembler -lLLVMSystemZCodeGen
#         -lLLVMSystemZAsmParser -lLLVMSystemZDesc -lLLVMSystemZInfo
#         -lLLVMSystemZAsmPrinter -lLLVMSparcDisassembler -lLLVMSparcCodeGen
#         -lLLVMSparcAsmParser -lLLVMSparcDesc -lLLVMSparcInfo
#         -lLLVMSparcAsmPrinter -lLLVMPowerPCDisassembler -lLLVMPowerPCCodeGen
#         -lLLVMPowerPCAsmParser -lLLVMPowerPCDesc -lLLVMPowerPCInfo
#         -lLLVMPowerPCAsmPrinter -lLLVMNVPTXCodeGen -lLLVMNVPTXDesc -lLLVMNVPTXInfo
#         -lLLVMNVPTXAsmPrinter -lLLVMMSP430Disassembler -lLLVMMSP430CodeGen
#         -lLLVMMSP430AsmParser -lLLVMMSP430Desc -lLLVMMSP430Info -lLLVMMSP430AsmPrinter
#         -lLLVMMipsDisassembler -lLLVMMipsCodeGen -lLLVMMipsAsmParser
#         -lLLVMMipsDesc -lLLVMMipsInfo -lLLVMMipsAsmPrinter -lLLVMLanaiDisassembler
#         -lLLVMLanaiCodeGen -lLLVMLanaiAsmParser -lLLVMLanaiDesc
#         -lLLVMLanaiAsmPrinter -lLLVMLanaiInfo -lLLVMHexagonDisassembler -lLLVMHexagonCodeGen
#         -lLLVMHexagonAsmParser -lLLVMHexagonDesc -lLLVMHexagonInfo
#         -lLLVMBPFDisassembler -lLLVMBPFCodeGen -lLLVMBPFAsmParser -lLLVMBPFDesc -lLLVMBPFInfo
#         -lLLVMBPFAsmPrinter -lLLVMARMDisassembler -lLLVMARMCodeGen
#         -lLLVMARMAsmParser -lLLVMARMDesc -lLLVMARMInfo -lLLVMARMAsmPrinter -lLLVMARMUtils
#         -lLLVMAMDGPUDisassembler -lLLVMAMDGPUCodeGen -lLLVMMIRParser
#         -lLLVMipo -lLLVMInstrumentation -lLLVMVectorize -lLLVMLinker -lLLVMIRReader
#         -lLLVMAsmParser -lLLVMAMDGPUAsmParser -lLLVMAMDGPUDesc
#         -lLLVMAMDGPUInfo -lLLVMAMDGPUAsmPrinter -lLLVMAMDGPUUtils -lLLVMAArch64Disassembler
#         -lLLVMMCDisassembler -lLLVMAArch64CodeGen -lLLVMGlobalISel
#         -lLLVMSelectionDAG -lLLVMAsmPrinter -lLLVMDebugInfoDWARF -lLLVMAArch64AsmParser
#         -lLLVMAArch64Desc -lLLVMAArch64Info -lLLVMAArch64AsmPrinter
#         -lLLVMAArch64Utils -lLLVMObjectYAML -lLLVMLibDriver -lLLVMOption -lgtest_main
#         -lgtest -lLLVMLineEditor -lLLVMInterpreter -lLLVMExecutionEngine
#         -lLLVMRuntimeDyld -lLLVMCodeGen -lLLVMTarget -lLLVMScalarOpts -lLLVMInstCombine
#         -lLLVMAggressiveInstCombine -lLLVMTransformUtils -lLLVMBitWriter
#         -lLLVMAnalysis -lLLVMProfileData -lLLVMObject -lLLVMMCParser -lLLVMMC
#         -lLLVMDebugInfoCodeView -lLLVMDebugInfoMSF -lLLVMBitReader
#         -lLLVMCore -lLLVMBinaryFormat -lLLVMSupport -lLLVMDemangle)


# https://github.com/llvm/llvm-project/blob/90de4a4ac96ef314e3af9c43c516d5aaf105777a/llvm/cmake/modules/LLVM-Config.cmake#L72
macro(llvm_config executable)
    cmake_parse_arguments(ARG "USE_SHARED" "" "" ${ARGN})
    set(link_components ${ARG_UNPARSED_ARGUMENTS})

    if(ARG_USE_SHARED)
        # If USE_SHARED is specified, then we link against libLLVM,
        # but also against the component libraries below. This is
        # done in case libLLVM does not contain all of the components
        # the target requires.
        #
        # Strip LLVM_DYLIB_COMPONENTS out of link_components.
        # To do this, we need special handling for "all", since that
        # may imply linking to libraries that are not included in
        # libLLVM.

        if(DEFINED link_components AND DEFINED LLVM_DYLIB_COMPONENTS)
            if("${LLVM_DYLIB_COMPONENTS}" STREQUAL "all")
                set(link_components "")
            else()
                list(REMOVE_ITEM link_components ${LLVM_DYLIB_COMPONENTS})
            endif()
        endif()

        target_link_libraries(${executable} PRIVATE LLVM)
    endif()

    target_compile_definitions(${executable} INTERFACE ${LLVM_DEFINITIONS})
    target_compile_options(${executable} INTERFACE
        # https://stackoverflow.com/questions/53805007/compilation-failing-on-enableabibreakingchecks
        # abi-breaking.h
        -DLLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1

        # -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS
    )
    if(NOT ${LLVM_ENABLE_EXCEPTION})
        target_compile_options(${executable} INTERFACE
            -fno-exceptions
        )
    endif()
    if(NOT ${LLVM_ENABLE_RTTI})
        # For non-MSVC compilers
        # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
        target_compile_options(${executable} PRIVATE
            -fno-rtti
        )
    endif()
    explicit_llvm_config(${executable} ${link_components})
endmacro(llvm_config)

# https://github.com/llvm/llvm-project/blob/90de4a4ac96ef314e3af9c43c516d5aaf105777a/llvm/cmake/modules/LLVM-Config.cmake#L102
function(explicit_llvm_config executable)
    set(link_components ${ARGN})

    llvm_map_components_to_libnames(LIBRARIES ${link_components})
    foreach(c ${link_components})
        # message(STATUS "   - c = ${c}")
        if("${c}" STREQUAL "all")
            # message(STATUS "   - c = ${c} | MATCHED")
            get_property(all_components GLOBAL PROPERTY LLVM_COMPONENT_LIBS)
            # message(STATUS "   - all_components = ${all_components}")
            if(NOT all_components)
                # execute_process(COMMAND ${LLVM_TOOLS_BINARY_DIR}/llvm-config --libs OUTPUT_VARIABLE all_components)
                # # message(STATUS "   - all_components = ${all_components}")
                # string(STRIP "${all_components}" t)
                # string(REGEX REPLACE "[-]l" "" LIBRARIES "${t}")
                # # message(STATUS "---- all_components: ${all_components}")
                set(LIBRARIES LLVM)
            else()
                llvm_map_components_to_libnames(LIBRARIES ${all_components})
            endif()
            message(STATUS "---- LIBRARIES: ${LIBRARIES}")
            # list(APPEND LIBRARIES ${all_components})
        endif()
    endforeach()
    list(REMOVE_ITEM LIBRARIES LLVMjit) # fix llvm_map_components_to_libnames's wrong outputs
    string(STRIP "${LIBRARIES}" LIBRARIES)
    get_target_property(t ${executable} TYPE)
    # message(STATUS "---- link_components: ${link_components}")
    # message(STATUS "---- LIBRARIES: ${LIBRARIES}")
    if(t STREQUAL "STATIC_LIBRARY")
        message(STATUS "     Added llvm_libs (static) to target '${executable}'")
        message(STATUS "       ${LIBRARIES}")
        target_link_libraries(${executable} INTERFACE ${LIBRARIES})
    elseif(t STREQUAL "EXECUTABLE" OR t STREQUAL "SHARED_LIBRARY" OR t STREQUAL "MODULE_LIBRARY")
        message(STATUS "     Added llvm_libs (shared) to target '${executable}'")
        message(STATUS "       ${LIBRARIES}")
        target_link_libraries(${executable} PRIVATE ${LIBRARIES})
    elseif(t STREQUAL "INTERFACE_LIBRARY")
        message(STATUS "     Added llvm_libs (interface) to target '${executable}'")
        message(STATUS "       ${LIBRARIES}")
        target_link_libraries(${executable} INTERFACE ${LIBRARIES})
    else()
        message(STATUS "---- t: ${t}")
        message(STATUS "     Added llvm_libs (legacy) to target '${executable}'")
        message(STATUS "       ${LIBRARIES}")
        # Use plain form for legacy user.
        target_link_libraries(${executable} ${LIBRARIES})
    endif()
endfunction(explicit_llvm_config)

set(LLVM_LINK_COMPONENTS
    Analysis
    Core
    ExecutionEngine
    InstCombine
    Object
    OrcJIT
    Passes
    RuntimeDyld
    ScalarOpts
    Support
    TargetParser
    native
    nativecodegen irprinter irreader
    engine executionengine extensions interpreter
    mc mcjit
    asmparser demangle
    scalaropts
    transformutils
    #         support core irreader
    #         demangle engine executionengine
    #         extensions interpreter ipo irprinter native nativecodegen
    #         mc mcjit
    #         asmparser
    #         objcarcopts
    #         scalaropts
    #         transformutils
)
# llvm_map_components_to_libnames(llvm_libs ${which_llvm_components})
# execute_process(COMMAND ${LLVM_TOOLS_BINARY_DIR}/llvm-config --libs "${LLVM_LINK_COMPONENTS}" OUTPUT_VARIABLE llvm_libs)
# list(REMOVE_ITEM llvm_libs LLVMjit) # fix llvm_map_components_to_libnames's wrong outputs
# message(STATUS "---- llvm_libs: ${llvm_libs}")


function(define_basics_llvm_target)
    if(ARGC GREATER 0)
        set(new_target ${ARGV0})
        set(comps ${ARGN})
        # message(STATUS "---- ARGC=${ARGC}, ARGV0=${ARGV0}, ARGV1=${ARGV1}. ${ARGN}")
        # message(STATUS "---- comps=${comps} ----- '${ARGN}'")
        list(REMOVE_AT comps 0)
        # message(STATUS "---- define_basic_llvm_target: new_target=${new_target}, comps=${comps}")
    else()
        # message(STATUS "---- define_basic_llvm_target/: ARGC=${ARGC}, ARGV0=${ARGV0}, ARGV1=${ARGV1}")
        set(new_target basics::LLVM)
    endif()

    if(TARGET ${new_target})
        if(ARGV0 AND ARGV1)
            message(STATUS "Target ${new_target} exists")
        endif()
    else()
        # Create a wrapper for the LLVM components we need in this
        # project. This will allow us to link it to multiple targets
        # without duplicating a lot of code. It's too bad that LLVM
        # doesn't provide anything like this.
        add_library(${new_target} INTERFACE IMPORTED)
        target_include_directories(${new_target} INTERFACE ${LLVM_INCLUDE_DIRS})
        target_compile_definitions(${new_target} INTERFACE ${LLVM_DEFINITIONS})
        # target_link_libraries(${new_target} INTERFACE ${llvm_libs})

        if(comps)
            message(STATUS "---- define_basic_llvm_target: new_target=${new_target}, comps=${comps}")
            llvm_config(${new_target} ${comps})
        else()
            llvm_config(${new_target} ${LLVM_LINK_COMPONENTS})
        endif()

        # target_link_libraries(${new_target} INTERFACE ${LLVM_LIBRARIES})
        # target_link_options(${new_target} INTERFACE ${llvm_link_flags})
        target_compile_options(${new_target} INTERFACE
            # https://stackoverflow.com/questions/53805007/compilation-failing-on-enableabibreakingchecks
            # abi-breaking.h
            -DLLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1

            # -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS
        )
        if(NOT ${LLVM_ENABLE_EXCEPTION})
            target_compile_options(${new_target} INTERFACE
                -fno-exceptions
            )
        endif()
        if(NOT ${LLVM_ENABLE_RTTI})
            # For non-MSVC compilers
            # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
            target_compile_options(${new_target} INTERFACE
                -fno-rtti
            )
        endif()
    endif()
endfunction()

function(add_llvm_supports target)
    # message(STATUS "---- add_llvm_supports - ARGC=${ARGC}, ARGV0=${ARGV0}, ARGV1=${ARGV1}. ${ARGN}")
    cmake_parse_arguments(ARG "LLVM_COMPONENTS" "" "" ${ARGN})
    set(llvm_components ${ARG_UNPARSED_ARGUMENTS})
    # message(STATUS "---- add_llvm_supports(target=${target}): ARG_UNPARSED_ARGUMENTS=${ARG_UNPARSED_ARGUMENTS}")

    if(llvm_components)
        set(LIB "basics::llvm::${target}_deps")
        # message(STATUS "---- add_llvm_supports(target=${target}): ARG_UNPARSED_ARGUMENTS=${ARG_UNPARSED_ARGUMENTS}")
        define_basics_llvm_target("${LIB}" "${ARG_UNPARSED_ARGUMENTS}")
    else()
        set(LIB basics::LLVM)
        define_basics_llvm_target()
    endif()

    set_target_properties(${target}
        PROPERTIES
        CXX_STANDARD ${CXX_STANDARD}
        CXX_STANDARD_REQUIRED YES
        CXX_EXTENSIONS OFF # use -std=c++11 rather than -std=gnu++11
    )
    # # target_include_directories(${target} PRIVATE
    # #         /opt/homebrew/opt/llvm/include
    # # )
    # target_compile_options(${target} PRIVATE
    #         -fno-exceptions -fno-rtti
    # 
    #         # https://stackoverflow.com/questions/53805007/compilation-failing-on-enableabibreakingchecks
    #         # abi-breaking.h
    #         -DLLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1
    #
    #         -DLLVM_TARGETS_TO_BUILD="X86;BPF"
    #         -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_ENABLE_RTTI=ON -DCMAKE_BUILD_TYPE=Release ..
    #         # -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS
    # )
    # target_compile_definitions(${target} PRIVATE
    # )
    # # target_link_directories(${target} PRIVATE
    # #         /opt/homebrew/opt/llvm/lib
    # # )
    # target_link_libraries(${target} PRIVATE
    #         z curses xml2
    #         # m
    # )
    # target_compile_definitions(${target} PRIVATE ${LLVM_DEFINITIONS})
    # target_include_directories(${target} PRIVATE ${LLVM_INCLUDE_DIRS})
    # target_link_libraries(${target} PRIVATE ${llvm_libs})
    # target_link_options(${target} PRIVATE ${llvm_link_flags})
    target_link_libraries(${target} PRIVATE ${LIB})
    # if(llvm_components)
    #     message(STATUS "---- DONE: add_llvm_supports(target=${target}): ${LIB}")
    # endif()
endfunction()

# Usage:
#   add_llvm_target(llvm-app SOURCES main.cc LLVM_COMPONENTS all)
#   add_llvm_target(llvm-app SOURCES main.cc)
#   add_llvm_target(llvm-app SOURCES main.cc 
#      LLVM_COMPONENTS
#        Core
#        Support
#        native
#        irreader)
#
function(add_llvm_target APP_NAME)
    # add_executable(${APP_NAME} chapter2-Implementing-a-Parser-and-AST.cpp)
    # add_llvm_supports(${APP_NAME})

    set(altt_PARAM_OPTIONS
        # INSTALL # installable?
        # PACK # CPack?
        # GENERATE_CONFIG # generate config.h and version.h
        # BUILD_DOCS # build docs with doxygen? 
        # IPO # enable IPO mode
    )
    set(altt_PARAM_ONE_VALUE_KEYWORDS
        # PREFIX # PROJ_PREFIX
        # CXXSTANDARD # such as CXXSTANDARD 17
        # VERSION # default is ${PROJECT_VERSION}
    )
    set(altt_PARAM_MULTI_VALUE_KEYWORDS
        # CXXFLAGS # cxx compiler options
        # CXXDEFINITIONS
        # HEADERS
        # DETAILED_HEADERS
        # SOURCES
        # INCLUDE_DIRECTORIES
        # LIBRARIES
        # FLEX
        # BISON
        LLVM_COMPONENTS
        SOURCES
    )

    # message(STATUS "---- add_llvm_test_target - ARGC=${ARGC}, ARGV0=${ARGV0}, ARGV1=${ARGV1}. ${ARGN}")
    cmake_parse_arguments(altt_ARG
        "${altt_PARAM_OPTIONS}"
        "${altt_PARAM_ONE_VALUE_KEYWORDS}"
        "${altt_PARAM_MULTI_VALUE_KEYWORDS}"
        ${ARGN})

    set(altt_usage "add_llvm_target(<Name/Target>
      [SOURCES a.cc b.cc ...]
      [LLVM_COMPONENTS core jit ...]
      )
     
      Unparsed Params Are:
        ${altt_ARG_UNPARSED_ARGUMENTS}
	")

    # if(NOT "${altt_ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
    #     message(SEND_ERROR ${altt_usage})
    # endif()

    if(NOT "${altt_ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
        set(altt_ARG_SOURCES "${altt_ARG_UNPARSED_ARGUMENTS}")
    endif()

    debug_print_value(altt_ARG_LLVM_COMPONENTS)
    debug_print_value(altt_ARG_SOURCES)

    set(_prj_name "${APP_NAME}")
    set(llvm_components ${altt_ARG_LLVM_COMPONENTS})
    add_executable(${_prj_name} ${altt_ARG_SOURCES})
    if(altt_ARG_LLVM_COMPONENTS)
        add_llvm_supports(${_prj_name} LLVM_COMPONENTS ${altt_ARG_LLVM_COMPONENTS})
    else()
        add_llvm_supports(${_prj_name})
    endif()
endfunction()


# Usage:
#   add_llvm_test_target(k1 SOURCES main.cc LLVM_COMPONENTS all)
#   add_llvm_test_target(k2 SOURCES main.cc)
#   add_llvm_test_target(k3 SOURCES main.cc 
#      LLVM_COMPONENTS
#        Core
#        Support
#        native
#        irreader)
#
function(add_llvm_test_target APP_NAME)
    set(_prj_name "test-${APP_NAME}")
    add_llvm_target(${_prj_name} ${ARGN})
    add_test(NAME ${_prj_name}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMAND $<TARGET_FILE:${_prj_name}>)
endfunction()
