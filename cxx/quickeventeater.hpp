#ifndef QUICKEVENTEATER_HPP
#define QUICKEVENTEATER_HPP

#include <QObject>
#include <QDebug>
#include <QKeyEvent>

#include "defination.h"

class QuickEventEater: public QObject {
    Q_OBJECT
public:
    QuickEventEater(QObject* parent)
        : QObject(parent) 
    {
        if (parent) parent->installEventFilter(this);
    }
signals:
    void reload();
protected:
    bool eventFilter(QObject*, QEvent* e) override {
        if (e->type() == QEvent::KeyPress) {
            auto ke = static_cast<QKeyEvent*>(e);
            if (ke->key() == Qt::Key_Q && ke->modifiers() == Qt::Modifier::ALT) {
                emit reload();
                LOG(Log, "Start reloading qml components");
                
                return true;
            }
        }
        return false;
    }
};

#endif // QUICKEVENTEATER_HPP
