#ifndef CLIENTBACKEND_H
#define CLIENTBACKEND_H

#include <QQuickItem>
#include "defination.h"
#include <memory>

class NetworkHelper;

class ClientBackend : public QObject {
    Q_OBJECT
    
public:
    explicit
        ClientBackend(QObject* parent = nullptr);
    virtual
        ~ClientBackend();
        
public FUNCTION:
    Q_INVOKABLE void    /*向服务器发送登录请求报文*/
        sendSignInRequest(QString username, QString password, int authorityLevel);
    Q_INVOKABLE void    /*向服务器发送注册请求报文*/
        sendSignUpRequest(QString username, QString password, int authorityLevel);
    Q_INVOKABLE void    /*请求所有房间状态*/
        sendGetAllRoomInfoRequest();
    Q_INVOKABLE void    /*开关电源*/
        sendFlipPowerRequest(bool powerOn, int roomCode);
    Q_INVOKABLE void    /*设置参数*/
        sendSetParamRequest(int room_num, QString mode, QString wind_level, double temperature, int wind_flag);
    Q_INVOKABLE void    /*客户入住*/
        sendRegisterCustomerRequest(int room_num, QString phone_number, QString password);
    Q_INVOKABLE void    /*客户退房*/
        sendUserCheckoutRequest(int room_num);
    Q_INVOKABLE void    /*获取房间账单*/
        sendGetBillRequest(int room_num);
    Q_INVOKABLE void    /*获取房间详单*/
        sendGetDetailRequest(int room_num);
    Q_INVOKABLE void    /*更新房间信息*/
        sendUpdateRoomInfoRequest(int room_num);
    Q_INVOKABLE void    /*获取房间账单*/
        sendGetRoomBillRequest(int room_num);
        
signals:
    // 信号组，用于backend通知前端进行响应
    void    /*触发用户名变化的信号*/
        userNameChanged();
    void    /*收到服务端注册响应*/
        sigUserSignUp(int status, QString msg);
    void    /*收到服务端登录响应*/
        sigUserLogin(int status, QString msg);
    void    /*收到请求用户信息响应*/
        sigGetUserInfo(int status, QVariantMap userInfo);
    void    /*展示弹窗*/
        sigShowPopup(QString msg, QString btn);
    void    /*获取全部房间信息*/
        sigGetAllRoomData(QList<QVariantMap> rooms);
    void    /*获取单个房间数据*/
        sigGetRoomData(QVariantMap data);
    void
        sigGetRoomBill(double fee);
    void    /*获取房间详单*/
        sigGetRoomDetail(QString msg);
    
private slots:
    void    /*接收network helper组件送来的服务器数据报文*/
        slotGetServerMessage(QByteArray);
    
private RESOURCE:
    std::unique_ptr<NetworkHelper>  /*网络组件（tcpsocket封装类指针)*/
        m_helper;
};

#endif // CLIENTBACKEND_H
