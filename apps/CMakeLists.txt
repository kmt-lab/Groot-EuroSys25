add_executable(groot groot.cu)
add_executable(mtx_converter mtx_converter.cu)

# Link libraries differently based on architecture
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64|arm64")
    target_link_libraries(groot PRIVATE grootlib ${NVOMP_LIBRARY})
    target_link_libraries(mtx_converter PRIVATE grootlib ${NVOMP_LIBRARY})
else()
    target_link_libraries(groot PRIVATE grootlib)
    target_link_libraries(mtx_converter PRIVATE grootlib)
endif()
