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
            MenuItem
            {
                text: powerOn ? "Standby" : "Power on"
                onClicked: powerStandby(text)
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
                    source: ync.deviceInfo["IconUrl"]
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
                        anchors.centerIn: parent
                        width: 64
                        height: 64
                        visible: deviceLabel.text === "Searching..."

                        Timer
                        {
                            interval: 25
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
                    opacity: powerOn ? 1.0 : 0.4
                    horizontalAlignment: Text.AlignHCenter
                }
                Column
                {
                    width: parent.width / 2
                    IconButton
                    {
                        enabled: powerOn
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
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
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
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

            Label
            {
                visible: false
                text: "Input: <b>" + ync.deviceStatus["Input/Input_Sel_Item_Info/Param"] + "</b>" + ync.currentInput
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                opacity: powerOn ? 1.0 : 0.4
                horizontalAlignment: Text.AlignHCenter
                /* WTF ! combobox does not see if currentIndex var changes, i need to trigger it here ?? */
                onTextChanged: inputSelector.currentIndex = ync.currentInput
            }


            ComboBox
            {
                id: inputSelector
                enabled: powerOn
                width: page.width
                label: "Input "
                description: "change input"
                currentIndex: ync.currentInput
                menu: ContextMenu {
                    Repeater {
                        model: ync.deviceInputs
                        MenuItem {
                            text: ync.deviceInputs[index]["inputTitle"] + "(" + ync.deviceInputs[index]["inputName"] + ")"
                            onClicked: ync.postThis("<?xml version=\"1.0\" encoding=\"utf-8\"?><YAMAHA_AV cmd=\"PUT\"><Main_Zone><Input><Input_Sel>" + ync.deviceInputs[index]["inputName"] + "</Input_Sel></Input></Main_Zone></YAMAHA_AV>")
                        }
                    }
                }
            }

            //  Seems these are not available from receiver (?)
            //            Image
            //            {
            //                source: ync.deviceInfo["BaseUrl"] + ync.deviceStatus["Input/Input_Sel_Item_Info/Icon/On"]
            //                onSourceChanged: console.log(source)
            //            }


        }
    }

}


