#!/bin/sh
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

cd "$(dirname "$(realpath -e "$0")")"
if [ -z "$ydb_dist" ] ; then
    export ydb_dist="$(pkg-config --variable=prefix yottadb)"; ydb_tmp_stat=$?
    if [ 0 -ne $ydb_tmp_stat ] || [ ! -d $ydb_dist ] ; then
	echo >&2 YDB installation directory not found. Exiting ; exit $ydb_tmp_stat
    fi
fi
set -e
# RHEL & derivates use a different cmake command name
if [ -x "$(command -v cmake3)" ]; then
  cmakeCommand="cmake3"
else
  cmakeCommand="cmake"
fi											
rm -rf build && mkdir build && cd build
echo "Installing M Mode Shared Library"
$cmakeCommand -DM_NOWARNING=1 -DM_UTF8_MODE=0 ..
make && make install
cd ..
if [ -d "$ydb_dist/utf8" ] ; then
	echo ""
	echo "Installing UTF-8 Mode Shared Library"
	rm -rf build && mkdir build && cd build
	$cmakeCommand -DM_NOWARNING=1 -DM_UTF8_MODE=1 ..
	make && make install
	cd ..
fi
