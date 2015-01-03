/*
    harbour-ync, Yamaha Network Controller
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: "About..."
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"),
                                          { "version": ync.version,
                                              "year": "2014",
                                              "name": "Yamaha Network Controller",
                                              "imagelocation": "/usr/share/icons/hicolor/86x86/apps/harbour-ync.png"} )
            }
        }

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                title: "YNC"
            }
            Row
            {
                x: Theme.paddingLarge
                spacing: Theme.paddingLarge

                Image
                {
                    id: deviceLogo
                    anchors.verticalCenter: parent.verticalCenter
                    source: "http://192.168.10.53:8080/BCO_device_lrg_icon.png"
                }

                Label
                {
                    id: deviceLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: ync.deviceName
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Volume up"
                onClicked: ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                    "<Main_Zone><Volume><Lvl><Val>Up 1 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>")
            }
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Volume down"
                onClicked: ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                    "<Main_Zone><Volume><Lvl><Val>Down 1 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>")
            }
        }
    }

}


