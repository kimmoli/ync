/*
    harbour-ync, Yamaha Network Controller
*/


#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include "ync.h"


int main(int argc, char *argv[])
{
    qmlRegisterType<YNC>("harbour.ync.remote", 1, 0, "YNC");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/ync.qml"));
    view->show();

    return app->exec();
}

