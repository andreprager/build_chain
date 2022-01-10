cmake_minimum_required(VERSION 3.10)

include_guard()

macro(add_option_static_runtime target)
	set(${target}_FORCE_STATIC_RUNTIME OFF
		CACHE BOOL "Force use of static runtime library for ${target}")
	if(${${target}_FORCE_STATIC_RUNTIME})
		set_property(TARGET ${target} PROPERTY
		  MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")	
	endif()
endmacro()

macro(add_option_static_runtime_target_id_suffix target)
	set(${target}_USE_STATIC_RUNTIME OFF
		CACHE BOOL "Use of static runtime library for ${target}")
	if(${${target}_USE_STATIC_RUNTIME})
		set(target_id "${target_id}_mt")
	endif()
endmacro()

macro(add_option_shared_target_id_suffix target)
	set(${target}_USE_SHARED ${BUILD_SHARED_LIBS}
		CACHE BOOL "Use of shared library for ${target}")
	if(${${target}_USE_SHARED})
		set(target_id "${target_id}_shared")
	endif()
endmacro()

macro(return_value value)
	set(${value} ${${value}} PARENT_SCOPE)
endmacro()

macro(begin_project)
	message(STATUS "  >> ${PROJECT_NAME} >>")
endmacro()

macro(end_project)
	message(STATUS "  << ${PROJECT_NAME} <<")
endmacro()

function(get_system out_value)
	string(SUBSTRING "${CMAKE_SYSTEM_NAME}" 0 3 ${out_value})
	return_value(${out_value})
endfunction()

function(get_architecture out_value)
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(${out_value} x64)
	elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
		set(${out_value} x86)
	else()
		message(WARNING "Unknown system architecture, probably modification of this function is needed?")
		set(${out_value} unknown)
	endif()
	message(STATUS "detected architecture: ${${out_value}}")
	return_value(${out_value})
endfunction()

#deprecated
function(get_cxx_compiler out_value)
	get_compiler(${out_value})
	return_value(${out_value})
endfunction()

function(get_compiler out_value)
	#set version, e.g. MSVC_19_14
	#string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" version ${CMAKE_CXX_COMPILER_VERSION})
	#string(REPLACE "." "_" version ${version})
	if(NOT "${CMAKE_CXX_COMPILER_VERSION}" STREQUAL "")
		message(STATUS "CMAKE_CXX_COMPILER_ID compiler: <${CMAKE_CXX_COMPILER_ID}>")
		message(STATUS "CMAKE_CXX_COMPILER_VERSION compiler: <${CMAKE_CXX_COMPILER_VERSION}>")
		#set version, e.g. MSVC_19
		string(REGEX MATCH "^([0-9]+)\\." version ${CMAKE_CXX_COMPILER_VERSION})
		string(REPLACE "." "" version ${version})
		set(${out_value} "${CMAKE_CXX_COMPILER_ID}_${version}")
	else()
		if(NOT "${CMAKE_C_COMPILER_VERSION}" STREQUAL "")
			message(STATUS "CMAKE_C_COMPILER_ID compiler: <${CMAKE_C_COMPILER_ID}>")
			message(STATUS "CMAKE_C_COMPILER_VERSION compiler: <${CMAKE_C_COMPILER_VERSION}>")
			#set version, e.g. MSVC_19
			string(REGEX MATCH "^([0-9]+)\\." version ${CMAKE_C_COMPILER_VERSION})
			string(REPLACE "." "" version ${version})
			set(${out_value} "${CMAKE_C_COMPILER_ID}_${version}")
		else()
			message(STATUS "CMAKE_CSharp_COMPILER_ID compiler: <${CMAKE_CSharp_COMPILER_ID}>")
			message(STATUS "CMAKE_CSharp_COMPILER_VERSION compiler: <${CMAKE_CSharp_COMPILER_VERSION}>")
			set(compiler_id "${CMAKE_CSharp_COMPILER_ID}")
			string(REPLACE " " "_" compiler_id ${compiler_id})
			#set version, e.g. MSVC_19
			string(REGEX MATCH "^([0-9]+)\\." version ${CMAKE_CSharp_COMPILER_VERSION})
			string(REPLACE "." "" version ${version})
			set(${out_value} "${compiler_id}_${version}")
		endif()
	endif()

	message(STATUS "detected compiler: ${${out_value}}")
	return_value(${out_value})
endfunction()

function(AssertCompilerVersion compiler version)
	if(NOT compiler MATCHES "^(${version})")
		message(FATAL_ERROR "Compiler ${compiler} does not match with expected version ${version}!")
	endif()
endfunction()

function(AssertArchitecture arch version)
	if(NOT arch STREQUAL "${version}")
		message(FATAL_ERROR "Architecture '${arch}' does not match with expected '${version}'!")
	endif()
endfunction()

function(generate_target_id out_value)
	#check for architecture
	get_architecture(arch)
	#get system name
	get_system(OS)
	#get compiler version
	get_cxx_compiler(compiler)
	#set return value, e.g. Win_x64_MSVC_19
	set(${out_value}
		"${OS}_${arch}_${compiler}"
	)
	message(STATUS "generated target id: ${${out_value}}")
	return_value(${out_value})
endfunction()

function(convert_flags_CUDA target)
	get_property(old_flags TARGET ${target} PROPERTY INTERFACE_COMPILE_OPTIONS)
	if(NOT "${old_flags}" STREQUAL "")
		string(REPLACE ";" "," CUDA_flags "${old_flags}")
		set_target_property(${target} PROPERTIES
			INTERFACE
				_COMPILE_OPTIONS
					"$<$<BUILD_INTERFACE:$<COMPILE_LANGUAGE:CXX>>:${old_flags}>$<$<BUILD_INTERFACE:$<COMPILE_LANGUAGE:CUDA>>:-Xcompiler=${CUDA_flags}>"
		)
	endif()
endfunction()

function(WarningAsError target)
	set(WARN_AS_ERROR ON CACHE BOOL "Treat warnings as errors.")
	if(WARN_AS_ERROR)
		get_cxx_compiler(compiler)
		if(${compiler} MATCHES "^MSVC")
			target_compile_options(${target}
				PRIVATE
					-WX
					-W3
			)
			message(STATUS "Compile options added: -WX -Wall (${target})")
		else()
			target_compile_options(${target}
				PRIVATE
					-Werror
					-Wall
					-Wextra
			)
			message(STATUS "Compile options added: -Werror -Wall -Wextra (${target})")
		endif()
	endif()
endfunction()

function(Deactivate_C5105 target)
	get_compiler(compiler)
	if(${compiler} MATCHES "^MSVC")
		#reduce MSVC Compiler Warning C5105 to warning level 1
		message(STATUS "Compile options added: WarningLevel(C5105) -W4 (${target})")
		target_compile_options(${PROJECT_NAME}
			PRIVATE
				/w45105
		)
	endif()
endfunction()

function(Enable_CRT_SECURE_NO_WARNINGS target)
	get_compiler(compiler)
	if(${compiler} MATCHES "^MSVC")
		#reduce MSVC Compiler Warning C5105 to warning level 1
		message(STATUS "Compile definition added: _CRT_SECURE_NO_WARNINGS (${target})")
		target_compile_definitions(${PROJECT_NAME}
			PRIVATE
				_CRT_SECURE_NO_WARNINGS
		)
	endif()
endfunction()

function(GuardedImport target dir)
	if(TARGET ${target})
		message(STATUS "Target ${target} already defined!")
		return()
	endif()

	message(STATUS "GuardedImport: ${target} [dir: ${dir}]")

	if(${ARGC} GREATER 2)
		set(bin_dir ${ARGV2})
		message(STATUS "build dir (optional argument): ${bin_dir}")
	else()
		if(${target} MATCHES "(master)$")
			message(WARNING "Using automatic build directory for *master projects can lead to errors, because it is used twice. Consider using a real <target> as guard and specify a build directory <target>_master as third optional argument.")
		endif()
		set(bin_dir "${CMAKE_BINARY_DIR}/3rd_party/${target}")
		message(STATUS "build dir (automatic): ${bin_dir}")
	endif()

	add_subdirectory(
		"${dir}"
		"${bin_dir}"
	)

	if(TARGET ${target})
		message(STATUS "Defined target: ${target}")
	else()
		message(WARNING "Expected ${target} to be defined but it is NOT! Do you use the correct directory?")
	endif()
endfunction()

function(GuardedImportConfigurable parent target dir)
	if(TARGET ${target})
		message(STATUS "Target ${target} already defined!")
		return()
	endif()

	set(${parent}_${target}_IMPORT_DIR ${dir} CACHE
		PATH "Path to ${target} library used for target ${parent}.")

	get_filename_component(abs_dir "${${parent}_${target}_IMPORT_DIR}" ABSOLUTE)
		
	set(${target}_DIR ${abs_dir} CACHE
		PATH "Path to ${target} library (load of library for target ${parent}).")

	set(tmp ${BUILD_SHARED_LIBS})
	set(${parent}_${target}_BIND_SHARED OFF
		CACHE BOOL "Bind ${target} as shared library to target ${parent}.")
	mark_as_advanced(
		${parent}_${target}_IMPORT_DIR
	)

	set(BUILD_SHARED_LIBS ${${parent}_${target}_BIND_SHARED})
	GuardedImport(${target}
		${${parent}_${target}_IMPORT_DIR}
		"${CMAKE_BINARY_DIR}/3rd_party/${target}_import"
	)
	set(BUILD_SHARED_LIBS ${tmp})
endfunction()

function(SetupDebugInformation target)
	get_target_property(imported ${target} IMPORTED)
	if(NOT ${imported})
		#integrate debug information into library (no pdb)
		message(STATUS "Activated compile option /Z7 for Debug of ${target}")
		target_compile_options(${target}
			PRIVATE $<$<CONFIG:Debug>:/Z7>
		)
	endif()
endfunction()

#assumes build directory is two levels down of CMakeLists.txt location
function(DefaultInstallPrefix target_id)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
		set(CMAKE_INSTALL_PREFIX "../../install/${target_id}"
			CACHE PATH "Set the install prefix." FORCE)
	endif()
endfunction()

macro(DefaultOutputDirs target)
	set_target_properties(${target}
		PROPERTIES
			ARCHIVE_OUTPUT_DIRECTORY $<CONFIG>/bin
			LIBRARY_OUTPUT_DIRECTORY $<CONFIG>/lib
			RUNTIME_OUTPUT_DIRECTORY $<CONFIG>/lib
			PDB_OUTPUT_DIRECTORY $<CONFIG>/bin
			COMPILE_PDB_OUTPUT_DIRECTORY $<CONFIG>/lib
	)
endmacro()

macro(DefaultOutputDirs)
	DefaultOutputDirs(${PROJECT_NAME})
endmacro()

# define default variables for install setup, set them yourself in previous to override default values
macro(DefineProjectInstallVariables)
	set(${PROJECT_NAME}_INSTALL ${BUILD_SHARED_LIBS}
		CACHE BOOL "Enables installation of ${PROJECT_NAME}.")
	set(${PROJECT_NAME}_INSTALL_DEPENDENCIES ON
		CACHE BOOL "Enables installation of ${PROJECT_NAME} runtime dependencies.")
	set(${PROJECT_NAME}_INSTALL_PREFIX ""
		CACHE STRING "Set additional prefix for install of ${PROJECT_NAME}.")
	set(${PROJECT_NAME}_INSTALL_RUNTIME "bin$<$<NOT:$<CONFIG:Release>>:/$<CONFIG>>"
		CACHE STRING "Suffix to destination for runtime targets.")
	set(${PROJECT_NAME}_INSTALL_LIBRARY "lib$<$<NOT:$<CONFIG:Release>>:/$<CONFIG>>"
		CACHE STRING "Suffix to destination for library targets.")
	set(${PROJECT_NAME}_INSTALL_ARCHIVE "lib$<$<NOT:$<CONFIG:Release>>:/$<CONFIG>>"
		CACHE STRING "Suffix to destination for archive targets.")
	set(${PROJECT_NAME}_INSTALL_INCLUDE include/${PROJECT_NAME}
		CACHE STRING "Install destination for API headers.")
	set(${PROJECT_NAME}_INSTALL_PDB OFF
		CACHE BOOL "Install PDB files.")
	mark_as_advanced(
		${PROJECT_NAME}_INSTALL_DEPENDENCIES
		${PROJECT_NAME}_INSTALL_PREFIX
		${PROJECT_NAME}_INSTALL_RUNTIME
		${PROJECT_NAME}_INSTALL_LIBRARY
		${PROJECT_NAME}_INSTALL_ARCHIVE
		${PROJECT_NAME}_INSTALL_INCLUDE
		${PROJECT_NAME}_INSTALL_PDB
	)
	set(${PROJECT_NAME}_EXPORT OFF
		CACHE BOOL "Create a ${PROJECT_NAME}.cmake file to import project via find_package in other projects.")
endmacro()

#needs predefined variable ${PROJECT_NAME}_INSTALL and ${PROJECT_NAME}_INSTALL_PREFIX and include_install
macro(DefaultProjectInstallAndExport)
	if(${PROJECT_NAME}_INSTALL)
		install(
			TARGETS
				${PROJECT_NAME}
			EXPORT ${PROJECT_NAME}Config
				COMPONENT
					${PROJECT_NAME}
			#used with CMAKE_INSTALL_PREFIX
			RUNTIME
				DESTINATION
					${${PROJECT_NAME}_INSTALL_PREFIX}${${PROJECT_NAME}_INSTALL_RUNTIME}
				COMPONENT
					${PROJECT_NAME}
			LIBRARY
				DESTINATION
					${${PROJECT_NAME}_INSTALL_PREFIX}${${PROJECT_NAME}_INSTALL_LIBRARY}
				COMPONENT
					${PROJECT_NAME}
			ARCHIVE
				DESTINATION
					${${PROJECT_NAME}_INSTALL_PREFIX}${${PROJECT_NAME}_INSTALL_ARCHIVE}
				COMPONENT
					${PROJECT_NAME}
			PUBLIC_HEADER
				DESTINATION
					${${PROJECT_NAME}_INSTALL_PREFIX}${${PROJECT_NAME}_INSTALL_INCLUDE}
				COMPONENT
					${PROJECT_NAME}
			INCLUDES
				DESTINATION
					${${PROJECT_NAME}_INSTALL_INCLUDE}
		)

		if(${PROJECT_NAME}_EXPORT)
			install(EXPORT ${PROJECT_NAME}Config
				DESTINATION
					"${${PROJECT_NAME}_INSTALL_PREFIX}cmake"
				COMPONENT
					${PROJECT_NAME}
			)
		endif()
		if(${PROJECT_NAME}_EXPORT_BUILD)
			export(EXPORT ${PROJECT_NAME}
				FILE
					"${CMAKE_CURRENT_BINARY_DIR}/cmake/${PROJECT_NAME}.cmake"
			)
		endif()

		get_target_property(target_type ${PROJECT_NAME} TYPE)
		if((target_type STREQUAL "STATIC_LIBRARY") OR (target_type STREQUAL "SHARED_LIBRARY"))

			install( DIRECTORY ${include}/
				DESTINATION
					${${PROJECT_NAME}_INSTALL_PREFIX}${${PROJECT_NAME}_INSTALL_INCLUDE}
				COMPONENT
					${PROJECT_NAME}
				FILES_MATCHING
					PATTERN "*${CMAKE_INSTALL_PREFIX}*" EXCLUDE
					PATTERN "*.git/*" EXCLUDE
					PATTERN "*.svn/*" EXCLUDE
					PATTERN "*.vs/*" EXCLUDE
					PATTERN "*build/*" EXCLUDE
					PATTERN "*install/*" EXCLUDE
					PATTERN "*.h"
					PATTERN "*.hpp"
			)
		endif()
		if(${${PROJECT_NAME}_INSTALL_PDB})
			InstallPdbFiles(${PROJECT_NAME})
		endif()
	endif()
endmacro()

macro(group_sources srcs)
	#unfortunately source_group() seems to not working properly
	#source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" PREFIX "main" FILES "${sources}")

	if(${ARGC} GREATER 1)
		get_filename_component(group_sources_root "${ARGV1}" ABSOLUTE)
		#message(STATUS "group sources from: ${group_sources_root}")
	else()
		set(group_sources_root ${CMAKE_CURRENT_SOURCE_DIR})
		#message(STATUS "group sources from: ${group_sources_root} [default]")
	endif()
	foreach(file ${srcs}) 
		#convert source file to absolute
		get_filename_component(abs_path "${file}" ABSOLUTE)
		#message(STATUS "abs_path: ${abs_path}")
		# Get the directory of the absolute source file
		get_filename_component(parent_dir "${abs_path}" DIRECTORY)
		#message(STATUS "parent_dir: ${parent_dir}")
		# Remove common directory prefix to make the group
		string(REPLACE "${group_sources_root}" "" group "${parent_dir}")
		#message(STATUS "group: ${group}")
		# Make sure we are using windows slashes
		string(REPLACE "/" "\\" group "${group}")
		#message(STATUS "group: ${group}")
		# Group into "Source Files" and "Header Files"
		#if ("${file}" MATCHES ".*\\.[c|cpp]")
		#	set(group "Source Files${group}")
		#elseif("${file}" MATCHES ".*\\.[h|hpp]")
		#	set(group "Header Files${group}")
		#endif()
		#message(STATUS "Grouped ${file} to ${group}")
		source_group("${group}" FILES "${file}")
	endforeach()
endmacro()

function(AddDoxygenOption target doxygen_dir)
	set(${target}_BUILD_DOC OFF CACHE BOOL "Build documentation of ${target}.")
	if(NOT ${target}_BUILD_DOC)
		return()
	endif()

	set(${target}_DOC_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PREFIX}docs/ CACHE STRING
		"Install directory for documentation of ${target}.")
	mark_as_advanced(${target}_DOC_INSTALL_PREFIX)
	message(STATUS "  >> Doxygen ${target} >>")
	message(STATUS "Doxygen install path: ${${target}_DOC_INSTALL_PREFIX}")
	find_package(Doxygen)
	if(DOXYGEN_FOUND)
		message(STATUS "Generate documentation for ${target}...")
		add_custom_target( ${target}_doxygen ALL
			COMMAND ${DOXYGEN_EXECUTABLE} "${doxygen_dir}/doxyfile.txt"
			WORKING_DIRECTORY "${doxygen_dir}"
			COMMENT "Generating ${target} documentation with Doxygen"
			VERBATIM
		)
		install(DIRECTORY
				"${doxygen_dir}/${target}/html/"
			DESTINATION
				"${${target}_DOC_INSTALL_PREFIX}html"
			COMPONENT
				${target}
		)
	elseif()
		message(WARNING "Doxygen not found. Documentation cannot be generated.  >>")
	endif()
	message(STATUS "  << Doxygen <<")
endfunction()

include(${CMAKE_CURRENT_LIST_DIR}/default_library.cmake)
