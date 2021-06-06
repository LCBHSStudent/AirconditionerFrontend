#ifndef DEFINATION_H
#define DEFINATION_H

#define FUNCTION  
#define RESOURCE  
#define Q_RESOURCE

#define uint32 uint32_t

#include <QString>
#include <QDateTime>
enum LogLevel {
    Log = 0,
    Error,
    Fatal
};
inline static const QString __logstr_dict[Fatal + 1] = {
    "[Log]   ",
    "[Error] ",
    "[Fatal] "
};
inline QString logstr(LogLevel level, const QString& message) {
    
    return  __logstr_dict[level] +
            QDateTime::currentDateTime().toString("<yyyy-MM-dd hh:mm:ss.zzz>  ") +
            message;
}

#define LOG(__LEVEL__, __MESSAGE__) \
    qDebug().noquote() << logstr(__LEVEL__, __MESSAGE__)

#endif // DEFINATION_H
