import QtQuick 2.11
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

TextField {
    id: field

    property string errorText: "Error!"

    property bool hasHelper: false

    readonly property string currentControlState: field.state

    property alias errorIconText: errorIcon

    property string helperText: ""

    property color helperColor: "green"

    property color errorColor: "red"

    property bool isNumber: false

    property bool isEmail: true

    property bool isPassword: false

    property alias textfield: field

    property string value: field.text

    property color passiveColor: "#bdbdbd"

    property bool isError: false

    selectByMouse: true
    width: implicitWidth
    height: 56
    clip: false
    echoMode: isPassword == true ? TextInput.Password : TextInput.Normal

    onIsErrorChanged: {
        if (isError)
            state = "error"
        else
            state = "active"
    }

    onEnabledChanged: {

        if (!enabled) {
            helperColor = passiveColor
            state = "passive"
        } else {
            state = ""
        }
    }
    inputMethodHints: {
        if (isNumber == true) {
            return Qt.ImhDialableCharactersOnly
        } else if (isEmail == true) {
            return Qt.ImhEmailCharactersOnly | Qt.ImhLowercaseOnly
        } else {
            return Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                    | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
        }
    }
    font.family: "Microsoft YaHei"
    placeholderText: "Label"
    onFocusChanged: {
        if (focus) {
            if (state == "passiveError")
                state = "error"
            else
                state = "active"
        } else {
            if (state == "error")
                state = "passiveError"
            else if (text.length) {
                state = "passive"
            } else {
                state = ""
            }
                
        }
    }

    Material.accent: Material.Purple
    bottomPadding: 0
    leftPadding: 14
    rightPadding: 14
    font.pixelSize: 18

    Rectangle {
        id: iconContainer
        width: height
        height: 12
        radius: width / 2
        scale: 0.85
        opacity: 0
        color: errorColor
        z: 2
        visible: false
        onOpacityChanged: {
            if (opacity > 0.1)
                visible = true
            else
                visible = false
        }

        x: parent.width - (width + field.rightPadding)
        y: parent.height / 2 - height / 2
        MouseArea {
            anchors.fill: parent
            onClicked: {
                field.clear()
                field.state = "active"
            }
        }
        Text {
            id: errorIcon

            anchors.centerIn: parent
            font.pixelSize: 18
            color: "#fff"
        }
    }

    onPlaceholderTextChanged: {
        var g = placeholderText
        placeholderText = ""
        pl.text = g
    }
    property color backgroundColor: "#f5f5f5"
    
    background: Item {
        anchors.fill: parent
        clip: true

        Rectangle {
            width: parent.width
            height: parent.height + radius
            color: backgroundColor
            radius: 6
            z: -1

            Item {
                id: placeHolderRec
                width: pl.implicitWidth
                height: pl.implicitHeight
                x: field.leftPadding
                y: field.height / 2 - height / 2

                Text {

                    property real size: 1
                    scale: size
                    id: pl
                    x: 0
                    text: "Label"
                    color: passiveColor
                    font.family: field.font.family
                    font.letterSpacing: 0.45
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: field.font.pixelSize
                    padding: 0
                }
            }
            Rectangle {
                id: bottomBorder
                width: parent.width
                height: 2

                color: pl.color
                y: parent.height - (height + parent.radius)
            }
        }
    }
    Item {
        id: errorRec
        width: parent.width
        height: field.hasHelper ? Math.max(16,
                                           mErrorText.implicitHeight) : 0

        opacity: field.hasHelper ? 1 : 0
        visible: true
        y: parent.height

        Text {
            id: mErrorText
            color: field.hasHelper ? helperColor : errorColor
            text: field.hasHelper ? helperText : errorText
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: field.leftPadding - 2
            maximumLineCount: 2
            padding: 4
            elide: Text.ElideRight
            font.pixelSize: 12
        }
    }

    states: [
        State {
            name: "active"
            PropertyChanges {
                target: placeHolderRec
                y: 4
            }

            PropertyChanges {
                target: field
                bottomPadding: -4
            }
            PropertyChanges {
                target: pl
                color: Material.accent

                padding: -2
                size: 0.7
                x: -(width / 6)
            }
        },

        State {
            name: "passive"
            PropertyChanges {
                target: placeHolderRec
                y: 4
            }
            PropertyChanges {
                target: field
                bottomPadding: -4
            }

            PropertyChanges {
                target: pl

                color: passiveColor

                size: 0.7
                padding: -2
                x: -(width / 6)
            }
        },
        State {

            name: "error"

            PropertyChanges {
                target: placeHolderRec
                y: 4
            }
            PropertyChanges {
                target: field
                bottomPadding: -4
            }
            PropertyChanges {
                target: pl
                color: errorColor
                padding: -2
                size: 0.7
                x: -(width / 6)
            }

            PropertyChanges {
                target: errorRec
                opacity: 1
                height: Math.max(16), mErrorText.implicitHeight
            }
            PropertyChanges {
                target: iconContainer
                opacity: 1
                color: errorColor
                scale: 1
            }
            PropertyChanges {
                target: errorIcon
                color: "black"
            }
            PropertyChanges {
                target: mErrorText
                color: errorColor
            }
        },
        State {

            name: "passiveError"

            PropertyChanges {
                target: pl
                color: passiveColor
            }
            PropertyChanges {
                target: pl
                color: passiveColor
                padding: -2
                size: 0.7
                x: -(width / 6)
            }

            PropertyChanges {
                target: errorRec
                opacity: 1
                height: Math.max(16), mErrorText.implicitHeight
            }
            PropertyChanges {
                target: placeHolderRec
                y: 4
            }
            PropertyChanges {
                target: iconContainer
                opacity: 1
                color: passiveColor
                scale: 1
            }
            PropertyChanges {
                target: mErrorText
                color: passiveColor
            }
            PropertyChanges {
                target: errorIcon
                color: "black"
            }
        }
    ]
    onStateChanged: {

        if (state == "active") {
            smoother.easing.type = Easing.OutExpo
        } else {
            smoother.easing.type = Easing.InExpo
        }
    }
    transitions: [
        Transition {
            from: ""
            to: "active"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    id: smoother
                    properties: "y,x,size,scale,padding,opacity,color,bottomPadding,"
                    duration: 300
                    easing.type: Easing.OutExpo
                }
                ColorAnimation {
                    duration: 100
                }
            }
        },
        Transition {
            from: "active"
            to: "passive"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y,x,size,opacity,color,bottomPadding"
                    duration: 300
                    easing.type: Easing.OutExpo
                }
                ColorAnimation {
                    duration: 100
                }
            }
        },
        Transition {
            from: "active"
            to: "error"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    id: smoother2
                    duration: 250
                    easing.type: Easing.OutExpo
                    properties: "x,y,height,opacity,scale"
                }
                ColorAnimation {
                    id: cSmoother2
                    duration: 250
                    easing.type: Easing.OutExpo
                }
            }
        },
        Transition {
            from: "passive"
            to: "error"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    id: smoother3
                    duration: 250
                    easing.type: Easing.OutExpo
                    properties: "x,y,height,opacity,scale"
                }
                ColorAnimation {
                    id: cSmoother3
                    duration: 250
                    easing.type: Easing.OutExpo
                }
            }
        },
        Transition {
            from: "active"
            to: "passiveError"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    id: smoother4
                    duration: 250
                    easing.type: Easing.OutExpo
                    properties: "x,y,height,opacity,scale"
                }
                ColorAnimation {
                    id: cSmoother4
                    duration: 250
                    easing.type: Easing.OutExpo
                }
            }
        },
        Transition {
            from: "error"
            to: "passive"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    id: smoother5
                    duration: 250
                    easing.type: Easing.OutExpo
                    properties: "x,y,height,opacity,scale"
                }
                ColorAnimation {
                    id: cSmoother5
                    duration: 250
                    easing.type: Easing.OutExpo
                }
            }
        }
    ]
}
