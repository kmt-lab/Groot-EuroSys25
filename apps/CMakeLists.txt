add_executable(groot groot.cu)

# Link libraries differently based on architecture
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
    target_link_libraries(groot PRIVATE grootlib ${NVOMP_LIBRARY})
else()
    target_link_libraries(groot PRIVATE grootlib)
endif()
