import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    background: Item {}
    
    Rectangle {
        id: roomViewBg
        anchors.fill: parent
        anchors.margins: parent.width * 0.05
        
        color: "#AA0F0F0F"
        radius: 12
        
        GridView {
            clip: true
            id: roomView
            anchors.fill: parent
            cellWidth: width / 4
            
            anchors.leftMargin: spacing
            anchors.rightMargin: spacing
            property int spacing: 4
                                
            delegate: Image {
                source: "qrc:/res/airconBg.png"
                width: roomView.cellWidth - roomView.spacing
                height: sourceSize.height / sourceSize.width * width
                fillMode: Image.PreserveAspectFit
                onHeightChanged: roomView.cellHeight = height + roomView.spacing
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        refreshTimer.running = false
                        refreshTimer.stop()
                        parent.opacity = 0.75
                    }
                    onExited: {
                        refreshTimer.running = true
                        refreshTimer.start()
                        parent.opacity = 1
                    }
                }
                
                Text {
                    id: targetTemp
                    anchors.bottom: curTemp.top
                    anchors.left: curTemp.left
                    color: uiconfig.colorClouds
                    font.pixelSize: 14
                    font.family: uiconfig.fontFamily
                    text: "target temperature: " + temperature + "°C"
                }
                
                Text {
                    id: curTemp
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        margins: 20
                    }
                    text: room_temperature + "°C"
                    color: uiconfig.colorClouds
                    font.pixelSize: 48
                    font.family: uiconfig.fontFamily
                }
                
                Text {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: 20
                        rightMargin: 5
                    }
                    text: room_num
                    color: uiconfig.colorClouds
                    font.pixelSize: 24
                    font.family: uiconfig.fontFamily
                }
                
                Behavior on opacity {
                    PropertyAnimation {
                        duration: 150
                    }
                }
                
                ComboBox {
                    id: modeCombo
                    anchors {
                        left: powerLabel.right
                        verticalCenter: powerLabel.verticalCenter
                        
                        leftMargin: 22
                    }
                    width: 100
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
                    
                    enabled: power === "on"
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
                            room_num, 
                            model[index],
                            wind_level, 
                            temperature, 
                            0
                        )
                    }
                }
                
                ComboBox {
                    width: 100
                    height: 40
                    anchors {
                        bottom: targetTemp.top
                        left: targetTemp.left
                    }
                    model: ["stop", "low", "mid", "high"]
                    id: windLevelCombo
                    
                    Component.onCompleted: {
                        for (var i = 0; i < 5; i++) {
                            if (wind_level === model[i]) {
                                currentIndex = i
                                break
                            }
                        }
                    }
                    
                    enabled: power === "on"
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
                        console.debug("coco")
                        backend.sendSetParamRequest(
                            room_num, 
                            mode, 
                            model[index], 
                            temperature, 
                            1
                        )
                    }
                }
                
                Rectangle {
                    id: powerLabel
                    anchors {
                        left: parent.left
                        top: parent.top
                        topMargin: 20
                        leftMargin: 22
                    }
                    width: 30
                    height: 30
                    radius: width / 2
                    color: {
                        if (power === "off")
                            return uiconfig.colorAlizarin
                        else if (power == "on")
                            return uiconfig.colorEmerald
                        else 
                            return uiconfig.colorConcrete
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (power === "off") {
                                backend.sendFlipPowerRequest(true, room_num)
                            } else {
                                backend.sendFlipPowerRequest(false, room_num)
                            }
                        }
                    }
                }
            }
            
            model: ListModel {
                id: roomDataModel
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
    
    
    Connections {
        target: backend
        function onSigGetAllRoomData(roomList) {
            updateRoomData(roomDataModel, roomList)
        }
    }
    
    function updateRoomData(roomDataModel, roomList) {
        roomDataModel.clear()
        for (var i = 0; i < roomList.length; i++) {
            roomDataModel.append({
                "temperature": roomList[i].temperature,
                "room_num": roomList[i].room_num,
                "power": roomList[i].power,
                "room_temperature": roomList[i].room_temperature,
                "mode": roomList[i].mode,
                "wind_level": roomList[i].wind_level,
            })
        }
    }    
    
    Component.onCompleted: backend.sendGetAllRoomInfoRequest()
    
    Timer {
        id: refreshTimer
        running: true
        repeat: true
        interval: 1000
        onTriggered: backend.sendGetAllRoomInfoRequest()
    }
}
