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
#include <QVariantList>
#include <QStringList>

#include "networkobserver.h"

class YNC : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())
    Q_PROPERTY(QVariantMap deviceInfo READ readDeviceInfo NOTIFY deviceInfoChanged())
    Q_PROPERTY(QVariantMap deviceStatus READ readDeviceStatus NOTIFY deviceStatusChanged())
    Q_PROPERTY(QVariantMap tunerStatus READ readTunerStatus NOTIFY tunerStatusChanged())
    Q_PROPERTY(QVariantList deviceInputs READ readDeviceInputs NOTIFY deviceInputsChanged())
    Q_PROPERTY(int currentInput READ readCurrentInput NOTIFY currentInputChanged())

public:
    explicit YNC(QObject *parent = 0);
    ~YNC();

    QString readVersion();
    QVariantMap readDeviceInfo() { return m_deviceInfo; }
    QVariantMap readDeviceStatus() { return m_deviceStatus; }
    QVariantMap readTunerStatus() { return m_tunerStatus; }
    QVariantList readDeviceInputs() { return m_deviceInputs; }
    int readCurrentInput() { return m_currentInput; }

    Q_INVOKABLE void postThis(QString data);

    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void getDeviceStatus();
    Q_INVOKABLE void getDeviceInputs();
    Q_INVOKABLE void getTunerStatus();

public slots:
    void postFinish(QNetworkReply *reply);
    void getDeviceStatusFinish(QNetworkReply *reply);
    void getDeviceInputsFinish(QNetworkReply *reply);
    void getTunerStatusFinish(QNetworkReply *reply);
    void deviceDiscovered(const QString &result);
    void deviceDiscoveryTimeout();

signals:
    void versionChanged();
    void deviceInfoChanged();
    void deviceStatusChanged();
    void tunerStatusChanged();
    void deviceInputsChanged();
    void currentInputChanged();

private:
    void getDeviceInfo(QString url);

    QVariantMap m_deviceInfo;
    QVariantMap m_deviceStatus;
    QVariantMap m_tunerStatus;
    QVariantList m_deviceInputs;

    NetworkObserver * m_networkObserver;

    QString m_baseUrl;
    QString m_iconUrl;
    int m_currentInput;

};


#endif // YNC_H

