/*
    harbour-ync, Yamaha Network Controller
*/

#ifndef YNC_H
#define YNC_H
#include <QObject>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QVariantMap>
#include <QStringList>

#include "networkobserver.h"

class YNC : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())
    Q_PROPERTY(QVariantMap deviceInfo READ readDeviceInfo NOTIFY deviceInfoChanged())
    Q_PROPERTY(QVariantMap deviceStatus READ readDeviceStatus NOTIFY deviceStatusChanged())
    Q_PROPERTY(QString iconUrl READ readIconUrl NOTIFY iconUrlChanged())

public:
    explicit YNC(QObject *parent = 0);
    ~YNC();

    QString readVersion();
    QVariantMap readDeviceInfo() { return m_deviceInfo; }
    QVariantMap readDeviceStatus() { return m_deviceStatus; }
    QString readIconUrl() { return m_iconUrl; }

    Q_INVOKABLE void postThis(QString data);

    Q_INVOKABLE void startDiscovery();

    Q_INVOKABLE void getDeviceStatus();

public slots:
    void postFinish(QNetworkReply *reply);
    void getDeviceStatusFinish(QNetworkReply *reply);
    void deviceDiscovered(const QString &result);
    void deviceDiscoveryTimeout();

signals:
    void versionChanged();
    void deviceInfoChanged();
    void deviceStatusChanged();
    void iconUrlChanged();

private:
    void getDeviceInfo(QString url);

    QVariantMap m_deviceInfo;
    QVariantMap m_deviceStatus;
    NetworkObserver * m_networkObserver;

    QString m_baseUrl;
    QString m_iconUrl;

};


#endif // YNC_H

