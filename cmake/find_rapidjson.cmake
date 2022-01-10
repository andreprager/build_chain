cmake_minimum_required(VERSION 3.10)

include_guard()

# FindRapidJSON.cmake
#
# Finds the rapidjson library
#
# This will define the following variables
#
#    RapidJSON_FOUND
#    RapidJSON_INCLUDE_DIRS
#
# and the following imported targets
#
#     RapidJSON::RapidJSON
#
# Author: Pablo Arias - pabloariasal@gmail.com

macro(findRapidJson path)
	message(STATUS "RapidJSON path: ${path}")

	find_package(RapidJSON REQUIRED
		PATHS "${path}"
	)

	if(RapidJSON_FOUND)
		set(RapidJSON_INCLUDE_DIRS ${RapidJSON_INCLUDE_DIR})
		if(NOT TARGET RapidJSON::RapidJSON)
			add_library(RapidJSON::RapidJSON INTERFACE IMPORTED)
			set_target_properties(RapidJSON::RapidJSON PROPERTIES
				INTERFACE_INCLUDE_DIRECTORIES "${RapidJSON_INCLUDE_DIR}"
			)
		endif()
	else()
		message(FATAL_ERROR "RapidJSON not found.")
	endif()
endmacro()

macro(Default_rapidjson)
	set(${PROJECT_NAME}_RapidJson_DIR
		"${${PROJECT_NAME}_3rdparty_DIR}/rapidjson/install/${target_id}/lib/cmake"
		CACHE PATH "Path to cmake file of RapidJson library.")
	findRapidJson(
		"${${PROJECT_NAME}_RapidJson_DIR}"
	)
endmacro()
