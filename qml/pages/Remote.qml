/*
    harbour-ync, Yamaha Network Controller
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page
    RemorsePopup { id: remorse }

    property string volUp   : "<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                              "<Main_Zone><Volume><Lvl><Val>Up</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>"
    property string volDown : "<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                              "<Main_Zone><Volume><Lvl><Val>Down</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>"
    property string volUpFast   : "<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                              "<Main_Zone><Volume><Lvl><Val>Up 1 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>"
    property string volDownFast : "<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                              "<Main_Zone><Volume><Lvl><Val>Down 1 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>"

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
            checkDeviceStatusTimer.start()
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

            Row
            {
                width: parent.width - Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                Label
                {
                    width: parent.width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    text: (ync.deviceStatus["Volume/Lvl/Val"]/10).toFixed(1) + " dB"
                    font.pixelSize: Theme.fontSizeExtraLarge
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Column
                {
                    width: parent.width / 2
                    IconButton
                    {
                        enabled: powerOn
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon.source: "image://theme/icon-m-up"
                        onClicked: ync.postThis(volUp)
                        onPressAndHold: volUpTimer.start()
                        onReleased: volUpTimer.stop()
                        Timer
                        {
                            id: volUpTimer
                            interval: 200
                            repeat: true
                            running: false
                            onTriggered: ync.postThis(volUpFast)
                        }

                    }
                    IconButton
                    {
                        enabled: powerOn
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon.source: "image://theme/icon-m-down"
                        onClicked: ync.postThis(volDown)
                        onPressAndHold: volDownTimer.start()
                        onReleased: volDownTimer.stop()
                        Timer
                        {
                            id: volDownTimer
                            interval: 200
                            repeat: true
                            running: false
                            onTriggered: ync.postThis(volDownFast)
                        }
                    }
                }
            }

            IconTextSwitch
            {
                text: "Mute"
                icon.source: "image://theme/icon-m-speaker-mute"
                automaticCheck: false
                width: parent.width - Theme.paddingLarge
                enabled: powerOn
                checked: ync.deviceStatus["Volume/Mute"] === "On"
                onClicked: ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                    "<Main_Zone><Volume><Mute>On/Off</Mute></Volume></Main_Zone></YAMAHA_AV>")
            }

            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: powerOn ? "Standby" : "On"
                onClicked: powerStandby(text)
            }

        }
    }

}


