cmake_minimum_required(VERSION 3.16)

if(DEFINED ENV{CRAFTROOT})
    set(_craft_prefix "$ENV{CRAFTROOT}")
    list(FIND CMAKE_PREFIX_PATH "${_craft_prefix}" _craft_index)
    if(_craft_index GREATER 0)
        list(REMOVE_AT CMAKE_PREFIX_PATH ${_craft_index})
    endif()
    if(_craft_index EQUAL -1 OR _craft_index GREATER 0)
        list(PREPEND CMAKE_PREFIX_PATH "${_craft_prefix}")
    endif()
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" CACHE STRING "Augmented search path (Craft first)" FORCE)
    if(NOT DEFINED Qt6_DIR)
        set(_craft_qt_dir "$ENV{CRAFTROOT}/lib/cmake/Qt6")
        if(EXISTS "${_craft_qt_dir}/Qt6Config.cmake")
            set(Qt6_DIR "${_craft_qt_dir}" CACHE PATH "Qt6 config path (CraftRoot)" FORCE)
        endif()
        unset(_craft_qt_dir)
    endif()
    unset(_craft_index)
    unset(_craft_prefix)
endif()

project(Vincent VERSION 0.1 LANGUAGES CXX)

set(QT_MIN_VERSION "6.8.0")
set(KF_MIN_VERSION "6.2.0")

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

add_subdirectory(App)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
