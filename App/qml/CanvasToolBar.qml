import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami 2.20 as Kirigami

Controls.ToolBar {
    id: toolbar

    property real brushSize: 4
    property color currentColor: "#1a1a1a"
    property var palette: []
    property var drawer: null
    property string currentTool: "brush"

    signal newCanvasRequested()
    signal clearCanvasRequested()
    signal brushSizeChangeRequested(real size)
    signal colorPicked(color swatchColor)
    signal toolSelected(string tool)

    contentItem: RowLayout {
        spacing: Kirigami.Units.mediumSpacing

        Controls.ToolButton {
            icon.name: "application-menu"
            display: Controls.AbstractButton.IconOnly
            Accessible.name: qsTr("Application menu")
            onClicked: {
                if (toolbar.drawer) {
                    toolbar.drawer.open()
                }
            }
        }

        Controls.ToolButton {
            text: qsTr("New")
            icon.name: "document-new"
            onClicked: toolbar.newCanvasRequested()
        }

        Controls.ToolButton {
            text: qsTr("Clear")
            icon.name: "edit-clear"
            onClicked: toolbar.clearCanvasRequested()
        }

        Kirigami.Separator {
            visible: true
            Layout.fillHeight: true
        }

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            Controls.ToolButton {
                icon.name: "draw-brush"
                checkable: true
                checked: toolbar.currentTool === "brush"
                display: Controls.AbstractButton.IconOnly
                Accessible.name: qsTr("Brush tool")
                onClicked: toolbar.toolSelected("brush")
            }

            Controls.ToolButton {
                icon.name: "draw-eraser"
                checkable: true
                checked: toolbar.currentTool === "eraser"
                display: Controls.AbstractButton.IconOnly
                Accessible.name: qsTr("Eraser tool")
                onClicked: toolbar.toolSelected("eraser")
            }
        }

        Kirigami.Separator {
            visible: true
            Layout.fillHeight: true
        }

        Controls.Label {
            text: qsTr("Brush")
            font.bold: true
        }

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            Controls.Slider {
                id: sizeSlider
                from: 1
                to: 48
                Layout.preferredWidth: 160
                value: toolbar.brushSize
                onMoved: toolbar.brushSizeChangeRequested(value)
                onValueChanged: {
                    if (pressed || activeFocus) {
                        toolbar.brushSizeChangeRequested(value)
                    }
                }
            }

            Controls.ToolButton {
                icon.name: "zoom-in"
                display: Controls.AbstractButton.IconOnly
                onClicked: toolbar.brushSizeChangeRequested(Math.min(48, toolbar.brushSize + 2))
                Accessible.name: qsTr("Increase brush size")
            }

            Controls.ToolButton {
                icon.name: "zoom-out"
                display: Controls.AbstractButton.IconOnly
                onClicked: toolbar.brushSizeChangeRequested(Math.max(1, toolbar.brushSize - 2))
                Accessible.name: qsTr("Decrease brush size")
            }
        }

        Controls.Label {
            text: qsTr("%1 px").arg(Math.round(toolbar.brushSize))
            width: 60
        }

        Repeater {
            model: toolbar.palette
            delegate: Rectangle {
                readonly property color swatchColor: modelData.color
                readonly property string swatchLabel: modelData.name ?? ""
                width: 28
                height: 28
                radius: 4
                color: swatchColor
                border.width: toolbar.currentColor === swatchColor ? 2 : 1
                border.color: toolbar.currentColor === swatchColor ? Kirigami.Theme.highlightColor : "#e0e0e0"

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 12
                    height: parent.height - 12
                    visible: swatchColor === "#ffffff"
                    color: "transparent"
                    border.color: "#b0b0b0"
                    border.width: 1
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toolbar.colorPicked(swatchColor)
                    Accessible.name: swatchLabel.length ? swatchLabel : qsTr("Brush color")
                }
            }
        }
    }
}
