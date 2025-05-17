cmake_minimum_required(VERSION 3.24)
project(groot_spmm)

set(PROJECT_VERSION "0.1")

enable_language(CUDA CXX)
#find_program(CMAKE_CUDA_COMPILER nvcc
#	PATHS
#	$ENV{NVHPC_ROOT}/compiler/bin
#	$ENV{PATH}/bin
#	/work/opt/local/aarch64/cores/nvidia/24.9/Linux_aarch64/24.9/compilers/bin
#	REQUIRED)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
    find_package(NVIDIAOpenMP)
    if(NVIDIAOpenMP_FOUND)
        message(STATUS "Using NVIDIA OpenMP: ${NVIDIA_OMP_LIBRARY}")
    endif()
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_ARCHITECTURES 90)
set(CUDA_SEPARABLE_COMPILATION ON)
set(CUDA_PROPAGATE_HOST_FLAGS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_definitions(-DTHRUST_HOST_SYSTEM=THRUST_HOST_SYSTEM_OMP)

# Find packages
find_package(OpenMP REQUIRED)
find_package(CUDAToolkit REQUIRED)
find_package(Boost REQUIRED COMPONENTS timer chrono system program_options)

# Set up NVIDIA OpenMP libraries if on ARM
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
    set(NVOMP_LIB_PATH "/work/opt/local/aarch64/cores/nvidia/24.9/Linux_aarch64/24.9/compilers/lib")
    find_library(NVOMP_LIBRARY nvomp PATHS ${NVOMP_LIB_PATH} REQUIRED)
    message(STATUS "Found NVIDIA OpenMP library: ${NVOMP_LIBRARY}")
endif()

if("${BUILD_COMPILER}" STREQUAL "nvc")
        set(CMAKE_C_FLAGS "-mp -fast -O3 -Wall")
        set(CMAKE_CXX_FLAGS "-mp -fast -O3 -Wall")
else()
	# gcc
        set(CMAKE_C_FLAGS "-fopenmp -O3 -Wall")
        set(CMAKE_CXX_FLAGS "-fopenmp -O3 -Wall")
endif()
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -fopenmp -O3 -Wall")

set(KGRAPH_ROOT "$ENV{HOME}/opt/kgraph")
include_directories(${KGRAPH_ROOT}/include)
link_directories(${KGRAPH_ROOT}/lib)

add_subdirectory(groot)

# Only build apps if not being included via FetchContent
if(NOT GROOT_FETCHCONTENT_BUILD)
    add_subdirectory(apps)
endif()
