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
# executables
###
set(main "sources/main.cpp")

macro(add_spec_test source)
  get_filename_component(test_name ${source} NAME_WE)
  add_executable(${test_name} ${main} ${source})
  target_link_libraries(${test_name} PRIVATE ${PROJECT_NAME} gtest Threads::Threads)
  add_test(NAME ${PROJECT_NAME}::${test_name}_tests COMMAND ${test_name})
endmacro()

set(tests
  sources/spec/builders/array_builder_spec.cpp
  sources/spec/builders/integer_builder_spec.cpp
  sources/spec/builders/builders_factory_spec.cpp
  sources/spec/builders/reply_builder_spec.cpp
  sources/spec/builders/bulk_string_builder_spec.cpp
  sources/spec/builders/simple_string_builder_spec.cpp
  sources/spec/builders/error_builder_spec.cpp
  sources/spec/redis_client_spec.cpp
  sources/spec/redis_subscriber_spec.cpp
  sources/spec/reply_spec.cpp)

foreach(test ${tests})
  add_spec_test(${test})
endforeach()
