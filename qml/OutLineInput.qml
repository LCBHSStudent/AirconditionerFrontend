import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

TextField {
    id: field

    property color passiveColor: "#bdbdbd"

    property color errorColor: "red"

    property string errorText: "Error!"

    property bool isError: false

    property string helperText: ""

    property bool isNumber: false

    property color helperColor: "green"

    property alias errorIconText: errorIcon

    property bool hasHelper: false

    readonly property string currentControlState: field.state

    property bool isEmail: true

    property bool isPassword: false

    property string value: field.text

    property alias textfield: field

    width: dp(150)
    height: dp(56)
    echoMode: isPassword == true ? TextInput.Password : TextInput.Normal
    onTextEdited: {

        if (text.length > 0 && !isError)

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
    onValueChanged: {
        field.text = value
        if (value.length == 0) {

            field.state = ""
        } else {

            if (!isError)
                field.state = "active"
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

    onIsErrorChanged: {
        if (isError)
            state = "error"
        else
            state = "active"
    }

    onFocusChanged: {
        if (focus) {
            if (state == "passiveError")
                state = "error"
            else
                state = "active"
        } else {
            if (text.length > 0) {
                if (state == "error")
                    state = "passiveError"
                else
                    state = "passive"
            } else
                state = ""
        }
    }

    font.family: "arial"
    font.pixelSize: sp(18)
    placeholderText: ""
    onPlaceholderTextChanged: {

        var t = placeholderText
        placeholderText = ""
        placeholdertext.text = t
    }
    Rectangle {
        id: placeholderRec
        width: placeholdertext.implicitWidth
        height: placeholdertext.implicitHeight
        y: parent.height / 2 - height / 2
        x: parent.rightPadding
        color: "transparent"
        Rectangle {
            id: placeholderRecChild
            width: parent.width
            height: parent.height

            Text {
                id: placeholdertext
                maximumLineCount: 1
                font.letterSpacing: 0.15
                text: "Label"
                color: passiveColor
                font.pixelSize: field.font.pixelSize
                padding: dp(4)
            }
        }
    }
    background: Rectangle {
        id: bg
        width: parent.width
        height: dp(56)
        border.width: dp(2)
        border.color: passiveColor
        radius: dp(4)
        Rectangle {
            id: errorRec
            width: parent.width
            height: field.hasHelper ? Math.max(dp(16),
                                               mErrorText.implicitHeight) : 0
            opacity: field.hasHelper ? 1 : 0
            y: parent.height
            Text {
                id: mErrorText
                color: field.hasHelper ? helperColor : errorColor
                text: field.hasHelper ? helperText : errorText
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: field.leftPadding
                maximumLineCount: 2
                padding: dp(4)
                elide: Text.ElideRight
                font.pixelSize: sp(12)
            }
        }
    }
    leftPadding: dp(14)
    rightPadding: dp(14)
    topPadding: dp(16)
    bottomPadding: dp(16)

    Rectangle {
        id: iconContainer
        width: height
        height: dp(24)
        radius: width / 2
        scale: 0.85
        opacity: 0
        visible: false
        onOpacityChanged: {
            if (opacity > 0.1)
                visible = true
            else
                visible = false
        }
        x: parent.width - (width + parent.rightPadding)
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
            font.pixelSize: sp(18)
        }
    }
    onStateChanged: {

        if (state == "active") {
            smoother.easing.type = Easing.OutExpo
            cSmoother.easing.type = Easing.OutExpo
        } else if (state == "passive") {
            smoother1.easing.type = Easing.OutExpo
            cSmoother1.easing.type = Easing.OutExpo
        } else if (state == "error") {
            smoother2.easing.type = Easing.OutExpo
            cSmoother2.easing.type = Easing.OutExpo
            smoother3.easing.type = Easing.OutExpo
            cSmoother3.easing.type = Easing.OutExpo
        } else {
            smoother.easing.type = Easing.InExpo
            cSmoother.easing.type = Easing.InExpo
            smoother1.easing.type = Easing.InExpo
            cSmoother1.easing.type = Easing.InExpo
            smoother2.easing.type = Easing.InExpo
            cSmoother2.easing.type = Easing.InExpo
            smoother3.easing.type = Easing.InExpo
            cSmoother3.easing.type = Easing.InExpo
        }
    }
    states: [

        State {

            name: "active"
            PropertyChanges {
                target: bg
                border.color: Material.accent
            }
            PropertyChanges {
                target: placeholdertext
                color: Material.accent
                font.letterSpacing: sp(1)
            }
            PropertyChanges {
                target: placeholderRec
                y: -height / 2
            }
            PropertyChanges {
                target: placeholderRecChild
                x: -(width / 6)
                y: placeholderRec / 2 - placeholderRecChild / 2
                color: "#fff"

                scale: 0.75
            }
        },
        State {

            name: "passive"
            PropertyChanges {
                target: bg
                border.color: passiveColor
            }
            PropertyChanges {
                target: placeholdertext
                color: passiveColor
                font.letterSpacing: sp(1)
            }

            PropertyChanges {
                target: placeholderRec

                y: -height / 2
            }
            PropertyChanges {
                target: placeholderRecChild
                x: -(width / 6)
                y: placeholderRec / 2 - placeholderRecChild / 2
                color: "#fff"

                scale: 0.75
            }
        },
        State {

            name: "error"
            PropertyChanges {
                target: mErrorText
                color: errorColor
            }
            PropertyChanges {
                target: bg
                border.color: errorColor
            }
            PropertyChanges {
                target: placeholdertext
                color: errorColor
                font.letterSpacing: sp(1)
            }

            PropertyChanges {
                target: placeholderRec

                y: -height / 2
            }
            PropertyChanges {
                target: placeholderRecChild
                x: -(width / 6)
                y: placeholderRec / 2 - placeholderRecChild / 2
                color: "#fff"

                scale: 0.75
            }
            PropertyChanges {
                target: errorRec
                opacity: 1
                height: Math.max(dp(16), mErrorText.implicitHeight)
            }
            PropertyChanges {
                target: iconContainer
                opacity: 1
                color: errorColor
                scale: 1
            }
            PropertyChanges {
                target: errorIcon
                color: "#fff"
            }
        },
        State {

            name: "passiveError"
            PropertyChanges {
                target: bg
                border.color: passiveColor
            }
            PropertyChanges {
                target: placeholdertext
                color: passiveColor
                font.letterSpacing: sp(1)
            }
            PropertyChanges {
                target: placeholderRec

                y: -height / 2
            }
            PropertyChanges {
                target: placeholderRecChild
                x: -(width / 6)
                y: placeholderRec / 2 - placeholderRecChild / 2
                color: "#fff"

                scale: 0.75
            }
            PropertyChanges {
                target: errorRec
                opacity: 1
                height: Math.max(dp(16), mErrorText.implicitHeight)
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
                color: "#fff"
            }
        }
    ]
    transitions: [
        Transition {
            from: ""
            to: "active"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    id: smoother
                    duration: 250
                    easing.type: Easing.OutExpo
                    properties: "x,y,scale,font.letterSpacing"
                }
                ColorAnimation {
                    id: cSmoother
                    duration: 250
                    easing.type: Easing.OutExpo
                }
            }
        },
        Transition {
            from: "active"
            to: "passive"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    id: smoother1
                    duration: 250
                    easing.type: Easing.OutExpo
                    properties: "x,y,scale,font.letterSpacing"
                }
                ColorAnimation {
                    id: cSmoother1
                    duration: 250
                    easing.type: Easing.OutExpo
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
                    properties: "x,y,height,opacity,scale,font.letterSpacing"
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
                    properties: "x,y,height,opacity,scale,font.letterSpacing"
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
                    properties: "x,y,height,opacity,scale,font.letterSpacing"
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
                    properties: "x,y,height,opacity,scale,font.letterSpacing"
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
