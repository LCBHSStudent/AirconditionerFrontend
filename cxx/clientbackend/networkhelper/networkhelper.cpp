#include "networkhelper.h"

#include <QTcpSocket>
#include <QTimer>
#include <stdint.h>

/**
 * @method  构造网络辅助类
 * @param   {QString} hostAddr 服务器IP地址字符串 {QObject*} 父Object指针，默认为nullptr
 * @return  {void}
 */
NetworkHelper::NetworkHelper(const QString& hostAddr, int port, QObject* parent)
    : QObject(parent)
    , m_host(hostAddr)
    , m_port(port)
    , m_status(false)
    , m_nextBlockSize(0)
    , m_socket(std::make_unique<QTcpSocket>(this))
    , m_timeoutTimer(std::make_unique<QTimer>(this))
    , m_keepAliveTimer(std::make_unique<QTimer>(this))
{
    m_timeoutTimer->setSingleShot(true);
    
    m_keepAliveTimer->setSingleShot(false);
    m_keepAliveTimer->setInterval(heartBeatInterval);
    m_keepAliveTimer->setTimerType(Qt::TimerType::CoarseTimer);
    
    m_socket->setSocketOption(QAbstractSocket::LowDelayOption, 1);
    m_socket->setSocketOption(QAbstractSocket::KeepAliveOption, 1);
    
    connect(
        m_timeoutTimer.get(),   &QTimer::timeout,
        this,                   &NetworkHelper::connectionTimeout
    );
    connect(
        m_keepAliveTimer.get(), &QTimer::timeout,
        this,                   &NetworkHelper::checkAndReconnect
    );
    
    connect(
        m_socket.get(),         &QTcpSocket::disconnected,
        this,                   &NetworkHelper::closeConnection
    );
    
    connect(
        m_socket.get(),         &QTcpSocket::connected,
        this,                   &NetworkHelper::connected
    );
    connect(
        m_socket.get(),         &QTcpSocket::readyRead,
        this,                   &NetworkHelper::readyRead
    );
    
    m_keepAliveTimer->start();
}

/**
 * @method  连接服务端
 * @param   {void}
 * @return  {void}
 */
void NetworkHelper::connect2host() {
    m_timeoutTimer->start(connectLmt);
    m_socket->connectToHost(m_host, m_port);
}

/**
 * @method  连接超时时触发的槽函数
 * @param   {void}
 * @return  {void}
 */
void NetworkHelper::connectionTimeout() {
    LOG(Error, "Connection timeout");
    if(m_socket->state() == QAbstractSocket::ConnectingState) {
        m_socket->abort();
        emit m_socket->errorOccurred(QAbstractSocket::SocketTimeoutError);
    }
}

/**
 * @method  检查socket状态，尝试重新连接服务端
 * @param   {void}
 * @return  {void}
 */
void NetworkHelper::checkAndReconnect() {
    LOG(Log, "Checking socket status") << m_socket->state();
    
    if(m_socket->state() != QAbstractSocket::ConnectedState) {
        LOG(Log, "Try reconnecting host machine");
        connect2host();
    }
}

/**
 * @method  连接服务端成功后触发的槽函数
 * @param   {void}
 * @return  {void}
 */
void NetworkHelper::connected() {
    m_status = true;
    m_timeoutTimer->stop();
    LOG(Log, "Successfully connected to server");
    emit statusChanged(true);
}

/**
 * @method  获取socket状态
 * @param   {void}
 * @return  {bool} socket状态
 */
bool NetworkHelper::getStatus() const {return m_status;}

/**
 * @method  socket有数据可读
 * @param   {void}
 * @return  {void}
 */
void NetworkHelper::readyRead() {
    QByteArray data = m_socket->readAll();
    
    emit sigServerMessage(data);
}

/**
 * @method  连接断开时触发的槽函数
 * @param   {void}
 * @return  {void}
 */
void NetworkHelper::closeConnection() {
    LOG(Log, "Disconnected from server");
    m_timeoutTimer->stop();
    
    // 防止服务端重启后客户端收不到已连接的信号
//    disconnect(m_socket, &QTcpSocket::connected, 0, 0);
//    disconnect(m_socket, &QTcpSocket::readyRead, 0, 0);
    
    bool shouldEmit = false;
    switch (m_socket->state()) {
    case 0:
        m_socket->disconnectFromHost();
        shouldEmit = true;
        break;
    case 2:
        m_socket->abort();
        shouldEmit = true;
        break;
    default:
        m_socket->abort();
        break;
    }
    
    if(shouldEmit) {
        m_status = false;
        emit statusChanged(false);
    }
}

/**
 * @method  析构网络辅助类
 * @param   {void}
 * @return  {void}
 */
NetworkHelper::~NetworkHelper() {
    if(m_status) {
        m_socket->disconnectFromHost();
    }
    m_timeoutTimer->stop();
    m_keepAliveTimer->stop();
}

/**
 * @method  发送QString封装的数据到服务端（废弃）
 * @param   {const QString&} QString数据引用
 * @return  {void}
 */
void NetworkHelper::sendToServer(const QString&) {
    
}

/**
 * @method  发送QByteArray封装的数据到服务端
 * @param   {QByteArray&&} QByteArray的右值引用 & 折叠后的一般引用
 * @return  {void}
 */
void NetworkHelper::sendToServer(QByteArray&& data) {
    m_socket->write(data, data.length());
//    m_socket->flush();
//    m_socket->waitForBytesWritten();
}
