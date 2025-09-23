import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami 2.20 as Kirigami
import "."

Kirigami.Page {
    id: painterPage

    readonly property var defaultPalette: [
        { name: qsTr("Ink Black"), color: "#1a1a1a" },
        { name: qsTr("Signal Red"), color: "#e53935" },
        { name: qsTr("Amber"), color: "#fb8c00" },
        { name: qsTr("Sun Yellow"), color: "#fdd835" },
        { name: qsTr("Leaf Green"), color: "#43a047" },
        { name: qsTr("Sky Blue"), color: "#1e88e5" },
        { name: qsTr("Violet"), color: "#5e35b1" },
        { name: qsTr("Clay"), color: "#8d6e63" },
        { name: qsTr("Pure White"), color: "#ffffff" },
        { name: qsTr("Pitch Black"), color: "#000000" }
    ]

    property color brushColor: defaultPalette[0].color
    property real brushSize: 6
    property var palette: defaultPalette
    property string toolMode: "brush"

    signal pageReady()

    Component.onCompleted: pageReady()

    function newCanvas() {
        drawingSurface.newCanvas()
    }

    function clearCanvas() {
        drawingSurface.newCanvas()
    }

    function setBrushColor(colorValue) {
        brushColor = colorValue
    }

    function adjustBrush(delta) {
        brushSize = Math.max(1, Math.min(48, brushSize + delta))
    }

    function saveCanvasAs(fileUrl) {
        drawingSurface.saveToFile(fileUrl)
    }

    function openImage(fileUrl) {
        drawingSurface.loadImage(fileUrl)
    }

    header: CanvasToolBar {
        id: canvasToolBar
        brushSize: painterPage.brushSize
        currentColor: painterPage.brushColor
        currentTool: painterPage.toolMode
        palette: painterPage.palette
        onNewCanvasRequested: painterPage.newCanvas()
        onClearCanvasRequested: painterPage.clearCanvas()
        onBrushSizeChangeRequested: function(size) {
            painterPage.brushSize = size
        }
        onColorPicked: function(swatchColor) {
            painterPage.setBrushColor(swatchColor)
        }
        onToolSelected: function(tool) {
            painterPage.toolMode = tool
        }
        onSaveRequested: function(fileUrl) {
            painterPage.saveCanvasAs(fileUrl)
        }
        onOpenRequested: function(fileUrl) {
            painterPage.openImage(fileUrl)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor

            DrawingSurface {
                id: drawingSurface
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                brushColor: painterPage.brushColor
                brushSize: painterPage.brushSize
                toolMode: painterPage.toolMode
                onBrushDeltaRequested: painterPage.adjustBrush(delta)
            }
        }
    }

    Controls.ToolButton {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Kirigami.Units.largeSpacing
        icon.name: "application-menu"
        display: Controls.AbstractButton.IconOnly
        visible: canvasToolBar.globalDrawer !== null
        Accessible.name: qsTr("Open menu")
        onClicked: if (canvasToolBar.globalDrawer) canvasToolBar.globalDrawer.open()
    }
}
