import QtQuick
import org.kde.kirigami 2.20 as Kirigami
import "."

Kirigami.ApplicationWindow {
    id: window
    width: 960
    height: 640
    visible: true
    title: qsTr("Painter for UNIX")

    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None

    property var canvasPage: null

    pageStack.initialPage: PainterCanvasPage {
        id: painterPage
        onPageReady: window.canvasPage = painterPage
    }
}
