import QtQuick

Rectangle {
    id: surface
    color: "white"
    radius: 6
    border.color: "#d0d0d0"
    border.width: 1

    property color brushColor: "#1a1a1a"
    property real brushSize: 2
    property var strokes: []
    property var currentStroke: null
    property string toolMode: "brush"
    property string backgroundSource: ""

    signal brushDeltaRequested(int delta)

    function newCanvas() {
        strokes = []
        currentStroke = null
        backgroundSource = ""
        backgroundDisplay.source = ""
        paintCanvas.requestPaint()
    }

    function loadImage(fileUrl) {
        var sourceUrl = normalizeUrl(fileUrl)
        if (!sourceUrl) {
            return
        }
        backgroundSource = sourceUrl
        backgroundDisplay.source = sourceUrl
        currentStroke = null
        strokes = []
        paintCanvas.loadImage(sourceUrl)
        paintCanvas.requestPaint()
    }

    function saveToFile(fileUrl) {
        var path = toLocalPath(fileUrl)
        if (!path) {
            return false
        }
        return paintCanvas.save(path)
    }

    Image {
        id: backgroundDisplay
        anchors.fill: parent
        source: surface.backgroundSource
        fillMode: Image.Stretch
        visible: source.length > 0
        onStatusChanged: {
            if (status === Image.Ready && source.length > 0) {
                paintCanvas.loadImage(source)
                paintCanvas.requestPaint()
            }
        }
    }

    Canvas {
        id: paintCanvas
        anchors.fill: parent
        renderTarget: Canvas.Image

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "#ffffff"
            ctx.fillRect(0, 0, width, height)

            if (surface.backgroundSource && surface.backgroundSource.length) {
                ctx.drawImage(surface.backgroundSource, 0, 0, width, height)
            }

            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            for (var i = 0; i < surface.strokes.length; ++i) {
                var stroke = surface.strokes[i]
                if (!stroke || stroke.points.length === 0) {
                    continue
                }

                if (stroke.points.length === 1) {
                    var point = stroke.points[0]
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
                for (var j = 1; j < stroke.points.length; ++j) {
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
        cursorShape: surface.toolMode === "eraser" ? Qt.PointingHandCursor : Qt.CrossCursor

        onPressed: function(mouse) {
            var colorValue
            if (surface.toolMode === "eraser") {
                colorValue = "#ffffff"
            } else {
                colorValue = typeof surface.brushColor === "string" ? surface.brushColor : surface.brushColor.toString()
            }
            surface.currentStroke = {
                color: colorValue,
                size: surface.brushSize,
                points: [ { x: mouse.x, y: mouse.y } ]
            }
            var updated = surface.strokes.slice()
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

    function normalizeUrl(fileUrl) {
        if (!fileUrl) {
            return ""
        }
        var url = fileUrl.toString()
        if (url.startsWith("file://")) {
            return url
        }
        if (url.indexOf("://") !== -1) {
            return url
        }
        if (url.startsWith("/")) {
            return "file://" + url
        }
        return Qt.resolvedUrl(url)
    }

    function toLocalPath(fileUrl) {
        if (!fileUrl) {
            return ""
        }
        var path = fileUrl.toString()
        if (path.startsWith("file://")) {
            path = decodeURIComponent(path.substring(7))
            if (Qt.platform.os === "windows" && path.startsWith("/")) {
                path = path.substring(1)
            }
            return path
        }
        if (path.indexOf("://") !== -1) {
            return ""
        }
        return path
    }
}
