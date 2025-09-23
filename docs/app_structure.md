# PainterForUNIX Application Structure

This document captures the current architecture of PainterForUNIX as observed in the repository. It describes how the project is laid out, how the build system is wired, and how the runtime pieces cooperate to deliver the painting experience.

## Top-Level Layout

- `CMakeLists.txt` (root) – bootstraps ECM/KF, applies common KDE settings, and delegates to the application sources in `App/`.
- `App/` – contains all C++ and QML code for the application bundle.
- `build/`, `cmake-build-debug/` – out-of-source build trees (ignored in project description, but important to keep generated artifacts isolated).

No other product source directories are present at this time.

## Build System Overview

The project relies on KDE's Extra CMake Modules (ECM) paired with Qt 6 and KDE Frameworks 6.

1. The root `CMakeLists.txt` ensures Craft-provided prefixes take priority when `CRAFTROOT` is set. It then configures ECM, KDE install paths, and compiler settings before adding the `App/` subdirectory.
2. `App/CMakeLists.txt` locates the runtime dependencies: `Qt6::Quick`, `Qt6::QuickControls2`, `KF6::Kirigami2`, `KF6::I18n`, and `KF6::KirigamiPlatform`.
3. A single executable target, `painterforunix`, is defined around `App/main.cpp`.
4. `qt_add_qml_module` registers the `PainterForUNIX` QML module version 1.0, exposing the components under `App/qml/` to the QML engine at runtime.
5. macOS-specific blocks adjust OpenGL discovery so Qt Quick works even when SDK headers are missing from the default search paths.
6. The executable links privately against the Qt/KF targets and is installed via the standard KDE install macro set.

## Runtime Entry Point (`App/main.cpp`)

- Creates the `QGuiApplication` instance that hosts the Qt Quick scene graph.
- Configures a `QQmlApplicationEngine` and augments its import paths when `CRAFTROOT` exposes prebuilt QML modules.
- Connects `objectCreationFailed` to `QCoreApplication::exit(-1)` for fail-fast behavior if the QML scene cannot load.
- Loads the `PainterForUNIX` QML module's `Main` component and starts the event loop.

No additional C++ types or singletons are registered; all UI and interaction logic lives in QML.

## QML Module Layout (`App/qml/`)

### `Main.qml`

- Declares the root `Kirigami.ApplicationWindow` with fixed initial dimensions and title.
- Stores a reference to the active canvas page for cross-component coordination.
- Initializes the `pageStack` with `PainterCanvasPage` and exposes the page instance via the `pageReady` signal.

### `PainterCanvasPage.qml`

- Extends `Kirigami.Page` to host the main drawing surface.
- Maintains the user-facing state (`brushColor`, `brushSize`, `toolMode`, and color `palette`).
- Emits `pageReady` when the component loads to let `Main.qml` grab a pointer.
- Provides imperative helpers (`newCanvas`, `clearCanvas`, `saveCanvasAs`, `openImage`, `adjustBrush`) that wrap the lower-level `DrawingSurface` API.
- Instantiates the `CanvasToolBar` as the page header and wires its signals back into the page state.
- Hosts the `DrawingSurface` inside a `Rectangle`, forwarding brush parameters and listening for scroll-wheel-driven size changes.
- Includes a floating Kirigami menu button that opens the global drawer when available.

### `CanvasToolBar.qml`

- Implements a hybrid toolbar/global drawer using Qt Quick Controls and Kirigami.
- Exposes signals for high-level actions (new, open, save, clear) and tool adjustments (brush size, tool selection, palette picks).
- Provides `Dialogs.FileDialog` instances for open/save flows, including extension inference when a filename lacks a suffix.
- Presents quick-access buttons, tool toggles, a size slider with increment/decrement buttons, and a color palette repeater that highlights the active swatch.
- Exposes the `Kirigami.GlobalDrawer` via `globalDrawer` for external visibility toggling.

### `DrawingSurface.qml`

- Renders the actual canvas within a rounded `Rectangle`.
- Manages drawing state (`strokes`, `currentStroke`, `backgroundSource`) and tool behavior.
- Uses a `Canvas` element to batch-render all strokes; each stroke contains point arrays, colors, and widths.
- Supports eraser mode by substituting white strokes, wheel-based brush size adjustments via the `brushDeltaRequested` signal, and optional background image loading.
- Normalizes file URLs for loading and saving, ensuring compatibility with both `file://` URIs and bare paths.

## Data Flow & Interaction Summary

1. The C++ entry point loads `PainterForUNIX.Main` and hands off control to QML.
2. `Main.qml` instantiates `PainterCanvasPage`, which centralizes application state and owns the drawing surface.
3. `CanvasToolBar` surfaces user actions. Signals propagate up to `PainterCanvasPage` methods, which then mutate page state or invoke `DrawingSurface` methods.
4. `DrawingSurface` tracks strokes and encodes them into the Qt Quick `Canvas`. Brush parameters flow from the page to the surface, ensuring interactive updates.
5. File dialog selections bubble from `CanvasToolBar` to `PainterCanvasPage`, which forwards them to `DrawingSurface` for persistence or background loading.

## Notable Platform Considerations

- Craft integration: both CMake and `main.cpp` account for Craft-managed prefixes so that packaged QML plugins resolve without manual configuration.
- macOS OpenGL: The CMake logic conditionally adds shim targets and explicit frameworks to satisfy Qt Quick's OpenGL requirements on modern SDKs.

## Opportunities for Extension

- Introduce C++ back-end helpers (e.g., document models, command stacks) if the painting logic outgrows the QML-only approach.
- Add automated tests under `tests/` once non-trivial logic (such as file handling) gains more edge cases.
- Expand documentation with user-facing guides (tool descriptions, keyboard shortcuts) alongside this structural overview.

