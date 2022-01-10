cmake_minimum_required(VERSION 3.10)

include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/system.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/find_rapidjson.cmake)

function(get_default_qt out_value)
	get_cxx_compiler(compiler)
	get_architecture(arch)
	if(${compiler} MATCHES "^MSVC_16")
		if(${arch} STREQUAL x86)
			set(${out_value} "C:/Qt/5.3/msvc2010_opengl")
		endif()
	elseif(${compiler} MATCHES "^MSVC_19")
		set(${out_value} "C:/Qt/5.12.0/msvc2017")
		if(${arch} STREQUAL x64)
			set(${out_value} "${qt_hint}_64")
		endif()
	endif()
	message(STATUS "default Qt dir hint: ${${out_value}}")
	return_value(${out_value})
endfunction()

macro(Default_canvasdraw)
	generate_target_id(target_id)
	set(${PROJECT_NAME}_canvasdraw_DIR "${${PROJECT_NAME}_3rdparty_DIR}/canvasdraw/install"
		CACHE PATH "Path to cmake file of canvasdraw library."
	)
	message(STATUS "canvasdraw path: ${${PROJECT_NAME}_canvasdraw_DIR}")
	GuardedImportConfigurable(${PROJECT_NAME}
		cd
		"${${PROJECT_NAME}_canvasdraw_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/canvasdraw"
	)
endmacro()

macro(Default_CUDA)
	enable_language(CUDA)

	include(CheckLanguage)
	check_language(CUDA)

	if(NOT DEFINED CMAKE_CUDA_STANDARD)
		set(CMAKE_CUDA_STANDARD 11)
		set(CMAKE_CUDA_STANDARD_REQUIRED ON)
	endif()

	find_package(CUDAToolkit)

	if(${CUDAToolkit_FOUND})
		message(STATUS "CUDA Toolkit include: ${CUDAToolkit_INCLUDE_DIRS}")
		ImportInterface(cuda
			"${CUDAToolkit_INCLUDE_DIRS}"
		)
	else()
		message(FATAL_ERROR "CUDA Toolkit not found.")
	endif()
endmacro()

macro(Default_eigen)
	set(${PROJECT_NAME}_eigen_DIR "${${PROJECT_NAME}_3rdparty_DIR}/eigen/install"
		CACHE PATH "Path to cmake file of eigen library."
	)
	message(STATUS "eigen path: ${${PROJECT_NAME}_eigen_DIR}")
#	generate_target_id(target_id)
#	find_package(Eigen3 REQUIRED
#		PATHS
#			"${${PROJECT_NAME}_fmt_DIR}/install/${target_id}/share/eigen3/cmake"
#	)
	GuardedImport(
		eigen
		"${${PROJECT_NAME}_eigen_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/eigen"
	)
endmacro()

macro(Default_fmt)
	generate_target_id(target_id)
	set(${PROJECT_NAME}_fmt_DIR "${${PROJECT_NAME}_3rdparty_DIR}/fmt/master"
		CACHE PATH "Path to cmake file of fmt library."
	)
	message(STATUS "fmt path: ${${PROJECT_NAME}_fmt_DIR}")
	find_package(fmt REQUIRED
		PATHS
			"${${PROJECT_NAME}_fmt_DIR}/install/${target_id}_static/lib/cmake/fmt"
	)
endmacro()

macro(Default_gbenchmark)
	set(${PROJECT_NAME}_gbenchmark_DIR "${${PROJECT_NAME}_3rdparty_DIR}/googlebenchmark/sources"
		CACHE PATH "Path to cmake file of googlebenchmark library.")
	GuardedImport(
		benchmark
		"${${PROJECT_NAME}_gbenchmark_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/gbenchmark"
	)
endmacro()

macro(Default_gtest)
	set(${PROJECT_NAME}_gtest_DIR "${${PROJECT_NAME}_3rdparty_DIR}/googletest/sources"
		CACHE PATH "Path to cmake file of googletest library.")
	GuardedImport(
		gtest
		"${${PROJECT_NAME}_gtest_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/gtest"
	)
endmacro()

macro(Default_glew)
	set(${PROJECT_NAME}_glew_DIR "${${PROJECT_NAME}_3rdparty_DIR}/glew"
		CACHE PATH "Path to cmake file of glew library.")
	GuardedImport(
		glew
		"${${PROJECT_NAME}_glew_DIR}/install"
		"${CMAKE_BINARY_DIR}/3rd_party/glew"
	)
endmacro()

macro(Default_glm)
	set(${PROJECT_NAME}_glm_DIR "${${PROJECT_NAME}_3rdparty_DIR}/glm"
		CACHE PATH "Path to cmake file of glm library.")
	GuardedImport(
		glm
		"${${PROJECT_NAME}_glm_DIR}/install"
		"${CMAKE_BINARY_DIR}/3rd_party/glm"
	)
endmacro()

macro(Default_im_toolkit)
	generate_target_id(target_id)
	set(${PROJECT_NAME}_im_toolkit_DIR "${${PROJECT_NAME}_3rdparty_DIR}/im_toolkit/install"
		CACHE PATH "Path to cmake file of im_toolkit library."
	)
	message(STATUS "im_toolkit path: ${${PROJECT_NAME}_im_toolkit_DIR}")
	GuardedImportConfigurable(${PROJECT_NAME}
		im
		"${${PROJECT_NAME}_im_toolkit_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/im_toolkit"
	)
endmacro()

macro(Default_iup)
	generate_target_id(target_id)
	set(${PROJECT_NAME}_iup_DIR "${${PROJECT_NAME}_3rdparty_DIR}/iup/install"
		CACHE PATH "Path to cmake file of iup library."
	)
	message(STATUS "iup path: ${${PROJECT_NAME}_iup_DIR}")
	GuardedImportConfigurable(${PROJECT_NAME}
		iup
		"${${PROJECT_NAME}_iup_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/iup"
	)
