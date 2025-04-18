# FindNVIDIAOpenMP.cmake
# Finds NVIDIA's OpenMP implementation for ARM architectures

find_library(NVIDIA_OMP_LIBRARY
  NAMES nvomp
  PATHS
    /work/opt/local/aarch64/cores/nvidia/24.9/Linux_aarch64/24.9/compilers/lib
    /opt/nvidia/hpc_sdk/Linux_aarch64/*/compilers/lib
    ENV LD_LIBRARY_PATH
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NVIDIAOpenMP
  DEFAULT_MSG
  NVIDIA_OMP_LIBRARY
)

if(NVIDIAOpenMP_FOUND)
  if(NOT TARGET NVIDIA::OpenMP)
    add_library(NVIDIA::OpenMP SHARED IMPORTED)
    set_target_properties(NVIDIA::OpenMP PROPERTIES
      IMPORTED_LOCATION "${NVIDIA_OMP_LIBRARY}"
    )
  endif()
endif()
