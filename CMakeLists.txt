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
	GIT_TAG		c0458d5bd2b672b12c4b73cc47e2221146a40502
)
# The following sets ydbcmake_SOURCE_DIR
FetchContent_MakeAvailable(YDBCMake)
message(STATUS "YDBCMake Source Directory: ${ydbcmake_SOURCE_DIR}")
set(CMAKE_MODULE_PATH "${ydbcmake_SOURCE_DIR}/ydbcmake/")

set(M_NOWARNING "ON")
project(MWebServer M)
find_package(YOTTADB REQUIRED)

# Sources
set(source_files
  src/_webapi.m
  src/_webhome.m
  src/_webjson.m
  src/_webjsonDecode.m
  src/_webjsonEncode.m
  src/_webreq.m
  src/_webrsp.m
  src/_webutils.m
)

add_ydb_library(_ydbmwebserver SOURCES ${source_files})
install_ydb_library(_ydbmwebserver)
