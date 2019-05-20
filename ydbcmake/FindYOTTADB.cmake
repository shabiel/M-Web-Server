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

#  YOTTADB_FOUND - System has YottaDB
#  YOTTADB_INCLUDE_DIRS - The YottaDB include directories
#  YOTTADB_LIBRARIES - The libraries needed to use YottaDB

find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    # See comment in ydbcmake/CMakeDetermineMUMPSCompiler.cmake for why the below two set commands are needed.
    set(CMAKE_FIND_LIBRARY_PREFIXES "lib")
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".so;.a;.dylib")
    pkg_check_modules(PC_YOTTADB QUIET yottadb)
endif()

# If $ydb_dist is defined, use that as YottaDB dir, if not check $gtm_dist (for a GT.M version build)
# and if neither is defined, check if pkg-config found YottaDB installed.
# Note: We check for "mumps" executable (instead of say "libyottadb.h") since this is guaranteed to be present
#       both in a YottaDB and GT.M build/install directory.
find_path(YOTTADB_INCLUDE_DIRS NAMES mumps
	HINTS $ENV{ydb_dist} $ENV{gtm_dist} ${PC_YOTTADB_INCLUDEDIR} )
find_library(YOTTADB_LIBRARY NAMES yottadb gtmshr
  HINTS $ENV{ydb_dist} $ENV{gtm_dist} ${PC_YOTTADB_LIBRARY_DIRS} )

set(YOTTADB_LIBRARIES ${YOTTADB_LIBRARY})
set(YOTTADB_PLUGIN_DIR "${YOTTADB_INCLUDE_DIRS}/plugin/")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(YOTTADB  DEFAULT_MSG
                                  YOTTADB_LIBRARIES YOTTADB_INCLUDE_DIRS)

mark_as_advanced(YOTTADB_INCLUDE_DIRS YOTTADB_LIBRARIES)
