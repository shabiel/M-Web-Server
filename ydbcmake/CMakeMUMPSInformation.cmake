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

set(CMAKE_MUMPS_CREATE_SHARED_LIBRARY "<CMAKE_C_COMPILER> -shared -o <TARGET> <OBJECTS>")
set(CMAKE_MUMPS_CREATE_SHARED_MODULE "<CMAKE_C_COMPILER> <CMAKE_SHARED_LIBRARY_C_FLAGS> -o <TARGET> <OBJECTS>")
set(CMAKE_MUMPS_CREATE_STATIC_LIBRARY "")

# Option to suppress mumps compiler warnings
option(MUMPS_NOWARNING "Disable warnings and ignore status code from MUMPS compiler")
option(MUMPS_EMBED_SOURCE "Embed source code in generated shared object" ON)
option(MUMPS_DYNAMIC_LITERALS "Enable dynamic loading of source code literals" OFF)

set(CMAKE_MUMPS_COMPILE_OBJECT "LC_ALL=\"${LC_ALL}\" ydb_chset=\"${ydb_chset}\" ydb_icu_version=\"${icu_version}\" <CMAKE_MUMPS_COMPILER> -object=<OBJECT>")

if(MUMPS_EMBED_SOURCE)
  set(CMAKE_MUMPS_COMPILE_OBJECT "${CMAKE_MUMPS_COMPILE_OBJECT} -embed_source")
endif()

if(MUMPS_DYNAMIC_LITERALS)
  set(CMAKE_MUMPS_COMPILE_OBJECT "${CMAKE_MUMPS_COMPILE_OBJECT} -dynamic_literals")
endif()

if(MUMPS_NOWARNING)
  set(CMAKE_MUMPS_COMPILE_OBJECT "${CMAKE_MUMPS_COMPILE_OBJECT} -nowarning <SOURCE> || true")
else()
  set(CMAKE_MUMPS_COMPILE_OBJECT "${CMAKE_MUMPS_COMPILE_OBJECT} <SOURCE>")
endif()

set(CMAKE_MUMPS_LINK_EXECUTABLE "")

set(CMAKE_MUMPS_OUTPUT_EXTENSION .o)