endmacro()

macro(Default_linmath)
	set(${PROJECT_NAME}_linmath_DIR "${${PROJECT_NAME}_3rdparty_DIR}/linmath/sources"
		CACHE PATH "Path to cmake file of linmath library.")
	GuardedImport(
		linmath
		"${${PROJECT_NAME}_linmath_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/linmath"
	)
endmacro()

macro(Default_lua)
	set(${PROJECT_NAME}_lua_DIR "${${PROJECT_NAME}_3rdparty_DIR}/lua/install"
		CACHE PATH "Path to cmake file of lua library.")
	GuardedImport(
		lua
		"${${PROJECT_NAME}_lua_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/lua"
	)
endmacro()

macro(Default_luajit)
	set(${PROJECT_NAME}_luajit_DIR "${${PROJECT_NAME}_3rdparty_DIR}/luajit"
		CACHE PATH "Path to cmake file of luajit library.")
	GuardedImport(
		lua
		"${${PROJECT_NAME}_luajit_DIR}/install/5.1"
		"${CMAKE_BINARY_DIR}/3rd_party/luajit"
	)
endmacro()

macro(Default_mesa)
	set(${PROJECT_NAME}_mesa_DIR "${${PROJECT_NAME}_3rdparty_DIR}/mesa"
		CACHE PATH "Path to cmake file of mesa library.")
	GuardedImport(
		mesa
		"${${PROJECT_NAME}_mesa_DIR}/install"
		"${CMAKE_BINARY_DIR}/3rd_party/mesa"
	)
endmacro()

macro(Default_minizip)
	generate_target_id(target_id)
	set(${PROJECT_NAME}_minizip_DIR "${${PROJECT_NAME}_3rdparty_DIR}/zlib/minizip"
		CACHE PATH "Path to cmake file of zlib library.")
	find_package(minizip REQUIRED
		PATHS
			"${${PROJECT_NAME}_minizip_DIR}/install/${target_id}/cmake"
		NO_DEFAULT_PATH
	)
endmacro()

macro(Default_opencv)
	set(${PROJECT_NAME}_OpenCV_DIR "${${PROJECT_NAME}_3rdparty_DIR}/opencv/4.0.0"
		CACHE PATH "Path to cmake file of opencv library."
	)

	set(OpenCV_STATIC ON)
	message(STATUS "OpenCV path: ${${PROJECT_NAME}_OpenCV_DIR}/install/${target_id}/staticlib")

	find_package(OpenCV REQUIRED
		COMPONENTS
			world
		PATHS
			"${${PROJECT_NAME}_OpenCV_DIR}/install/${target_id}/staticlib"
		NO_DEFAULT_PATH
	)
endmacro()

macro(Default_pugixml)
	generate_target_id(target_id)
	set(${PROJECT_NAME}_pugixml_DIR "${${PROJECT_NAME}_3rdparty_DIR}/pugixml/sources"
		CACHE PATH "Path to cmake file of googlebenchmark library.")
	message(STATUS "pugixml path: ${${PROJECT_NAME}_pugixml_DIR}")
#	find_package(pugixml REQUIRED
#		PATHS
#			"${${PROJECT_NAME}_pugixml_DIR}/install/${target_id}_static/lib/cmake/pugixml"
#	)
	GuardedImport(
		pugixml
		"${${PROJECT_NAME}_pugixml_DIR}"
	)

endmacro()

macro(Default_spdlog)
	generate_target_id(target_id)
	set(${PROJECT_NAME}_spdlog_DIR "${${PROJECT_NAME}_3rdparty_DIR}/spdlog/master/"
		CACHE PATH "Path to cmake file of spdlog library."
	)
	message(STATUS "spdlog path: ${${PROJECT_NAME}_spdlog_DIR}")
	find_package(spdlog REQUIRED
		PATHS
			"${${PROJECT_NAME}_spdlog_DIR}/install/${target_id}_static/lib/cmake/spdlog"
	)
endmacro()

macro(Default_wave)
	set(${PROJECT_NAME}_wave_DIR "${${PROJECT_NAME}_3rdparty_DIR}/wave/install"
		CACHE PATH "Path to cmake file of wave library.")
	GuardedImport(
		wave
		"${${PROJECT_NAME}_wave_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/wave"
	)
endmacro()

macro(Default_wave_src)
	set(${PROJECT_NAME}_wave_DIR "${${PROJECT_NAME}_3rdparty_DIR}/wave/sources"
		CACHE PATH "Path to cmake file of wave library.")
	set(wave_enable_tests OFF CACHE BOOL "")
	set(BUILD_TESTING OFF CACHE BOOL "")
	GuardedImport(
		wave
		"${${PROJECT_NAME}_wave_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/wave"
	)
endmacro()

macro(Default_webview2)
	set(${PROJECT_NAME}_webview2_DIR "${${PROJECT_NAME}_3rdparty_DIR}/webview2/install"
		CACHE PATH "Path to cmake file of webview2 library.")
	GuardedImport(
		webview2
		"${${PROJECT_NAME}_webview2_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/webview2"
	)
endmacro()

macro(Default_zlib)
	set(${PROJECT_NAME}_zlib_DIR "${${PROJECT_NAME}_3rdparty_DIR}/zlib/install"
		CACHE PATH "Path to cmake file of zlib library.")
	GuardedImport(
		zlib
		"${${PROJECT_NAME}_zlib_DIR}"
		"${CMAKE_BINARY_DIR}/3rd_party/zlib"
	)
endmacro()
