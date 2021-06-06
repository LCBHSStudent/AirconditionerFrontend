import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.15

Page {
    background: Item {}
    
    property int roomNumber: 1001
    property real temperature: 0
    property string windLevel: "stop"
    property string mode: "cold"
    property double fee: 0.0
    property string powerOn: "off"
    property real roomTemperature: 0
    property real power: 0.0
    
    Dial {
        width: 400
        height: 400
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        Material.accent: Material.LightBlue
        
        from: 18
        to: 30
        
        value: temperature
        
        onPressedChanged: {
            if (!pressed) {
                backend.sendSetParamRequest(
                    roomNumber, 
                    mode,
                    windLevel, 
                    value, 
                    0
                )
            }
        }
        
        Text {
            anchors.centerIn: parent
            font.family: "UniDreamLED"
            font.pixelSize: 82
            color: "#81D4FA"
            text: parent.value.toFixed(1) + " 'C"
        }
    }
    
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: "Room  " + roomNumber
        font.family: "UniDreamLED"
        font.pixelSize: 64
        color: uiconfig.colorPeterRiver
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
    
    Timer {
        id: refreshTimer
        interval: 1000
        repeat: true
        running: roomNumber > 0
        onTriggered: {
            backend.sendUpdateRoomInfoRequest(roomNumber)
        }
    }
    
    onRoomNumberChanged: {
        if (roomNumber > 0) {
            backend.sendUpdateRoomInfoRequest(roomNumber)
        }
    }
    
    Image {
        anchors {
            right: parent.right
            top: parent.top
            margins: 20
        }

        width: 100
        height: sourceSize.height / sourceSize.width * width
        fillMode: Image.PreserveAspectFit
        source: "qrc:/res/power.png"
        layer.enabled: true
        layer.effect: ColorOverlay {
            color: powerOn === "on"? uiconfig.colorEmerald: uiconfig.colorAlizarin
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (powerOn === "off") {
                    backend.sendFlipPowerRequest(true, roomNumber)
                } else {
                    backend.sendFlipPowerRequest(false, roomNumber)
                }
            }
        }
    }
    
    Column {
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        
        Text {
            font: modeCombo.font
            color: uiconfig.colorClouds
            text: "Current mode"
        }
        
        ComboBox {
            id: modeCombo

            width: 150
            height: 40
            model: ["cold", "hot", "wind", "dry", "sleep"]
            
            Component.onCompleted: {
                for (var i = 0; i < 5; i++) {
                    if (mode === model[i]) {
                        currentIndex = i
                        break
                    }
                }
            }
            
            enabled: powerOn === "on"
            popup.onVisibleChanged: {
                if (popup.visible) {
                    refreshTimer.running = false
                    refreshTimer.stop()
                } else {
                    refreshTimer.running = true
                    refreshTimer.start()
                }   
            }
            onActivated: {
                backend.sendSetParamRequest(
                    roomNumber, 
                    model[index],
                    windLevel, 
                    temperature, 
                    0
                )
            }
        }
        
        Text {
            font: modeCombo.font
            color: uiconfig.colorClouds
            text: "Current wind level"
        }
        
        ComboBox {
            width: 150
            height: 40

            model: ["stop", "low", "mid", "high"]
            id: windLevelCombo
            
            Component.onCompleted: {
                for (var i = 0; i < 5; i++) {
                    if (windLevel === model[i]) {
                        currentIndex = i
                        break
                    }
                }
            }
            
            enabled: powerOn === "on"
            popup.onVisibleChanged: {
                if (popup.visible) {
                    refreshTimer.running = false
                    refreshTimer.stop()
                } else {
                    refreshTimer.running = true
                    refreshTimer.start()
                }   
            }
            onActivated: {
                backend.sendSetParamRequest(
                    roomNumber, 
                    mode, 
                    model[index], 
                    temperature, 
                    1
                )
            }
        }
    }
    
    Column {
        anchors.right: parent.right
        anchors.rightMargin: 300
        anchors.verticalCenter: parent.verticalCenter
        
        Text {
            font.family: "Microsoft YaHei"
            font.pixelSize: 82
            color: "#81D4FA"
            text: "Room Temp"
        }
        
        Text {
            font.family: "UniDreamLED"
            font.pixelSize: 82
            color: uiconfig.colorCarrot
            text: roomTemperature.toFixed(1) + " 'C"
        }
        
        Text {
            font.family: "UniDreamLED"
            font.pixelSize: 36
            color: uiconfig.colorEmerald
            text: "Fee:    " + fee + "￥"
        }
        
        Text {
            font.family: "UniDreamLED"
            font.pixelSize: 36
            color: uiconfig.colorEmerald
            text: "Power cost:    " + power + "￥"
        }
    }
    
    
    
    Connections {
        target: backend
        function onSigGetRoomData(data) {
            temperature = data["temperature"]
            roomTemperature = data["room_temperature"]
            powerOn = data["power"]
            mode = data["mode"]
            windLevel = data["wind_level"]
            power = data["total_power"]
        }
    }
}
