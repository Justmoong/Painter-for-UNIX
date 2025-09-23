import QtQuick

Rectangle {
    id: surface
    color: "white"
    radius: 6
    border.color: "#d0d0d0"
    border.width: 1

    property color brushColor: "#1a1a1a"
    property real brushSize: 6
    property var strokes: []
    property var currentStroke: null
    property string toolMode: "brush"

    signal brushDeltaRequested(int delta)

    function newCanvas() {
        strokes = []
        currentStroke = null
        paintCanvas.requestPaint()
    }

    function saveToFile(fileUrl) {
        if (!fileUrl) {
            return false
        }

        var target = fileUrl
        if (target.toString) {
            target = target.toString()
        }
        if (target.startsWith("file://")) {
            target = decodeURIComponent(target.substring(7))
            if (Qt.platform.os === "windows" && target.startsWith("/")) {
                target = target.substring(1)
            }
        }

        return paintCanvas.save(target, "jpeg")
    }

    Canvas {
        id: paintCanvas
        anchors.fill: parent
        renderTarget: Canvas.Image

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "#ffffff"
            ctx.fillRect(0, 0, width, height)
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            for (let i = 0; i < surface.strokes.length; ++i) {
                const stroke = surface.strokes[i]
                if (!stroke || stroke.points.length === 0) {
                    continue
                }

                if (stroke.points.length === 1) {
                    const point = stroke.points[0]
                    ctx.beginPath()
                    ctx.fillStyle = stroke.color
                    ctx.arc(point.x, point.y, stroke.size / 2, 0, Math.PI * 2)
                    ctx.fill()
                    continue
                }

                ctx.beginPath()
                ctx.strokeStyle = stroke.color
                ctx.lineWidth = stroke.size
                ctx.moveTo(stroke.points[0].x, stroke.points[0].y)
                for (let j = 1; j < stroke.points.length; ++j) {
                    ctx.lineTo(stroke.points[j].x, stroke.points[j].y)
                }
                ctx.stroke()
            }
        }
    }

    onStrokesChanged: paintCanvas.requestPaint()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.CrossCursor

        onPressed: function(mouse) {
            var colorValue
            if (surface.toolMode === "eraser") {
                colorValue = "#ffffff"
            } else {
                colorValue = typeof surface.brushColor === "string"
                        ? surface.brushColor
                        : surface.brushColor.toString()
            }
            surface.currentStroke = {
                color: colorValue,
                size: surface.brushSize,
                points: [ { x: mouse.x, y: mouse.y } ]
            }
            const updated = surface.strokes.slice()
            updated.push(surface.currentStroke)
            surface.strokes = updated
            paintCanvas.requestPaint()
        }

        onPositionChanged: function(mouse) {
            if (!surface.currentStroke) {
                return
            }
            surface.currentStroke.points.push({ x: mouse.x, y: mouse.y })
            paintCanvas.requestPaint()
        }

        onReleased: function(mouse) {
            if (!surface.currentStroke) {
                return
            }
            surface.currentStroke.points.push({ x: mouse.x, y: mouse.y })
            surface.currentStroke = null
            paintCanvas.requestPaint()
        }

        onCanceled: surface.currentStroke = null

        onWheel: function(wheel) {
            surface.brushDeltaRequested(wheel.angleDelta.y > 0 ? 1 : -1)
        }
    }
}
