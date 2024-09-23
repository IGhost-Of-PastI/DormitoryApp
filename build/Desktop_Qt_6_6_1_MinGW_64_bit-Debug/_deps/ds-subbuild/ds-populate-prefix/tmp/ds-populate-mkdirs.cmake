# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-src"
  "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-build"
  "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-subbuild/ds-populate-prefix"
  "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-subbuild/ds-populate-prefix/tmp"
  "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-subbuild/ds-populate-prefix/src/ds-populate-stamp"
  "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-subbuild/ds-populate-prefix/src"
  "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-subbuild/ds-populate-prefix/src/ds-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-subbuild/ds-populate-prefix/src/ds-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "G:/Qt Projects/DormitoryApp/build/Desktop_Qt_6_6_1_MinGW_64_bit-Debug/_deps/ds-subbuild/ds-populate-prefix/src/ds-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
