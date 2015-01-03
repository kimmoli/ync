/*
    harbour-ync, Yamaha Network Controller
*/

#include "ync.h"

YNC::YNC(QObject *parent) :
    QObject(parent)
{
    emit versionChanged();

    m_deviceName = QString("Not connected.");
    emit deviceNameChanged();

    getDeviceDescription();
}

YNC::~YNC()
{
    delete m_mgr;
}

QString YNC::readVersion()
{
    return APPVERSION;
}

void YNC::getDeviceDescription()
{
    m_mgr = new QNetworkAccessManager(this);
    connect(m_mgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(getDeviceDescFinish(QNetworkReply*)));
    connect(m_mgr, SIGNAL(finished(QNetworkReply*)), m_mgr, SLOT(deleteLater()));

    m_mgr->get(QNetworkRequest(QUrl("http://192.168.10.53:8080/MediaRenderer/desc.xml")));

    qDebug() << "Fetching device description";
}

void YNC::getDeviceDescFinish(QNetworkReply *reply)
{
    qDebug() << "Finished";

    if(reply->error() == QNetworkReply::NoError)
    {
        QString strReply = (QString)reply->readAll();
//        qDebug() << strReply;

        QXmlStreamReader xml(strReply);
        while(!xml.atEnd() && !xml.hasError())
        {
            QXmlStreamReader::TokenType token = xml.readNext();

            if(token == QXmlStreamReader::StartDocument)
                continue;

            if(token == QXmlStreamReader::StartElement)
            {
//                if(xml.name() == "device")
//                    continue;

                qDebug() << xml.name();

                if(xml.name() == "friendlyName")
                {
                    xml.readNext();
                    if(xml.tokenType() != QXmlStreamReader::Characters)
                    {
                        qDebug() << "no characters?";
                        continue;
                    }

                    qDebug() << "friendlyName" << xml.text().toString();
                    m_deviceName = xml.text().toString();
                    emit deviceNameChanged();
                }
            }
        }

        if(xml.hasError())
        {
            qDebug() << "XML error:" << xml.errorString();
        }

        qDebug() << "Finished parsing XML";

        xml.clear();
    }
    else
    {
        qDebug() << "Network error:" << reply->errorString();
    }

}


/*
 * Called from QML to post command to YNC
 */
void YNC::postThis(QString data)
{
    m_mgr = new QNetworkAccessManager(this);
    connect(m_mgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(postFinish(QNetworkReply*)));
    connect(m_mgr, SIGNAL(finished(QNetworkReply*)), m_mgr, SLOT(deleteLater()));

    QUrl url("http://192.168.10.53/YamahaRemoteControl/ctrl");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/xml");

    qDebug() << "posting..." << url << data;

    m_mgr->post(request, data.toLatin1());
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


