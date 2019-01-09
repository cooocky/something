#!/bin/bash

# Customization
#tNavPath="/home/alexey.kobzarev/tNavigator"
#buildPath="/home/alexey.kobzarev/tNavigator/out/debug_gcc"
#cc_compiler="/opt/rfd/gcc-7.2/bin/gcc"
#cxx_compiler="/opt/rfd/gcc-7.2/bin/g++"
#rootTarget=tNavigator

# Gen cmake file
echo "cmake_minimum_required(VERSION 3.12)" > CMakeLists.txt
echo "set(CMAKE_CXX_STANDARD 14)" >> CMakeLists.txt
echo 'set(CMAKE_EXPORT_COMPILE_COMMANDS ON)' >> CMakeLists.txt

echo "set(CMAKE_C_COMPILER $cc_compiler)" >> CMakeLists.txt
echo "set(CMAKE_CXX_COMPILER $cxx_compiler)" >> CMakeLists.txt

echo "project(${rootTarget})" >> CMakeLists.txt

# Gen defines
while read l; do
    wordsCount=$(echo "${l}" | wc -w)
    macro=$(echo ${l} | awk '{print $2}')
    if [ "${wordsCount}" = "2" ]; then
        echo -e "add_compile_definitions(${macro})" >> CMakeLists.txt
    elif [ "${wordsCount}" = "3" ]; then
        val=$(echo ${l} | awk '{print $3}')
        echo -e "add_compile_definitions(${macro}=${val})" >> CMakeLists.txt
    fi
done < "$buildPath/qtcreator_project/all.config"

# Gen includes (except Qt)
while read l; do
    echo -e "include_directories(${l})" | grep -v Qt >> CMakeLists.txt
done < "$buildPath/qtcreator_project/all.includes"

# Enable Qt
qtModules=(Qt5Core Qt5Gui Qt5Network Qt5OpenGL Qt5PrintSupport Qt5Sql Qt5Svg Qt5Widgets)
for mod in ${qtModules[*]}; do
    echo "find_package ($mod)" >> CMakeLists.txt
done

# Gen files
echo "set(${rootTarget}_SOURCES " >> CMakeLists.txt

while read l; do
    if [ -f "${l}" ]; then
        echo -e "\t${l}" >> CMakeLists.txt
    fi
done < "$buildPath/qtcreator_project/all.files"

echo ")" >> CMakeLists.txt

echo "set (CMAKE_CXX_FLAGS \"-fPIC -include ${tNavPath}/src/pch/precompiled_header.h \${CMAKE_CXX_FLAGS}\")" >> CMakeLists.txt
echo "add_executable(${rootTarget} \${${rootTarget}_SOURCES})" >> CMakeLists.txt
echo "qt5_use_modules(tNavigator Core Gui Network OpenGL PrintSupport Sql Svg Widgets)" >> CMakeLists.txt
