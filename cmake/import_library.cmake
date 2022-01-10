cmake_minimum_required(VERSION 3.10)

include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/system.cmake)

function(DelayLoad parent target)
	if(NOT TARGET ${target})
		message(FATAL_ERROR "${target} is not a target!")
		return()
	endif()
	
	get_target_property(target_type ${target} TYPE)
	if (NOT target_type STREQUAL "SHARED_LIBRARY")
		message(STATUS "${target} is not a shared library, DelayLoad skipped.")
		return()
	endif ()	

	if(NOT WIN32)
		message(STATUS "DelayLoad only supported for Windows.")
		return()
	endif()
	
	message(STATUS "DelayLoad of ${target}. (${parent})")
	target_link_libraries(${parent}
		PRIVATE
			Delayimp
	)

	target_link_options(${parent}
		PRIVATE
			/DELAYLOAD:$<TARGET_FILE_NAME:${target}>
	)
	
endfunction()

function(ImportUnlinkable
	lib_name
	bin_release_file
	bin_debug_file
)
	# import a shared library
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported.")
		return()
	endif()

	foreach(filename
		bin_release_file
		bin_debug_file
	)
		if(NOT EXISTS "${${filename}}")
			message(SEND_ERROR "file does not exist: ${${filename}}")
		else()
			message(STATUS "${filename}: ${${filename}}")
		endif()
	endforeach()

	add_library(${lib_name} SHARED IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION_RELEASE "${bin_release_file}"
		IMPORTED_LOCATION_DEBUG   "${bin_debug_file}"
	)

	# set property of configurations for installing dll's to projects target side
	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported shared library: ${lib_name}.")
endfunction()

