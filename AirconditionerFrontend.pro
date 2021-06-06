QT += quick network quickcontrols2

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
	cxx/clientbackend/networkhelper/networkhelper.cpp \
	cxx/clientbackend/clientbackend.cpp \
	cxx/main.cpp

RESOURCES += qml.qrc \
    res.qrc

INCLUDEPATH += $${PWD}\cxx

CONFIG(debug, debug|release) {
	DEFINES += DEBUG_BUILD
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    cxx/clientbackend/networkhelper/networkhelper.h \
    cxx/clientbackend/clientbackend.h \
    cxx/defination.h \
    cxx/protocol.h \
    cxx/quickeventeater.hpp

OTHER_FILES += \
	
