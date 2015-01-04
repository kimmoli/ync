/*
    harbour-ync, Yamaha Network Controller
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    CoverPlaceholder
    {
        text: "Harbour-ync"
        icon.source: "/usr/share/icons/hicolor/86x86/apps/harbour-ync.png"
    }

    Column
    {
        anchors.centerIn: parent
        width: parent.width - Theme.paddingLarge
        height: parent.height - 3*Theme.paddingLarge

        Label
        {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: ync.deviceInputs[ync.currentInput]["inputTitle"] + "(" + ync.deviceInputs[ync.currentInput]["inputName"] + ")"
            font.bold: true
        }
        Label
        {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: ync.deviceStatus["Volume/Mute"] === "On" ? "Muted" : ((ync.deviceStatus["Volume/Lvl/Val"]/10).toFixed(1) + " dB")
            font.bold: true
        }
    }

    CoverActionList
    {
        CoverAction
        {
            iconSource: coverActionLeftIcon
            onTriggered: coverActionLeft()
        }

//        CoverAction
//        {
//            iconSource: coverActionRightIcon
//            onTriggered: coverActionRight()
//        }
    }
}


