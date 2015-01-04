/*
    harbour-ync, Yamaha Network Controller
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page
    RemorsePopup { id: remorse }

    function powerStandby(text)
    {
        if (text === "Standby")
        {
            remorse.execute("Shutting down", function()
                {
                ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                                    "<Main_Zone><Power_Control><Power>Standby</Power></Power_Control></Main_Zone></YAMAHA_AV>")
                } )
        }
        else
        {
            ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                                "<Main_Zone><Power_Control><Power>On</Power></Power_Control></Main_Zone></YAMAHA_AV>")
        }
    }

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
                                              "name": "YNC",
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
                    source: ync.iconUrl
                    width: 120
                    height: 120
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("AboutDevice.qml"))
                    }
                    ProgressCircle
                    {
                        id: progressCircle
                        anchors.fill: parent
                        visible: deviceLabel.text === "Searching..."

                        Timer
                        {
                            interval: 32
                            repeat: true
                            onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
                            running: parent.visible
                        }

                    }
                }

                Label
                {
                    id: deviceLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: ync.deviceInfo["friendlyName"]
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge
                }

            }
            Label
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Volume " + ync.deviceStatus["Volume/Lvl/Val"]
            }

            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Volume up"
                onClicked: ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                    "<Main_Zone><Volume><Lvl><Val>Up</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>")

            }
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Volume down"
                onClicked: ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                    "<Main_Zone><Volume><Lvl><Val>Down</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>")
            }
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Toggle mute"
                onClicked: ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                    "<Main_Zone><Volume><Mute>On/Off</Mute></Volume></Main_Zone></YAMAHA_AV>")
            }
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: ync.deviceStatus["Power_Control/Power"] === "Standby" ? "On" : "Standby"
                onClicked: powerStandby(text)
            }

        }
    }

}


