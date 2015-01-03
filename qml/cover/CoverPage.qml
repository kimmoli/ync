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

    CoverActionList
    {
        CoverAction
        {
            iconSource: coverActionLeftIcon
            onTriggered: coverActionLeft()
        }

        CoverAction
        {
            iconSource: coverActionRightIcon
            onTriggered: coverActionRight()
        }
    }
}


