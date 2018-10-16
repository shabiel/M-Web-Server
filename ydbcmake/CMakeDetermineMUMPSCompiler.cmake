# Sets the following variables:
#  CMAKE_MUMPS_COMPILER

find_path(YOTTADB_INCLUDE_DIR NAMES libyottadb.h
          HINTS $ENV{ydb_dist} $ENV{gtm_dist})

set(YOTTADB_INCLUDE_DIRS ${YOTTADB_INCLUDE_DIR})

if(MUMPS_UTF8_MODE)
  set(CMAKE_MUMPS_COMPILER ${YOTTADB_INCLUDE_DIRS}/utf8/mumps)
else()
  set(CMAKE_MUMPS_COMPILER ${YOTTADB_INCLUDE_DIRS}/mumps)
endif()


configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeMUMPSCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeMUMPSCompiler.cmake
  )

set(CMAKE_MUMPS_COMPILER_ENV_VAR "mumps")
