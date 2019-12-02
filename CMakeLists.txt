# The MIT License (MIT)
#
# Copyright (c) 2015-2017 Simon Ninon <simon.ninon@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

###
# project
###
if (POLICY CMP0048)
  cmake_policy(SET CMP0048 NEW)
endif ()
if (POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif ()

project(cpp_redis
  VERSION 4.4.0
  DESCRIPTION "Lightweight C++11 Redis Client"
  HOMEPAGE_URL "https://github.com/cpp-redis/cpp_redis"
  LANGUAGES CXX)

###
# config
###
cmake_minimum_required(VERSION 3.13)

set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_CXX_STANDARD 11)

set(EXPORT_TARGET_NAME ${PROJECT_NAME} CACHE STRING "Name of the exported CMake target used in install(EXPORT)")

###
# verbose make
###
# set(CMAKE_VERBOSE_MAKEFILE TRUE)

include(sources.cmake)

###
# compilation options
###
if (MSVC)
  add_compile_options(/W3 /O2 /bigobj)

  # was causing conflics with gtest build
  string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})

  if ("${MSVC_RUNTIME_LIBRARY_CONFIG}" STREQUAL "")
    set(MSVC_RUNTIME_LIBRARY_CONFIG "/MT")
  endif ()

  foreach (flag_var CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE)
    if ("${MSVC_RUNTIME_LIBRARY_CONFIG}" STREQUAL "/MT")
      string(REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    elseif ("${MSVC_RUNTIME_LIBRARY_CONFIG}" STREQUAL "/MD")
      string(REPLACE "/MT" "/MD" ${flag_var} "${${flag_var}}")
    else ()
      string(REPLACE "/MD" "${MSVC_RUNTIME_LIBRARY_CONFIG}" ${flag_var} "${${flag_var}}")
      string(REPLACE "/MT" "${MSVC_RUNTIME_LIBRARY_CONFIG}" ${flag_var} "${${flag_var}}")
    endif ()
  endforeach ()

  add_definitions(-D_UNICODE)
  add_definitions(-DUNICODE)
  add_definitions(-DWIN32_LEAN_AND_MEAN)
else ()
  add_compile_options(-W -Wall -Wextra -O3)
endif ()

###
# tacopie
###
if (NOT tacopie_library AND NOT USE_CUSTOM_TCP_CLIENT)
  # requires CMP0077 set to NEW
  set(BUILD_EXAMPLES OFF)
  set(BUILD_TESTS OFF)
  add_subdirectory(tacopie)
  # TODO: add alias library
endif ()

set(cpp_redis_includes ${CMAKE_CURRENT_LIST_DIR}/includes)
set(deps_includes ${CMAKE_CURRENT_LIST_DIR}/deps/include)

set(deps_libraries ${PROJECT_SOURCE_DIR}/deps/lib)

# filter tcp_client if no tacopie
if (USE_CUSTOM_TCP_CLIENT)
  file(GLOB tacopie_cpp "sources/network/tcp_client.cpp")
  list(REMOVE_ITEM ${cpp_redis_sources} ${tacopie_cpp})
endif ()

###
# outputs
###
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_PKGCONFIG_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

###
# pkg-config
###
configure_file("${PROJECT_NAME}.pc.in" "${CMAKE_PKGCONFIG_OUTPUT_DIRECTORY}/${PROJECT_NAME}.pc" @ONLY)

###
# main target
###
add_library(${PROJECT_NAME} SHARED ${cpp_redis_sources})

###
# includes
###
target_include_directories(${PROJECT_NAME} PUBLIC
  $<BUILD_INTERFACE:${cpp_redis_includes}>
  $<INSTALL_INTERFACE:include>)

if (WIN32)
  set_target_properties(${PROJECT_NAME} PROPERTIES
    COMPILE_PDB_NAME ${PROJECT_NAME}
    COMPILE_PDB_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
endif ()

set_target_properties(${PROJECT_NAME} PROPERTIES
  SOVERSION ${PROJECT_VERSION}
  RESOURCE ${CMAKE_PKGCONFIG_OUTPUT_DIRECTORY}/${PROJECT_NAME}.pc)

find_package(Threads REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE Threads::Threads)

if (tacopie_library)
  target_link_libraries(${PROJECT_NAME} PUBLIC ${tacopie_library})
else ()
  target_link_libraries(${PROJECT_NAME} PUBLIC tacopie)
endif ()

###
# parameters
###
set(READ_SIZE "4096" CACHE STRING "Number of bytes read from sockets")
if (READ_SIZE MATCHES "^[1-9]+")
  target_compile_definitions(${PROJECT_NAME} PRIVATE __CPP_REDIS_READ_SIZE=${READ_SIZE})
endif ()

option(LOGGING_ENABLED "If true enables logging calls to cpp_redis::level()" OFF)
if (LOGGING_ENABLED)
  target_compile_definitions(${PROJECT_NAME} PRIVATE __CPP_REDIS_LOGGING_ENABLED)
endif ()

option(USE_CUSTOM_TCP_CLIENT "If true user must provide a custom tcp_client_iface instance, otherwise uses tacopie" OFF)
if (USE_CUSTOM_TCP_CLIENT)
  target_compile_definitions(${PROJECT_NAME} PRIVATE __CPP_REDIS_USE_CUSTOM_TCP_CLIENT)
endif ()

###
# install
###
install(DIRECTORY ${cpp_redis_includes}/ DESTINATION include USE_SOURCE_PERMISSIONS)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME} EXPORT ${EXPORT_TARGET_NAME}
  LIBRARY
  RESOURCE DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
install(EXPORT ${EXPORT_TARGET_NAME} DESTINATION lib/${PROJECT_NAME} EXPORT_LINK_INTERFACE_LIBRARIES)

###
# examples
###
if (BUILD_EXAMPLES)
  add_subdirectory(examples)
endif ()

###
# tests
###
if (BUILD_TESTS)
  enable_testing()
  if (NOT TARGET gtest)
    set(INSTALL_GTEST OFF)
    add_subdirectory(googletest)
  endif ()
  add_subdirectory(tests)
endif ()
