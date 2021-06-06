import QtQuick 2.14
import QtQuick.Controls 2.14

Popup {
    id: toast_t
    x: (root.width - contentW) / 2
    y: (root.height - contentH) / 2
    width: 0; height: 0
    margins: 0; padding: 0
    modal: true; focus: true
    visible: false
    opacity: visible? 1: 0
    
    signal clicked()
    
    Behavior on opacity {
        PropertyAnimation {
            duration: 150
        }
    }
    closePolicy: Popup.NoAutoClose
    
    property alias contentW: toastRect.width
    property alias contentH: toastRect.height
    
    property alias btnText:  text.text
    property alias contentText: content.text
   
    
    Rectangle {
        id: toastRect
        color: uiconfig.colorClouds
        radius: 5
        
        Text {
            id: content
            font.family: uiconfig.fontFamily
            width: parent.width * 0.9
            height: parent.height - btn.height * 1.1
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: 16
            color: "#111111"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        
        Rectangle {
            height: 1
            width: parent.width - 10
            color: "#DDDDDD"
            anchors {
                bottom: btn.top
                bottomMargin: btn.height * 0.2
                horizontalCenter: parent.horizontalCenter
            }
        }
        
        Rectangle {
            id: btn
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            height: text.contentHeight * 1.4
            width:  parent.width * 0.6
            radius: 8
            color: "#2CC486"
            border.width: 2
            border.color: "#34D0C6"
            
            Behavior on scale {
                PropertyAnimation {duration: 50}
            }
            Rectangle {
                id: mask
                color: "#FFFFFF"
                anchors.fill: parent
                opacity: btnArea.pressed? 0.3: 0
                radius: 8
                Behavior on opacity {
                    PropertyAnimation {duration: 50}
                }
            }
            
            Text {
                id: text
                font.family: uiconfig.fontFamily
                font.pixelSize: 16                
                anchors.centerIn: parent
                color: "#EEEEEE"                
            }
            MouseArea {
                id: btnArea
                anchors.fill: parent
                onClicked: {
                    toast_t.clicked()
                    toast_t.visible = false
                }
                onPressedChanged: {
                    btn.scale = pressed? 1.1: 1
                }
            }
        }
    }
    
    function showPopup(content, btn) {
        contentText = content
        btnText     = btn
        visible     = true
    }
}


