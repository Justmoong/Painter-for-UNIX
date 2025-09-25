import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami 2.20 as Kirigami
import "."

Kirigami.ApplicationWindow {
    id: window
    width: 1080
    height: 720
    visible: true
    title: qsTr("Vincent")

    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None

    property var canvasPage: null

    header: Controls.ToolBar
    {
        id: mainToolBar
        contentHeight: implicitHeight

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
            border.width: 0
        }
    }

    pageStack.initialPage: PainterCanvasPage {
        id: painterPage
        onPageReady: window.canvasPage = painterPage
    }
}
