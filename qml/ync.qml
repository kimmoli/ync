/*
    harbour-ync, Yamaha Network Controller
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.ync.remote 1.0

ApplicationWindow
{
    id: appWin

    property string coverActionLeftIcon: "image://theme/icon-m-speaker-mute"
    property string coverActionRightIcon: "image://theme/icon-cover-play"

    property real volumeValue: -350
    property bool powerOn: false

    initialPage: Qt.resolvedUrl("pages/Remote.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    function coverActionLeft()
    {
        console.log("Left cover action")
        ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\">" +
                            "<Main_Zone><Volume><Mute>On/Off</Mute></Volume></Main_Zone></YAMAHA_AV>")
    }

    function coverActionRight()
    {
        console.log("Right cover action")
    }

    YNC
    {
        id: ync
        Component.onCompleted: ync.startDiscovery()
        onDeviceStatusChanged:
        {
            volumeValue = ync.deviceStatus["Volume/Lvl/Val"]
            powerOn = ync.deviceStatus["Power_Control/Power"] === "On"
        }
    }

    onPowerOnChanged:
    {
        if (powerOn)
            checkDeviceStatusTimer.stop()
    }

    Timer
    {
        id: checkDeviceStatusTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: ync.getDeviceStatus()
    }

}


