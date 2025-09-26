if(APPLE)
    set(CMAKE_FIND_FRAMEWORK FIRST)
    list(PREPEND CMAKE_SYSTEM_FRAMEWORK_PATH
        "${CMAKE_OSX_SYSROOT}/System/Library/Frameworks"
        "${CMAKE_OSX_SYSROOT}/Library/Frameworks")

    set(CMAKE_DISABLE_FIND_PACKAGE_OpenGL ON CACHE BOOL "" FORCE)
    set(CMAKE_DISABLE_FIND_PACKAGE_WrapOpenGL ON CACHE BOOL "" FORCE)

    if(NOT TARGET WrapOpenGL::WrapOpenGL)
        add_library(WrapOpenGL::WrapOpenGL INTERFACE IMPORTED)
        target_link_libraries(WrapOpenGL::WrapOpenGL INTERFACE "-framework OpenGL")
    endif()

    set(WrapOpenGL_FOUND TRUE CACHE BOOL "" FORCE)
    set(OPENGL_LIBRARIES "-framework OpenGL" CACHE STRING "" FORCE)
    set(OPENGL_gl_LIBRARY "-framework OpenGL" CACHE STRING "" FORCE)
    set(OPENGL_opengl_LIBRARY "-framework OpenGL" CACHE STRING "" FORCE)
    set(OPENGL_INCLUDE_DIR "" CACHE PATH "" FORCE)
endif()

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS
        Quick
        QuickControls2)
find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami
        I18n
        svg)
find_package(KF6KirigamiPlatform ${KF_MIN_VERSION} REQUIRED)

qt_standard_project_setup(REQUIRES ${QT_MIN_VERSION})

qt_add_executable(Vincent
        MANUAL_FINALIZATION
        MACOSX_BUNDLE
        main.cpp
)

target_sources(Vincent PRIVATE
        resources.qrc
)

qt_add_qml_module(Vincent
    URI Vincent
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/PainterCanvasPage.qml
        qml/CanvasToolBar.qml
        qml/DrawingSurface.qml
)

# macOS bundle configuration
set(VINCENT_BUNDLE_IDENTIFIER "com.iisacc.vincent" CACHE STRING "Bundle identifier used for the Vincent macOS bundle")
set(VINCENT_APP_ICON "${CMAKE_SOURCE_DIR}/resources/icon.icns" CACHE FILEPATH "Path to .icns app icon")

if(APPLE)

    get_filename_component(_vincent_icon_abs "${VINCENT_APP_ICON}" ABSOLUTE)
    if(NOT EXISTS "${_vincent_icon_abs}")
        message(FATAL_ERROR "VINCENT_APP_ICON points to '${_vincent_icon_abs}', but the file does not exist.")
    endif()

    get_filename_component(_vincent_icon_ext "${_vincent_icon_abs}" EXT)
    if(NOT _vincent_icon_ext STREQUAL ".icns")
        message(FATAL_ERROR "VINCENT_APP_ICON must be a .icns file. Given: '${_vincent_icon_abs}'")
    endif()

    get_filename_component(_vincent_icon_name_we "${_vincent_icon_abs}" NAME_WE)

    target_sources(Vincent PRIVATE "${_vincent_icon_abs}")
    set_source_files_properties("${_vincent_icon_abs}" PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    set_target_properties(Vincent PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_ICON_FILE "${_vincent_icon_name_we}"
            MACOSX_BUNDLE_GUI_IDENTIFIER "${VINCENT_BUNDLE_IDENTIFIER}"
            MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
            MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    )
endif()

if(APPLE)
    set(_sdk_gl "${CMAKE_OSX_SYSROOT}/System/Library/Frameworks/OpenGL.framework/Headers/gl.h")
    if(EXISTS "${_sdk_gl}")
        message(STATUS "OpenGL.h in SDK: YES -> ${_sdk_gl}")
    else()
        message(STATUS "OpenGL.h in SDK: NO")
    endif()

    if(DEFINED ENV{SDK_GL_H_EXISTS})
        message(STATUS "GL.h exists? $ENV{SDK_GL_H_EXISTS}")
    else()
        message(STATUS "GL.h exists? (env var not set)")
    endif()
endif()

set(APPLE_SUPPRESS_X11_WARNING ON)

target_link_libraries(Vincent
    PRIVATE Qt6::Quick
            Qt6::QuickControls2
)

target_link_libraries(Vincent
        PRIVATE
        KF6::Kirigami
        KF6::I18n
        KF6::KirigamiPlatform
)

qt_finalize_executable(Vincent)

install(TARGETS Vincent ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
