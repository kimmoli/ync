/*
    harbour-ync, Yamaha Network Controller
*/

#include "ync.h"
#include <QXmlQuery>
#include <QXmlResultItems>

YNC::YNC(QObject *parent) :
    QObject(parent)
{
    emit versionChanged();

    m_deviceInfo = QVariantMap();
    m_deviceInfo.insert("friendlyName", "Not connected");

    m_baseUrl = QString();

    emit deviceInfoChanged();
}

YNC::~YNC()
{
}

QString YNC::readVersion()
{
    return APPVERSION;
}

void YNC::getDeviceInfo(QString url)
{
    QNetworkAccessManager * _mgr = new QNetworkAccessManager(this);

    QXmlQuery query;
    query.setNetworkAccessManager(_mgr);
    query.setFocus(QUrl(url));

    QString queryTemplate("declare default element namespace \"urn:schemas-upnp-org:device-1-0\"; /root/device/%1/string()");

    QStringList lookFor;
    lookFor << "friendlyName";
    lookFor << "manufacturer";
    lookFor << "manufacturerURL";
    lookFor << "modelName";
    lookFor << "modelDescription";
    lookFor << "serialNumber";

    m_deviceInfo.clear();

    foreach (const QString &looking, lookFor)
    {
        query.setQuery(queryTemplate.arg(looking));
        QString value;
        query.evaluateTo(&value);
        value = value.trimmed();
        m_deviceInfo.insert(looking, value);
    }

    qDebug() << m_deviceInfo;

    emit deviceInfoChanged();

    queryTemplate = "declare default element namespace \"urn:schemas-upnp-org:device-1-0\"; /root/device/iconList/icon/%1/string()";
    query.setQuery(queryTemplate.arg("url"));
    QStringList iconUrls;
    query.evaluateTo(&iconUrls);
    qDebug() << iconUrls;

    // just take last one
    m_iconUrl = QString("http://%1:%2%3").arg(QUrl(url).host()).arg(QUrl(url).port(80)).arg(iconUrls.last());
    qDebug() << m_iconUrl;

    emit iconUrlChanged();
}


/*
 * Called from QML to post command to YNC
 */
void YNC::postThis(QString data)
{
    QNetworkAccessManager * _mgr = new QNetworkAccessManager(this);
    connect(_mgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(postFinish(QNetworkReply*)));
    connect(_mgr, SIGNAL(finished(QNetworkReply*)), _mgr, SLOT(deleteLater()));

    QUrl url(m_baseUrl + "/YamahaRemoteControl/ctrl");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/xml");

    qDebug() << "posting..." << url << data;

    _mgr->post(request, data.toLatin1());
}

void YNC::postFinish(QNetworkReply *reply)
{
    qDebug() << "Finished";

    if(reply->error() == QNetworkReply::NoError)
    {
        QString strReply = (QString)reply->readAll();
        qDebug() << strReply;
    }
    else
    {
        qDebug() << "error:" << reply->errorString();
    }
}

void YNC::startDiscovery()
{
    m_networkObserver = new NetworkObserver(this);

    qDebug() << "starting search...";

    connect(m_networkObserver, SIGNAL(discovered(const QString&)), this, SLOT(deviceDiscovered(const QString&)));
    connect(m_networkObserver, SIGNAL(timeout()), this, SLOT(deviceDiscoveryTimeout()));
    connect(m_networkObserver, SIGNAL(timeout()), m_networkObserver, SLOT(deleteLater()));

    m_networkObserver->startSearch();
}

void YNC::deviceDiscovered(const QString &result)
{
    qDebug() << result;

    m_baseUrl = QString("http://%1").arg(QUrl(result).host());

    qDebug() << m_baseUrl;

    getDeviceInfo(result);
}

void YNC::deviceDiscoveryTimeout()
{
    qDebug() << "timeout";
}

