import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import "."

ApplicationWindow {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "Terminal"
    
    color: "#242636"
    
    Material.theme: Material.Dark
    
    UIConfig { id: uiconfig }
    
    StackView {
        id: mainStack
        initialItem: loginPage
        anchors.fill: parent
    }
    
    Component {
        id: loginPage
        LoginPage {}
    }
    
    Component {
        id: adminPage
        AdminPage {}
    }
    
    Component {
        id: receptionPage
        ReceptionPage {}
    }
    
    Component {
        id: managerPage
        ManagerPage {}
    }
    
    Component {
        id: customerPage
        CustomerPage {}
    }
    
    OneBtnToast {
        contentW: 400
        contentH: 300
        id: mainToast
        
        Connections {
            target: backend
            function onSigShowPopup(msg, btn) {
                mainToast.showPopup(msg, btn)
            }
        }
    }
}
