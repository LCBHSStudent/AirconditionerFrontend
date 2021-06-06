#ifndef NETWORKHELPER_H
#define NETWORKHELPER_H

#include "defination.h"
#include <QObject>
#include <memory>

class QTcpSocket;
class QTimer;

class NetworkHelper: public QObject {
    Q_OBJECT
public:
    explicit    /*构造网络辅助类*/
        NetworkHelper(
            const QString&  hostAddr,
            int             port,
            QObject*        parent = nullptr
        );
    virtual 
        ~NetworkHelper();
    
    bool        /*获取当前socket连接状态*/
        getStatus() const;

public slots:
    // 公有函数域
    void    /*当连接断开时调用*/
        closeConnection();
    void    /*连接到服务器端时调用*/ 
        connect2host();
    void    /*发送QString类型的data到服务器端*/
        sendToServer(const QString&);
    void    /*发送QByteArray封装的数据到服务端*/
        sendToServer(QByteArray&&);

signals:
    // 信号组
    void    /*socket状态变动触发的信号*/
        statusChanged(bool status);
    void    /*当接收到server数据报文时触发*/
        sigServerMessage(QByteArray data);

    
public RESOURCE:
    const static int /*指定连接超时限制*/
        connectLmt = 3000;
    const static int /*指定重新连接尝试间隔*/
        heartBeatInterval = 10000;
    
private slots:
    // 私有函数域
    void    /*当socket接收到可供阅读数目的数据报文时调用*/
        readyRead();
    void    /*当成功连接时调用*/
        connected();
    void    /*当连接超时时调用*/
        connectionTimeout();
    void    /*检查当前socket状态并判断是否进行重新连接*/
        checkAndReconnect();
    
private RESOURCE:
    QString                             /*存储服务器host信息*/
        m_host = {};
    int                                 /*用于指定端口号*/
        m_port = 0;
    bool                                /*存储socket连接ok状态*/
        m_status = false;
    quint16                             /*暂时废弃*/
        m_nextBlockSize = 0;
    std::unique_ptr<QTcpSocket>         /*Qt封装的socket类*/
        m_socket;
    std::unique_ptr<QTimer>             /*判断连接是否超时的timer*/
        m_timeoutTimer;
    std::unique_ptr<QTimer>             /*判断是否重新连接的timer*/
        m_keepAliveTimer;
};

#endif // NETWORKHELPER_H
