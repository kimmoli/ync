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
#include <QXmlStreamReader>

class YNC : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())
    Q_PROPERTY(QString deviceName READ readDeviceName NOTIFY deviceNameChanged())

public:
    explicit YNC(QObject *parent = 0);
    ~YNC();

    QString readVersion();
    QString readDeviceName() { return m_deviceName; }

    Q_INVOKABLE void postThis(QString data);

public slots:
    void postFinish(QNetworkReply *reply);
    void getDeviceDescFinish(QNetworkReply *reply);

signals:
    void versionChanged();
    void deviceNameChanged();

private:
    void getDeviceDescription();

    QNetworkAccessManager * m_mgr;
    QString m_deviceName;

};


#endif // YNC_H

