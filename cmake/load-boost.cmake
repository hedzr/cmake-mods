if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

find_package(Boost REQUIRED COMPONENTS headers program_options)
if(Boost_FOUND)
    message(STATUS "Found Boost: ${Boost_INCLUDE_DIRS} (found version \"${Boost_VERSION}\")")
    set(Boost_USE_MULTITHREADED TRUE)
    set(Boost_NO_WARN_NEW_VERSIONS 1)
endif()
# CMake Warning (policy) 
# (find_package):Policy CMP0167 is not set: The FindBoost module is removed.
# Run "cmake --help-policy CMP0167" for policy details.
# Use the cmake_policy command to set the policy and suppress this warning.