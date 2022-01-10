cmake_minimum_required(VERSION 3.10)

include_guard()

#copy shared library dependency to depending target's build tree
function(AddRuntimeDependencies depending_target dependency)
	get_target_property(depending_target_type ${depending_target} TYPE)
	get_target_property(dependency_type ${dependency} TYPE)
	if(dependency_type STREQUAL "SHARED_LIBRARY")
		message(STATUS "Add runtime dependency for ${depending_target} of ${dependency} [${dependency_type}].")
		# copy command for found shared library
		if(2 LESS ${ARGC})
			set(suffix ${ARGV2})
		else()
			set(suffix "")
		endif()
		
		add_custom_command(TARGET ${depending_target} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E echo
				"Copying: $<TARGET_FILE:${dependency}> to $<TARGET_FILE_DIR:${depending_target}>${suffix}"
			COMMAND ${CMAKE_COMMAND} -E make_directory
				"$<TARGET_FILE_DIR:${depending_target}>${suffix}"
			COMMAND ${CMAKE_COMMAND} -E copy_if_different
				$<TARGET_FILE:${dependency}>
				"$<TARGET_FILE_DIR:${depending_target}>${suffix}"
		)
	else()
		message(STATUS "No runtime dependency found for ${depending_target} of ${dependency} [${dependency_type}].")
	endif()
endfunction()

function(AddRuntimeFiles target files)
	message(STATUS "Add runtime files for ${target}: ${files}")

	if(2 LESS ${ARGC})
		set(suffix ${ARGV2})
	else()
		set(suffix "")
	endif()
	
	foreach(filename ${files})
		message(STATUS "Added file: ${filename} [${target}] (suffix: ${suffix})")
		add_custom_command(TARGET ${target} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E echo
				"Copying: ${filename} to $<TARGET_FILE_DIR:${target}>${suffix}"
			COMMAND ${CMAKE_COMMAND} -E make_directory
				"$<TARGET_FILE_DIR:${target}>${suffix}"
			COMMAND ${CMAKE_COMMAND} -E copy_if_different
				${filename}
				"$<TARGET_FILE_DIR:${target}>${suffix}"
			COMMAND ${CMAKE_COMMAND} -E echo "... done."
		)
	endforeach()
endfunction()

function(AddRuntimeDir target dir)
	message(STATUS "Add runtime directory for ${target}: ${dir}")

	if(2 LESS ${ARGC})
		set(suffix ${ARGV2})
	else()
		set(suffix "")
	endif()
	
	message(STATUS "Added directory: ${dir} [${target}] (suffix: ${suffix})")
	add_custom_command(TARGET ${target} POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E echo
			"Copying: ${dir} to $<TARGET_FILE_DIR:${target}>${suffix}"
		COMMAND ${CMAKE_COMMAND} -E make_directory
			"$<TARGET_FILE_DIR:${target}>${suffix}"
		COMMAND ${CMAKE_COMMAND} -E copy_directory
			${dir}
			"$<TARGET_FILE_DIR:${target}>${suffix}"
		COMMAND ${CMAKE_COMMAND} -E echo "... done."
	)
endfunction()

#install shared library dependency to depending target's install destination
function(InstallRuntimeDependencies depending_target dependency install_dir)
	get_target_property(dependency_type ${dependency} TYPE)
	if(dependency_type STREQUAL "SHARED_LIBRARY")
		message(STATUS "Install runtime dependencies for ${depending_target} of ${dependency} [${dependency_type}].")
		install(
			FILES
				$<TARGET_FILE:${dependency}>
			DESTINATION
				${install_dir}
			COMPONENT
				${depending_target}
		)
	else()
		message(STATUS "No runtime dependency found for ${depending_target} of ${dependency} [${dependency_type}].")
	endif()
endfunction()

function(InstallRuntimeFiles target files)
	if(NOT ${${target}_INSTALL})
		message(STATUS "Install runtime files for ${target}. [SKIPPED]")
		return()
	endif()
	
	if(2 LESS ${ARGC})
		set(suffix ${ARGV2})
	else()
		set(suffix "")
	endif()
	
	foreach(filename ${files})
		message(STATUS "Install runtime file: ${filename} [${target}] (suffix: ${suffix})")
		install(
			FILES
				"${filename}"
			DESTINATION
				"${${target}_INSTALL_PREFIX}${${target}_INSTALL_RUNTIME}${suffix}"
			COMPONENT
				${target}
		)
	endforeach()
endfunction()

function(InstallRuntimeDir target dir)
	if(NOT ${${target}_INSTALL})
		message(STATUS "Install runtime directory for ${target}. [SKIPPED]")
		return()
	endif()
	
	if(2 LESS ${ARGC})
		set(suffix ${ARGV2})
	else()
		set(suffix "")
	endif()
	
	message(STATUS "Install runtime directory: ${dir} [${target}] (suffix: ${suffix})")
	install(
		DIRECTORY
			"${dir}"
		DESTINATION
			"${${target}_INSTALL_PREFIX}${${target}_INSTALL_RUNTIME}${suffix}"
		COMPONENT
			${target}
	)
endfunction()

#copy pdb-files for imported dependency to depending target's build tree
function(AddPdbFiles depending_target dependency)
	message(WARNING "AddPdbFiles is deprecated. Please remove this call!" )
endfunction()

#copy pdb-files for imported dependency to depending target's build tree
function(InstallPdbFiles target)
	message(WARNING "InstallPdbFiles is deprecated. Please remove this call!" )
endfunction()

