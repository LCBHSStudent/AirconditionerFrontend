#include <QtQml>
#include <QtQuickControls2/QQuickStyle>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "quickeventeater.hpp"
#include "clientbackend/clientbackend.h"

#ifdef DEBUG_BUILD
    static const QUrl entranceQml(QStringLiteral("file:///A:/WorkSpace/QTProjects/AirconditionerFrontend/qml/main.qml"));
#else 
    static const QUrl entranceQml(QStringLiteral("qrc:/qml/main.qml"));
#endif

int main(int argc, char *argv[]) {
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");
    
    // qmlRegisterType<ClientBackend>("Backend.Controls", 1, 0, "Backend");
    std::unique_ptr<ClientBackend> backend(std::make_unique<ClientBackend>(&app));
    
    QQmlApplicationEngine engine;
    
    engine.rootContext()->setContextProperty("backend", backend.get());
    QObject::connect(
        &engine,    &QQmlApplicationEngine::objectCreated,
        &app,       [](QObject *obj, const QUrl &objUrl) 
        {
            if (!obj && entranceQml == objUrl) {
                QCoreApplication::exit(-1);
            } 
        },
    Qt::QueuedConnection);
    
    auto eater = new QuickEventEater(&app);
    QObject::connect(eater, &QuickEventEater::reload, [&engine] {
        engine.clearComponentCache();
        
        auto&& objs = engine.rootObjects();
        objs.first()->deleteLater();
        engine.children().empty();
        
        engine.load(entranceQml);
    });
    
    engine.load(entranceQml);
    
    return app.exec();
}
