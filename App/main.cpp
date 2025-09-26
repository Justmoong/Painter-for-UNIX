#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>

extern "C" void mac_unifyTitlebar(QWindow *qw);

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const auto craftRoot = QString::fromLocal8Bit(qgetenv("CRAFTROOT"));

    if (!craftRoot.isEmpty()) {
        const QStringList candidateImportPaths = {
            craftRoot + QStringLiteral("/qml"),
            craftRoot + QStringLiteral("/lib/qml")
        };
        for (const QString &importPath : candidateImportPaths) {
            if (QDir(importPath).exists()) {
                engine.addImportPath(importPath);
            }
        }
    }

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Vincent", "Main");

    return app.exec();
}