function(ImportShared
	lib_name
	lib_release
	lib_release_prefix
	lib_release_suffix
	lib_debug
	lib_debug_prefix
	lib_debug_suffix
	bin_release
	bin_release_prefix
	bin_release_suffix
	bin_debug
	bin_debug_prefix
	bin_debug_suffix
	lib_include
)
	# import a shared library
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(lib_release_file "${lib_release}/${lib_release_prefix}${lib_name}${lib_release_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(bin_release_file "${bin_release}/${bin_release_prefix}${lib_name}${bin_release_suffix}${CMAKE_SHARED_LIBRARY_SUFFIX}")
	set(lib_debug_file "${lib_debug}/${lib_debug_prefix}${lib_name}${lib_debug_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(bin_debug_file "${bin_debug}/${bin_debug_prefix}${lib_name}${bin_debug_suffix}${CMAKE_SHARED_LIBRARY_SUFFIX}")

	foreach(filename
		lib_release_file
		bin_release_file
		lib_debug_file
		bin_debug_file
	)
		if(NOT EXISTS "${${filename}}")
			message(SEND_ERROR "file does not exist: ${${filename}}")
		else()
			message(STATUS "${filename}: ${${filename}}")
		endif()
	endforeach()

	add_library(${lib_name} SHARED IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION_RELEASE     "${bin_release_file}"
		IMPORTED_IMPLIB_RELEASE       "${lib_release_file}"
		IMPORTED_LOCATION_DEBUG       "${bin_debug_file}"
		IMPORTED_IMPLIB_DEBUG         "${lib_debug_file}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	# set property of configurations for installing dll's to projects target side
	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported shared library: ${lib_name}")
endfunction()

function(ImportShared_NoConfig
	lib_name
	lib_dir
	lib_prefix
	lib_suffix
	bin_dir
	bin_prefix
	bin_suffix
	lib_include
)
	# import a shared library
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(lib_file "${lib_dir}/${lib_prefix}${lib_name}${lib_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(bin_file "${bin_dir}/${bin_prefix}${lib_name}${bin_suffix}${CMAKE_SHARED_LIBRARY_SUFFIX}")

	foreach(filename
		lib_file
		bin_file
	)
		if(NOT EXISTS "${${filename}}")
			message(SEND_ERROR "file does not exist: ${${filename}}")
		else()
			message(STATUS "${filename}: ${${filename}}")
		endif()
	endforeach()

	add_library(${lib_name} SHARED IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION "${bin_file}"
		IMPORTED_IMPLIB   "${lib_file}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	message(STATUS "imported shared library: ${lib_name}")
endfunction()

function(ImportSharedTarget
	lib_name
	lib_release
	lib_debug
	bin_release
	bin_debug
	lib_include
)
	# import a shared library
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(lib_release_file "${lib_release}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(bin_release_file "${bin_release}${CMAKE_SHARED_LIBRARY_SUFFIX}")
	set(lib_debug_file "${lib_debug}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(bin_debug_file "${bin_debug}${CMAKE_SHARED_LIBRARY_SUFFIX}")

	foreach(filename
		lib_release_file
		bin_release_file
		lib_debug_file
		bin_debug_file
	)
		if(NOT EXISTS "${${filename}}")
			message(SEND_ERROR "file does not exist: ${${filename}}")
		else()
			message(STATUS "${filename}: ${${filename}}")
		endif()
	endforeach()
	message(STATUS "${lib_name} include: ${lib_include}")

	add_library(${lib_name} SHARED IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION_RELEASE     "${bin_release_file}"
		IMPORTED_IMPLIB_RELEASE       "${lib_release_file}"
		IMPORTED_LOCATION_DEBUG       "${bin_debug_file}"
		IMPORTED_IMPLIB_DEBUG         "${lib_debug_file}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	# set property of configurations for installing dll's to projects target side
	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported shared library: ${lib_name}")
endfunction()

function(ImportSharedTarget_NoConfig
	lib_name
	lib_file
	bin_file
	lib_include
)
	# import a shared library
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(lib_file "${lib_file}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(bin_file "${bin_file}${CMAKE_SHARED_LIBRARY_SUFFIX}")

	foreach(filename
		lib_file
		bin_file
	)
		if(NOT EXISTS "${${filename}}")
			message(SEND_ERROR "file does not exist: ${${filename}}")
		else()
			message(STATUS "${filename}: ${${filename}}")
		endif()
	endforeach()
	message(STATUS "${lib_name} include: ${lib_include}")

	add_library(${lib_name} SHARED IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION     "${bin_file}"
		IMPORTED_IMPLIB       "${lib_file}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	# set property of configurations for installing dll's to projects target side
	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported shared library: ${lib_name}")
endfunction()

function(ImportStatic
	lib_name
	lib_release
	lib_release_prefix
	lib_release_suffix
	lib_debug
	lib_debug_prefix
	lib_debug_suffix
	lib_include
)
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(lib_release_file "${lib_release}/${lib_release_prefix}${lib_name}${lib_release_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(lib_debug_file "${lib_debug}/${lib_debug_prefix}${lib_name}${lib_debug_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX}")

	foreach(filename
		lib_release_file
		lib_debug_file
	)
		if(NOT EXISTS "${${filename}}")
			message(SEND_ERROR "file does not exist: ${${filename}}")
		else()
			message(STATUS "${filename}: ${${filename}}")
		endif()
	endforeach()

	add_library(${lib_name} STATIC IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION_RELEASE     "${lib_release_file}"
		IMPORTED_LOCATION_DEBUG       "${lib_debug_file}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported static library: ${lib_name}")
endfunction()

function(ImportStatic_NoConfig
	lib_name
	lib_dir
	lib_prefix
	lib_suffix
	lib_include
)
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(lib_file "${lib_dir}/${lib_prefix}${lib_name}${lib_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX}")

	if(NOT EXISTS "${lib_file}")
		message(SEND_ERROR "file does not exist: ${lib_file}")
	else()
		message(STATUS "lib_file: ${lib_file}")
	endif()

	add_library(${lib_name} STATIC IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION "${lib_file}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	message(STATUS "imported static library: ${lib_name}")
endfunction()

function(ImportStaticTarget
	lib_name
	lib_release
	lib_debug
	lib_include
)
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(lib_release_file "${lib_release}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	set(lib_debug_file "${lib_debug}${CMAKE_STATIC_LIBRARY_SUFFIX}")

	foreach(filename
		lib_release_file
		lib_debug_file
	)
		if(NOT EXISTS "${${filename}}")
			message(SEND_ERROR "file does not exist: ${${filename}}")
		else()
			message(STATUS "${filename}: ${${filename}}")
		endif()
	endforeach()
	message(STATUS "${lib_name} include: ${lib_include}")

	add_library(${lib_name} STATIC IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION_RELEASE     "${lib_release_file}"
		IMPORTED_LOCATION_DEBUG       "${lib_debug_file}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported static library: ${lib_name}")
endfunction()

function(ImportStaticTarget_NoConfig
	lib_name
	lib_file
	lib_include
)
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	set(filename "${lib_file}${CMAKE_STATIC_LIBRARY_SUFFIX}")

	if(NOT EXISTS "${filename}")
		message(SEND_ERROR "file does not exist: ${filename}")
	else()
		message(STATUS "${lib_name} static library: ${filename}")
	endif()
	message(STATUS "${lib_name} include: ${lib_include}")

	add_library(${lib_name} STATIC IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		IMPORTED_LOCATION             "${filename}"
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported static library: ${lib_name}")
endfunction()

# header only libraries
function(ImportInterface
	lib_name
	lib_include
)
	if(TARGET ${lib_name})
		message(STATUS "${lib_name} already imported")
		return()
	endif()

	add_library(${lib_name} INTERFACE IMPORTED GLOBAL)

	set_target_properties(${lib_name} PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES "${lib_include}"
	)

	set_property(TARGET ${lib_name}
		APPEND
		PROPERTY IMPORTED_CONFIGURATIONS DEBUG RELEASE
	)

	message(STATUS "imported library: ${lib_name}")
endfunction()

function(InstallImportedStatic
	target
	install_dir
)
	get_target_property(include_dir ${target}
		INTERFACE_INCLUDE_DIRECTORIES
	)
	install(
		DIRECTORY
			"${include_dir}/"
		DESTINATION
			"${install_dir}/include"
		COMPONENT
			${PROJECT_NAME}
	)

	get_target_property(lib_release ${target}
		IMPORTED_LOCATION_RELEASE
	)
	get_target_property(lib_debug ${target}
		IMPORTED_LOCATION_DEBUG
	)
	install(
		FILES
			${lib_debug}
			${lib_release}
		DESTINATION
			"${install_dir}/lib"
		COMPONENT
			${PROJECT_NAME}
	)
endfunction()

function(InstallImportedShared
	target
	install_dir
)
	get_target_property(include_dir ${target}
		INTERFACE_INCLUDE_DIRECTORIES
	)
	install(
		DIRECTORY
			"${include_dir}/"
		DESTINATION
			"${install_dir}/include"
		COMPONENT
			${PROJECT_NAME}
	)

	get_target_property(bin_release ${target}
		IMPORTED_LOCATION_RELEASE
	)
	get_target_property(bin_debug ${target}
		IMPORTED_LOCATION_DEBUG
	)
	install(
		FILES
			${bin_debug}
			${bin_release}
		DESTINATION
			"${install_dir}/bin"
		COMPONENT
			${PROJECT_NAME}
	)

	get_target_property(lib_release ${target}
		IMPORTED_IMPLIB_RELEASE
	)
	get_target_property(lib_debug ${target}
		IMPORTED_IMPLIB_DEBUG
	)
	install(
		FILES
			${lib_debug}
			${lib_release}
		DESTINATION
			"${install_dir}/lib"
		COMPONENT
			${PROJECT_NAME}
	)
endfunction()

function(InstallImported
	target
	install_dir
)
	get_target_property(target_type ${target} TYPE)
	if(target_type STREQUAL "SHARED_LIBRARY")
		InstallImportedShared(${target} ${install_dir})
	elseif(target_type STREQUAL "STATIC_LIBRARY")
		InstallImportedStatic(${target} ${install_dir})
	else()
		message(WARNING "${target} of type ${target_type} can not be installed. Only SHARED_LIBRARY and STATIC_LIBRARY are supported.")
	endif()
endfunction()

function(switch_option target name options default)
	unset(${target}_DIR CACHE)
	set(__${name} ${options})
	set(${name} ${default}
		CACHE STRING "Compile mode for library.")
	set_property(CACHE ${name} PROPERTY STRINGS ${__${name}})
endfunction()

function(switch_import
	lib_name
	install_root
	source_root
)
	if(TARGET ${lib_name})
		message(STATUS " ${lib_name} already defined.")
		return()
	endif()

	unset(${lib_name}_DIR CACHE)
	set(__LIB_IMPORT_OPTIONS STATIC SHARED SOURCES)
	set(${lib_name}_IMPORT STATIC CACHE STRING "Import mode for library.")
	set_property(CACHE ${lib_name}_IMPORT PROPERTY STRINGS ${__LIB_IMPORT_OPTIONS})
	if(${${lib_name}_IMPORT} STREQUAL STATIC)
		# import static library
		message(STATUS "  >> import ${lib_name} as static >>")
		generate_target_id(target_id)
		set(${lib_name}_DIR "${install_root}/${target_id}_static")
		message(STATUS "prefix: ${${lib_name}_DIR}")
		find_package(${lib_name} REQUIRED CONFIG
			PATHS ${${lib_name}_DIR}
		)
	elseif(${${lib_name}_IMPORT} STREQUAL SHARED)
		# import shared library
		message(STATUS "  >> import ${lib_name} as shared >>")
		generate_target_id(target_id)
		set(${lib_name}_DIR "${install_root}/${target_id}_shared")
		message(STATUS "prefix: ${${lib_name}_DIR}")
		find_package(${lib_name} REQUIRED CONFIG
			PATHS ${${lib_name}_DIR}
		)
	elseif(${${lib_name}_IMPORT} STREQUAL SOURCES)
		# import library from source
		message(STATUS "  >> import  ${lib_name} from sources >>")
		set(${lib_name}_DIR ${source_root})
		add_subdirectory(
			"${${lib_name}_DIR}"
			"${CMAKE_BINARY_DIR}/3rdparty/ ${lib_name}"
		)
	endif()
	message(STATUS "${lib_name}_DIR: ${${lib_name}_DIR}")
	message(STATUS "  << import ${lib_name} <<")
endfunction()
