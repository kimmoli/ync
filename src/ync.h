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
#include <QVariantMap>
#include <QStringList>

class YNC : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())
    Q_PROPERTY(QVariantMap deviceInfo READ readDeviceInfo NOTIFY deviceInfoChanged())

public:
    explicit YNC(QObject *parent = 0);
    ~YNC();

    QString readVersion();
    QVariantMap readDeviceInfo() { return m_deviceInfo; }

    Q_INVOKABLE void postThis(QString data);

public slots:
    void postFinish(QNetworkReply *reply);
    void getDeviceDescFinish(QNetworkReply *reply);

signals:
    void versionChanged();
    void deviceInfoChanged();

private:
    void getDeviceDescription();

    QNetworkAccessManager * m_mgr;
    QVariantMap m_deviceInfo;

};


#endif // YNC_H

