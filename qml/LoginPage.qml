import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import "."

Page {
    background: Item {}
    
    readonly property int lineEditWidth: 300
    
    Image {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 80
        source: "qrc:/res/loginBg.png"
    }
    
    Item {
        width: col.width
        height: col.height
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: parent.width * 0.15
        }

        Column {
            id: col
            spacing: 48

            // default
            LineInput {
                id: usernameInputer
                width: lineEditWidth
                backgroundColor: "#242636"
                placeholderText: "Username"
                Material.accent: uiconfig.colorEmerald
                errorText: "please input username"
            }

            // set value as Manager
            LineInput {
                id: passwordInputer
                width: lineEditWidth
                backgroundColor: "#242636"
                placeholderText: "Password"
                Material.accent: uiconfig.colorEmerald
                hasHelper: true
                isPassword: true
                helperColor: "gray"
                helperText: "input/set your password"
                errorText: "please input password"
            }

            Item {
                width: lineEditWidth
                height: 1
            }

            ComboBox {
                id: authorityCombo
                width: lineEditWidth
                height: passwordInputer.height
                font.family: uiconfig.fontFamily
                model: ["Administrator", "Reception", "Manager", "Customer"]
                popup.font: font
                
                Text {
                    anchors {
                        bottom: parent.top
                    }

                    text: "Select Authority"
                    color: "gray"
                    font: authorityCombo.font
                }
            }
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 50
                CusButton {
                    enabled: authorityCombo.currentIndex !== 3
                    text: "Sign up"
                    onClicked: {
                        if (!usernameInputer.value.length) {
                            usernameInputer.isError = true
                        }
                        if (!passwordInputer.value.length) {
                            passwordInputer.isError = true
                        }
                        
                        if (usernameInputer.isError || passwordInputer.isError)
                            return

                        backend.sendSignUpRequest(
                            usernameInputer.value, 
                            passwordInputer.value, 
                            authorityCombo.currentIndex
                        )
                    }
                }
                CusButton {
                    text: "Sign in"
                    onClicked: {
                        if (!usernameInputer.value.length) {
                            usernameInputer.isError = true
                        }
                        if (!passwordInputer.value.length) {
                            passwordInputer.isError = true
                        }
                        
                        if (usernameInputer.isError || passwordInputer.isError)
                            return
                        
                        backend.sendSignInRequest(
                            usernameInputer.value, 
                            passwordInputer.value, 
                            authorityCombo.currentIndex
                        )
                    }
                }
            }
        }
    }
    
    Connections {
        target: backend
        function onSigUserSignUp(status, msg) {
            handleResult(status, msg)
        }
        function onSigUserLogin(status, msg) {
            handleResult(status, msg)
        }
    }
    
    function handleResult(status, msg) {
        if (!status) {
            switch(authorityCombo.currentIndex) {
            case 0:
                mainStack.push(adminPage)
                break
            case 1:
                mainStack.push(receptionPage)
                break
            case 2:
                mainStack.push(managerPage)
                break
            case 3:
                console.debug(msg)
                mainStack.push(customerPage)
                mainStack.currentItem.roomNumber = Number(msg)
                break
            default:
                break
            }

        } else {
            mainToast.showPopup(msg, "OK")
        }
    }
}
