cmake_minimum_required(VERSION 3.22)
project(groot_spmm)

set(PROJECT_VERSION "0.1")

enable_language(CUDA CXX)

# Check for ARM architecture
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
    message(STATUS "Building for ARM architecture")
    add_definitions(-DKGRAPH_USE_ARM_IMPL)
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_ARCHITECTURES 90)
set(CUDA_SEPARABLE_COMPILATION ON)
set(CUDA_PROPAGATE_HOST_FLAGS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_definitions(-DTHRUST_HOST_SYSTEM=THRUST_HOST_SYSTEM_OMP)

find_package(OpenMP REQUIRED)
find_package(CUDAToolkit REQUIRED)
find_package(Boost REQUIRED COMPONENTS timer chrono system program_options)

set(KGRAPH_ROOT "$ENV{HOME}/opt/kgraph")
include_directories(${KGRAPH_ROOT}/include)
link_directories(${KGRAPH_ROOT}/lib)

add_subdirectory(groot)
add_subdirectory(apps)
