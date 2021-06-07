import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    background: Item {}
    
    property bool inCheckoutRoutine: false
    
    LineInput {
        id: roomNumberInput
        width: formBG.width * 0.4
        anchors {
            left: formBG.left
            bottom: formBG.top
            bottomMargin: 20
        }
        helperColor: uiconfig.colorClouds
        backgroundColor: "transparent"
        placeholderText: "RoomNumber"
        hasHelper: true
        helperText: "please input target room number"
        validator: IntValidator {
            bottom: 0
            top: 9999
        }
    }
    
    Text {
        font.family: uiconfig.fontFamily
        font.pixelSize: 24
        color: uiconfig.colorClouds
        anchors.right: formBG.right
        anchors.bottom: formBG.top
        text: "Data Form"
        font.underline: true
    }
    
    CusButton {
        id: query
        implicitWidth: 120
        anchors {
            left: roomNumberInput.right
            verticalCenter: roomNumberInput.verticalCenter
            verticalCenterOffset: 10
            leftMargin: 20
        }
        text: "Query Form"
        onClicked: {
            inCheckoutRoutine = false
            backend.sendGetDetailRequest(roomNumberInput.value)
        }
    }
    
    CusButton {
        id: checkout
        implicitWidth: 120
        anchors {
            left: query.right
            verticalCenter: roomNumberInput.verticalCenter
            verticalCenterOffset: 10
            leftMargin: 20
        }
        text: "Checkout"
        onClicked: {
            inCheckoutRoutine = true
            backend.sendGetRoomBillRequest(roomNumberInput.value)
        }
    }
    
    Connections {
        target: backend
        function onSigGetRoomBill(fee) {
            mainToast.showPopup("客户需要支付: " + fee.toFixed(1) + "元", "确认以支付")
        }
    }
    
    Connections {
        target: mainToast
        function onClicked() {
            if (inCheckoutRoutine) {
                inCheckoutRoutine = false
                backend.sendUserCheckoutRequest(roomNumberInput.value)
            }
        }
    }
    
    Rectangle {
        id: formBG
        radius: 20
        width: parent.width * 0.4
        height: parent.height * 0.7
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: parent.width * 0.05
        }
        border.width: 4
        border.color: uiconfig.colorCarrot
        color: "#11FFFFFF"
        
        ScrollView {
            id: detailView
            clip: true
            anchors.fill: parent
            anchors.margins: 10
            TextArea {
                id: detailFiled
                width: parent.width
                enabled: false
                color: uiconfig.colorClouds
                font.pixelSize: 16
                background: Item {}
            }
        }
        
        
        
        Connections {
            target: backend
            function onSigGetRoomDetail(msg) {
                detailFiled.append(msg)
            }
        }
    }
    
    Text {
        font.family: uiconfig.fontFamily
        font.pixelSize: 24
        color: uiconfig.colorClouds
        anchors.right: registerBG.right
        anchors.bottom: registerBG.top
        text: "Customer Register Form"
        font.underline: true
    }
    
    Rectangle {
        id: registerBG
        radius: 20
        width: parent.width * 0.4
        height: parent.height * 0.7
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: parent.width * 0.05
        }
        border.width: 4
        border.color: uiconfig.colorGreenSea
        color: "transparent"
        
        LineInput {
            id: regRoomNumber
            width: formBG.width * 0.4
            anchors {
                left: parent.left
                leftMargin: 20
                top: parent.top
                topMargin: 30
            }
            helperColor: uiconfig.colorClouds
            backgroundColor: "transparent"
            placeholderText: "RoomNumber"
            hasHelper: true
            helperText: "please input target room number"
            validator: IntValidator {
                bottom: 0
                top: 9999
            }
        }
        
        LineInput {
            id: regUserName
            width: formBG.width * 0.4
            anchors {
                left: parent.left
                leftMargin: 20
                top: parent.top
                topMargin: 130
            }
            helperColor: uiconfig.colorClouds
            backgroundColor: "transparent"
            placeholderText: "UserName"
            hasHelper: true
            helperText: "please input customer's username"
        }
        
        LineInput {
            id: regPassword
            width: formBG.width * 0.4
            anchors {
                right: parent.right
                rightMargin: 20
                top: parent.top
                topMargin: 130
            }
            helperColor: uiconfig.colorClouds
            backgroundColor: "transparent"
            placeholderText: "Password"
            hasHelper: true
            helperText: "please input customer's password"
            
            onValueChanged: {
                if (confirmPassword.value !== regPassword.value) {
                    confirmPassword.state = "error"
                } else {
                    confirmPassword.state = "passive"
                }
            }
        }
        
        LineInput {
            id: confirmPassword
            width: formBG.width * 0.4
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 250
            }
            helperColor: uiconfig.colorClouds
            backgroundColor: "transparent"
            placeholderText: "Confirm Password"
            hasHelper: true
            helperText: "please confirm password"
            
            errorText: "password not equal!"
            
            onValueChanged: {
                if (confirmPassword.value !== regPassword.value) {
                    confirmPassword.state = "error"
                } else {
                    confirmPassword.state = "active"
                }
            }
        }
        
        CusButton {
            id: register
            implicitWidth: 180
            anchors {
                horizontalCenter: confirmPassword.horizontalCenter
                top: confirmPassword.bottom
                topMargin: 60
            }
            text: "Register Customer"
            onClicked: {
                var cancel = false
                if (!regUserName.length) {
                    cancel = true
                    regUserName.state = "error"
                }
                if (!regPassword.length) {
                    cancel = true
                    regPassword.state = "error"
                }
                if (!regRoomNumber.length) {
                    cancel = true
                    regRoomNumber.state = "error"
                } 
                if (confirmPassword.state === "error") {
                    cancel = true
                }
                if (cancel)
                    return
                
                inCheckoutRoutine = false
                backend.sendRegisterCustomerRequest(regRoomNumber.value, regUserName.value, regPassword.value)
            }
        }
    }
    
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
