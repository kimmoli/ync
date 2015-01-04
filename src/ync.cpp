/*
    harbour-ync, Yamaha Network Controller
*/

#include "ync.h"
#include <QXmlQuery>
#include <QXmlResultItems>
#include <QBuffer>

YNC::YNC(QObject *parent) :
    QObject(parent)
{
    emit versionChanged();

    m_deviceInfo = QVariantMap();
    m_deviceInfo.insert("friendlyName", "Searching...");

    m_baseUrl = QString();
    m_currentInput = -1;

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

    m_deviceInfo.insert("BaseUrl", m_baseUrl);

    foreach (const QString &looking, lookFor)
    {
        query.setQuery(queryTemplate.arg(looking));
        QString value;
        query.evaluateTo(&value);
        value = value.trimmed();
        m_deviceInfo.insert(looking, value);
    }

    queryTemplate = "declare default element namespace \"urn:schemas-upnp-org:device-1-0\"; /root/device/iconList/icon/%1/string()";
    query.setQuery(queryTemplate.arg("url"));
    QStringList iconUrls;
    query.evaluateTo(&iconUrls);

    // just take last one
    m_deviceInfo.insert("IconUrl", QString("http://%1:%2%3").arg(QUrl(url).host()).arg(QUrl(url).port(80)).arg(iconUrls.last()));

    emit deviceInfoChanged();

    getDeviceInputs();
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

//    qDebug() << "posting..." << url << data;

    _mgr->post(request, data.toLatin1());
}

void YNC::postFinish(QNetworkReply *reply)
{
    if(reply->error() == QNetworkReply::NoError)
    {
        QString strReply = (QString)reply->readAll();
//        qDebug() << strReply;
    }
    else
    {
        qDebug() << "error:" << reply->errorString();
    }

    getDeviceStatus();
}

void YNC::getDeviceStatus()
{
    if (m_baseUrl.isEmpty())
        return;

    QString data("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"GET\"><Main_Zone><Basic_Status>GetParam</Basic_Status></Main_Zone></YAMAHA_AV>");

    QNetworkAccessManager * _mgr = new QNetworkAccessManager(this);
    connect(_mgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(getDeviceStatusFinish(QNetworkReply*)));
    connect(_mgr, SIGNAL(finished(QNetworkReply*)), _mgr, SLOT(deleteLater()));

    QUrl url(m_baseUrl + "/YamahaRemoteControl/ctrl");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/xml");

    _mgr->post(request, data.toLatin1());
}

void YNC::getDeviceStatusFinish(QNetworkReply *reply)
{
    QString strReply;

    if(reply->error() == QNetworkReply::NoError)
    {
        strReply = (QString)reply->readAll();
    }
    else
    {
        qDebug() << "Network error:" << reply->errorString();
        return;
    }

    QBuffer device;
    device.setData(strReply.toUtf8());
    device.open(QIODevice::ReadOnly);

    QXmlQuery query;
    query.bindVariable("reply", &device);

    m_deviceStatus.clear();

    QStringList lookFor;
    lookFor << "Power_Control/Power";
    lookFor << "Volume/Lvl/Val";
    lookFor << "Volume/Mute";
    lookFor << "Input/Input_Sel_Item_Info/Title";
    lookFor << "Input/Input_Sel_Item_Info/Param";
    lookFor << "Input/Input_Sel_Item_Info/Icon/On";

    foreach (const QString looking, lookFor)
    {
        query.setQuery(QString("doc($reply)/YAMAHA_AV/Main_Zone/Basic_Status/%1/string()").arg(looking));
        QString tmp;
        query.evaluateTo(&tmp);

        m_deviceStatus.insert(looking, tmp.trimmed());
    }

    for (int i=0 ; i<m_deviceInputs.count() ; i++)
    {
        QVariantMap m = m_deviceInputs.at(i).toMap();

        if (m_deviceStatus.value("Input/Input_Sel_Item_Info/Param") == m.value("inputName").toString())
        {
            m_currentInput = i;
            emit currentInputChanged();
            break;
        }
    }


    emit deviceStatusChanged();
}

void YNC::getDeviceInputs()
{
    if (m_baseUrl.isEmpty())
        return;

    QString data("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"GET\"><Main_Zone><Input><Input_Sel_Item>GetParam</Input_Sel_Item></Input></Main_Zone></YAMAHA_AV>");

    QNetworkAccessManager * _mgr = new QNetworkAccessManager(this);
    connect(_mgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(getDeviceInputsFinish(QNetworkReply*)));
    connect(_mgr, SIGNAL(finished(QNetworkReply*)), _mgr, SLOT(deleteLater()));

    QUrl url(m_baseUrl + "/YamahaRemoteControl/ctrl");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/xml");

    _mgr->post(request, data.toLatin1());

}

void YNC::getDeviceInputsFinish(QNetworkReply *reply)
{
    QString strReply;
    QVariantList list;
    QVariantMap map;

    if(reply->error() == QNetworkReply::NoError)
    {
        strReply = (QString)reply->readAll();
    }
    else
    {
        qDebug() << "Network error:" << reply->errorString();
        return;
    }

    QBuffer device;
    device.setData(strReply.toUtf8());
    device.open(QIODevice::ReadOnly);

    QXmlQuery query;
    query.bindVariable("reply", &device);

    m_deviceInputs.clear();

    query.setQuery(QString("doc($reply)/YAMAHA_AV/Main_Zone/Input/Input_Sel_Item/*/Param/string()"));
    QStringList tmpParam;
    query.evaluateTo(&tmpParam);

    query.setQuery(QString("doc($reply)/YAMAHA_AV/Main_Zone/Input/Input_Sel_Item/*/Title/string()"));
    QStringList tmpTitle;
    query.evaluateTo(&tmpTitle);


    for (int i=0 ; i<tmpParam.count() ; i++)
    {
        map.clear();
        map.insert("inputName", tmpParam.at(i).trimmed());
        map.insert("inputTitle", tmpTitle.at(i).trimmed());
        list.append(map);
    }

    m_deviceInputs = list;


    emit deviceInputsChanged();

    getDeviceStatus();
}

void YNC::startDiscovery()
{
    m_networkObserver = new NetworkObserver(this);

    qDebug() << "starting discovery...";

    connect(m_networkObserver, SIGNAL(discovered(const QString&)), this, SLOT(deviceDiscovered(const QString&)));
    connect(m_networkObserver, SIGNAL(timeout()), this, SLOT(deviceDiscoveryTimeout()));
    connect(m_networkObserver, SIGNAL(timeout()), m_networkObserver, SLOT(deleteLater()));

    m_networkObserver->startSearch();
}

void YNC::deviceDiscovered(const QString &result)
{
    qDebug() << "found device, description:" << result;

    m_baseUrl = QString("http://%1").arg(QUrl(result).host());

    getDeviceInfo(result);
}

void YNC::deviceDiscoveryTimeout()
{
    qDebug() << "discovery timeout";

    if (m_deviceInfo.value("friendlyName") == "Searching...")
    {
        m_deviceInfo.clear();
        m_deviceInfo.insert("friendlyName", "Nothing found.");

        emit deviceInfoChanged();
    }
}

