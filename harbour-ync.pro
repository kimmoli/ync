#
# Project harbour-ync, Yamaha Network Controller
#

TARGET = harbour-ync

CONFIG += sailfishapp
QT += xml xmlpatterns

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""

message($${DEFINES})

SOURCES += \
	src/ync.cpp \
    src/main.cpp \
    src/networkobserver.cpp
	
HEADERS += src/ync.h \
    src/networkobserver.h

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    qml/pages/Remote.qml \
    qml/pages/AboutPage.qml \
    rpm/harbour-ync.spec \
	harbour-ync.png \
    harbour-ync.desktop \
    qml/ync.qml \
    qml/pages/AboutDevice.qml

