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

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Quick QuickControls2)
find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 I18n)
find_package(KF6KirigamiPlatform ${KF_MIN_VERSION} REQUIRED)

qt_standard_project_setup(REQUIRES ${QT_MIN_VERSION})

qt_add_executable(painterforunix
    main.cpp
)

qt_add_qml_module(painterforunix
    URI PainterForUNIX
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/PainterCanvasPage.qml
        qml/CanvasToolBar.qml
        qml/DrawingSurface.qml
)

qt_import_qml_plugins(painterforunix)

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

target_link_libraries(painterforunix
    PRIVATE Qt6::Quick
            Qt6::QuickControls2
            KF6::Kirigami2
            KF6::I18n
            KF6::KirigamiPlatform
)

install(TARGETS painterforunix ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
