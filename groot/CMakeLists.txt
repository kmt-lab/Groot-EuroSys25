add_library(grootlib INTERFACE)

target_include_directories(grootlib
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Use the proper OpenMP flags
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
  target_link_libraries(grootlib INTERFACE
    OpenMP::OpenMP_CXX
    kgraph
    Boost::timer
    Boost::chrono
    Boost::system
    Boost::program_options)
else()
  target_link_libraries(grootlib INTERFACE
    OpenMP::OpenMP_CXX
    kgraph
    Boost::timer
    Boost::chrono
    Boost::system
    Boost::program_options)
endif()

target_compile_options(grootlib INTERFACE
  $<$<CONFIG:Debug>:-G -g>
  $<$<COMPILE_LANGUAGE:CUDA>:
  -Xcompiler=-fopenmp # Correct OpenMP flag for gcc
  --extended-lambda
  --expt-relaxed-constexpr
  -w # Suppress warning -- though warning is usually helpful
  >
)
