# Dispatches the translated compute 3D image_store on a four-deep volume UAV through the standalone offscreen
# harness. The startup runtime does not bind a tex3d UAV, so this is not a startup binding test.
if(EXISTS "${INTAKE_PYTHON}" AND TARGET offscreen_check)
    foreach(adapter IN ITEMS warp hardware)
        add_test(NAME startup_compute_image_store_volume_${adapter} COMMAND "${INTAKE_PYTHON}" -B
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/startup_compute_image_store_check.py" --dispatch-volume
            "${DXC_EXECUTABLE}" "$<TARGET_FILE:offscreen_check>" ${adapter})
        set_tests_properties(startup_compute_image_store_volume_${adapter} PROPERTIES TIMEOUT 120 SKIP_RETURN_CODE 77)
    endforeach()
endif()
