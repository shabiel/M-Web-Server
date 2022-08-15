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
project(MWebServer C M)
set(M_NOWARNING "ON")

# Find YottaDB and set Install Destination
find_package(YOTTADB REQUIRED)
set(CMAKE_INSTALL_PREFIX ${YOTTADB_M_PLUGIN_DIR})
message(STATUS "Install Location: ${YOTTADB_M_PLUGIN_DIR}")

# CMake Build Type (req b/c it's C code (we need ld from the C toolkit))
if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# Sources
set(source_files
  _webapi.m
  _webhome.m
  _webjson.m
  _webjsonDecode.m
  _webjsonEncode.m
  _webreq.m
  _webrsp.m
  _webutils.m
)

# .so file for plugin
add_library(_ydbmwebserver SHARED ${source_files})
SET_TARGET_PROPERTIES(_ydbmwebserver PROPERTIES PREFIX "")

# Install shared library
install(TARGETS _ydbmwebserver DESTINATION ${CMAKE_INSTALL_PREFIX})
