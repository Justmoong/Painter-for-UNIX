import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Dialogs as Dialogs
import QtQuick.Layouts
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg as KSvg


Controls.ToolBar {
    id: toolbar

    property real brushSize: 2
    property color currentColor: "#1a1a1a"
    property var palette: []
    property string currentTool: "brush"

    signal newCanvasRequested()
    signal clearCanvasRequested()
    signal openRequested(string fileUrl)
    signal saveRequested(string fileUrl)
    signal brushSizeChangeRequested(real size)
    signal colorPicked(color swatchColor)
    signal toolSelected(string tool)

    function openFileDialog() { openDialog.open() }
    function openSaveDialog() { saveDialog.open() }

    Dialogs.FileDialog {
        id: openDialog
        title: qsTr("Open Image")
        fileMode: Dialogs.FileDialog.OpenFile
        nameFilters: [qsTr("Images (*.png *.jpg *.jpeg *.bmp *.gif)")]
        onAccepted: {
            const selected = openDialog.selectedFile || openDialog.fileUrl
            const urlString = selected ? selected.toString() : ""
            if (urlString.length) {
                toolbar.openRequested(urlString)
            }
        }
    }

    Dialogs.FileDialog {
        id: saveDialog
        title: qsTr("Save Image As")
        fileMode: Dialogs.FileDialog.SaveFile
        nameFilters: [
            qsTr("PNG Image (*.png)"),
            qsTr("JPEG Image (*.jpg *.jpeg)"),
            qsTr("Bitmap Image (*.bmp)")
        ]
        onAccepted: {
            const selected = saveDialog.selectedFile || saveDialog.fileUrl
            var urlString = selected ? selected.toString() : ""
            if (!urlString.length) {
                return
            }

            if (!urlString.includes('.')) {
                if (urlString.endsWith('/')) {
                    urlString += 'canvas'
                }
                const suffix = saveDialog.selectedNameFilter.toLowerCase()
                if (suffix.indexOf('jpeg') !== -1 || suffix.indexOf('jpg') !== -1) {
                    urlString += '.jpg'
                } else if (suffix.indexOf('bmp') !== -1) {
                    urlString += '.bmp'
                } else {
                    urlString += '.png'
                }
            }

            toolbar.saveRequested(urlString)
        }
    }

    contentItem: RowLayout {
        spacing: Kirigami.Units.mediumSpacing

        Controls.ToolButton {
            id: newButton
            readonly property int actionIconSize: Kirigami.Units.iconSizes.smallMedium

            text: qsTr("New")
            Accessible.name: text
            onClicked: toolbar.newCanvasRequested()

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                KSvg.SvgItem {
                    implicitWidth: newButton.actionIconSize
                    implicitHeight: newButton.actionIconSize
                    imagePath: "qrc:/../resources/icons/new.svg"
                }

                Controls.Label {
                    text: newButton.text
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Controls.ToolButton {
            id: openButton
            readonly property int actionIconSize: Kirigami.Units.iconSizes.smallMedium

            text: qsTr("Open")
            Accessible.name: text
            onClicked: toolbar.openFileDialog()

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                KSvg.SvgItem {
                    implicitWidth: openButton.actionIconSize
                    implicitHeight: openButton.actionIconSize
                    imagePath: "qrc:/../resources/icons/open.svg"
                }

                Controls.Label {
                    text: openButton.text
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Controls.ToolButton {
            id: saveButton
            readonly property int actionIconSize: Kirigami.Units.iconSizes.smallMedium

            text: qsTr("Save")
            Accessible.name: text
            onClicked: toolbar.openSaveDialog()

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                KSvg.SvgItem {
                    implicitWidth: saveButton.actionIconSize
                    implicitHeight: saveButton.actionIconSize
                    imagePath: "qrc:/../resources/icons/save.svg"
                }

                Controls.Label {
                    text: saveButton.text
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Controls.ToolButton {
            id: clearButton
            readonly property int actionIconSize: Kirigami.Units.iconSizes.smallMedium

            text: qsTr("Clear")
            Accessible.name: text
            onClicked: toolbar.clearCanvasRequested()

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                KSvg.SvgItem {
                    implicitWidth: clearButton.actionIconSize
                    implicitHeight: clearButton.actionIconSize
                    imagePath: "qrc:/../resources/icons/clear.svg"
                }

                Controls.Label {
                    text: clearButton.text
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Kirigami.Separator {
            visible: true
            Layout.fillHeight: true
        }

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            Controls.ToolButton {
                readonly property int toolIconSize: Kirigami.Units.iconSizes.smallMedium

                checkable: true
                checked: toolbar.currentTool === "brush"
                display: Controls.AbstractButton.IconOnly
                Accessible.name: qsTr("Brush tool")
                onClicked: toolbar.toolSelected("brush")

                contentItem: KSvg.SvgItem {
                    implicitWidth: parent.toolIconSize
                    implicitHeight: parent.toolIconSize
                    imagePath: "qrc:/../resources/icons/brush.svg"
                }
            }

            Controls.ToolButton {
                readonly property int toolIconSize: Kirigami.Units.iconSizes.smallMedium

                checkable: true
                checked: toolbar.currentTool === "eraser"
                display: Controls.AbstractButton.IconOnly
                Accessible.name: qsTr("Eraser tool")
                onClicked: toolbar.toolSelected("eraser")

                contentItem: KSvg.SvgItem {
                    implicitWidth: parent.toolIconSize
                    implicitHeight: parent.toolIconSize
                    imagePath: "qrc:/../resources/icons/eraser.svg"
                }
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
                onClicked: toolbar.brushSizeChangeRequested(Math.min(48, toolbar.brushSize + 1))
                Accessible.name: qsTr("Increase brush size")
            }

            Controls.ToolButton {
                icon.name: "zoom-out"
                display: Controls.AbstractButton.IconOnly
                onClicked: toolbar.brushSizeChangeRequested(Math.max(1, toolbar.brushSize - 1))
                Accessible.name: qsTr("Decrease brush size")
            }
        }

        Controls.Label {
            text: qsTr("%1 px").arg(Math.round(toolbar.brushSize))
            width: 120
        }

        Item { Layout.fillWidth: true } //For Fixed Layout

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
