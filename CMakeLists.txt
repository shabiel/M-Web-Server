# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

# Prelim
cmake_minimum_required(VERSION 3.14)
include(ExternalProject)
include(FetchContent)

# The tag is at the time of writing the latest tag in YDBCMake.
# The tag is fixed at that point to ensure reproducible builds.
FetchContent_Declare(YDBCMake
	GIT_REPOSITORY	https://gitlab.com/YottaDB/Tools/YDBCMake.git
	GIT_TAG		84c5180d1f184a892f5cc52367ce51f9bc2eac7e
)
# The following sets ydbcmake_SOURCE_DIR
FetchContent_MakeAvailable(YDBCMake)
message(STATUS "YDBCMake Source Directory: ${ydbcmake_SOURCE_DIR}")
set(CMAKE_MODULE_PATH "${ydbcmake_SOURCE_DIR}/ydbcmake/")

project(MWebServer)
find_package(YOTTADB REQUIRED)

ExternalProject_Add(mwebserver-m
	PREFIX		mwebserver-m
	BUILD_ALWAYS	1  # Always rescan source directory for changes
	SOURCE_DIR	${CMAKE_CURRENT_SOURCE_DIR}/src/
	CMAKE_ARGS	-DM_NOWARNING=1 -DM_UTF8_MODE=0 -DCMAKE_MODULE_PATH=${ydbcmake_SOURCE_DIR}/ydbcmake/
	INSTALL_COMMAND	"" # Disable Install in the External Project portion
	)
ExternalProject_Get_Property(mwebserver-m binary_dir)
install(FILES ${binary_dir}/_ydbmwebserver.so DESTINATION "${YOTTADB_PLUGIN_PREFIX}/o")

if(EXISTS ${YOTTADB_INCLUDE_DIRS}/utf8)
	ExternalProject_Add(mwebserver-utf8
		PREFIX		mwebserver-utf8
		BUILD_ALWAYS	1  # Always rescan source directory for changes
		SOURCE_DIR	${CMAKE_CURRENT_SOURCE_DIR}/src/
		CMAKE_ARGS	-DM_UTF8_MODE=1 -DM_NOWARNING=1 -DCMAKE_MODULE_PATH=${ydbcmake_SOURCE_DIR}/ydbcmake/
		INSTALL_COMMAND	"" # Disable Install in the External Project portion
		)
	ExternalProject_Get_Property(mwebserver-utf8 binary_dir)
	install(FILES ${binary_dir}/_ydbmwebserver.so DESTINATION "${YOTTADB_PLUGIN_PREFIX}/o/utf8")
endif()
