cmake_minimum_required(VERSION 3.10)

include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/system.cmake)

function(get_default_hasp_dir out_value)
	if(EXISTS "C:/Program Files (x86)/Gemalto Sentinel/Sentinel LDK/VendorTools/VendorSuite/envelope.com")
		set(${out_value} "C:/Program Files (x86)/Gemalto Sentinel/Sentinel LDK/VendorTools/VendorSuite")
	else()
		set(${out_value} "C:/Program Files (x86)/Thales/Sentinel LDK/VendorTools/VendorSuite")
	endif()
	return_value(${out_value})
endfunction()

macro(Default_hasp)
	GuardedImportConfigurable(${PROJECT_NAME} hasp "${${PROJECT_NAME}_3rdparty_DIR}/hasp/install")
endmacro()

macro(Default_leadtools)
	GuardedImportConfigurable(${PROJECT_NAME} leadtools "${${PROJECT_NAME}_3rdparty_DIR}/leadtools/install")
	message(STATUS "leadtools_DIR: ${leadtools_DIR}")
	include(${leadtools_DIR}/lead_tools.cmake)
endmacro()

macro(Default_cudanar)
	GuardedImportConfigurable(${PROJECT_NAME} cudanar "${${PROJECT_NAME}_3rdparty_DIR}/../CUDAnaR")
endmacro()

macro(Default_dwgex_parser)
	GuardedImportConfigurable(${PROJECT_NAME} dwgex_parser "${${PROJECT_NAME}_3rdparty_DIR}/../DWGex_Parser")
endmacro()
