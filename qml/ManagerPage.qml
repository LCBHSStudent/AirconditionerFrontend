import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    background: Item {}
    
    CusButton {
        text: "Sign Out"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: parent.width * 0.01
        
        onClicked: {
            mainStack.pop()
        }
    }
}
