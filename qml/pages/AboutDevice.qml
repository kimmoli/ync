/*
    YNC - About device
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


Page
{

    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width - Theme.paddingLarge
            x: Theme.paddingLarge
            spacing: Theme.paddingSmall
            PageHeader
            {
                title: "About " + ync.deviceInfo["friendlyName"]
            }

            SectionHeader
            {
                text: "Device"
            }
            Image
            {
                source: ync.iconUrl
            }

            Label
            {
                text: ync.deviceInfo["modelName"]
            }
            Label
            {
                text: ync.deviceInfo["modelDescription"]
            }
            Label
            {
                text: "Serial: " + ync.deviceInfo["serialNumber"]
            }

            SectionHeader
            {
                text: "Manufacturer"
            }
            Label
            {
                text: ync.deviceInfo["manufacturer"]
            }
            Label
            {
                text: ync.deviceInfo["manufacturerURL"]
            }
        }
    }
}
