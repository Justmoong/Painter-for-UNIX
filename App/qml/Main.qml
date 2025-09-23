import QtQuick
import QtQuick.Dialogs
import org.kde.kirigami 2.20 as Kirigami
import "."

Kirigami.ApplicationWindow {
    id: window
    width: 960
    height: 640
    visible: true
    title: qsTr("Painter for UNIX")

    property var canvasPage: null

    pageStack.initialPage: PainterCanvasPage {
        id: painterPage
        onPageReady: window.canvasPage = painterPage
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save Canvas as JPEG")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("JPEG Image (*.jpg *.jpeg)")]
        defaultSuffix: "jpg"
        onAccepted: {
            if (window.canvasPage) {
                window.canvasPage.saveCanvasAs(selectedFile)
            }
        }
    }

    // globalDrawer: Kirigami.GlobalDrawer {
    //     title: qsTr("Painter for UNIX")
    //     titleIcon: "document-edit"
    //     actions: [
    //         Kirigami.Action {
    //             text: qsTr("New Canvas")
    //             icon.name: "document-new"
    //             onTriggered: if (window.canvasPage) window.canvasPage.newCanvas()
    //         },
    //         Kirigami.Action {
    //             text: qsTr("Clear Canvas")
    //             icon.name: "edit-clear"
    //             onTriggered: if (window.canvasPage) window.canvasPage.clearCanvas()
    //         },
    //         Kirigami.Action {
    //             text: qsTr("Save as JPEG")
    //             icon.name: "document-save"
    //             onTriggered: saveDialog.open()
    //         }
    //     ]
    // }
}
