#include "clientbackend.h"

#include <QJsonDocument>
#include <QJsonObject>

#include <QSettings>
#include <QFileInfo>

#include "protocol.h"
#include "networkhelper/networkhelper.h"

#include <mutex>

// 用于检测socket连接状态的宏，不是非成员函数！
#define CHECK_SOCKET_STATUS                             \
    if(!m_helper->getStatus()) {                        \
        emit sigShowPopup("Client offline", "OK");      \
        LOG(Error, "Client offline");                   \
        return;                                         \
    }                                                   \

constexpr auto configPath = "./RemoteConfig.ini";

/**
 * @brief ClientBackend::ClientBackend
 *        构造后台类
 * @param {QString}hostAddr 服务端IPV4-addr字符串
 */
ClientBackend::ClientBackend(QObject* parent)
    : QObject(parent)
{
    if (!QFileInfo::exists(configPath)) {
        LOG(Fatal, "Failed to load config file: {./RemoteConfig.ini}");
        throw std::runtime_error("Missing config");
    }
    
    QSettings remoteConfig("./RemoteConfig.ini", QSettings::IniFormat);
    
    auto&& host = remoteConfig.value("RemoteConfig/Host", "").toString();
    auto   port = remoteConfig.value("RemoteConfig/Port", -1).toInt();
    
    if (host.isEmpty() || port == -1) {
        LOG(Fatal, "Failed to load {RemoteConfig/Host} or {RemoteConfig/Port}");
        throw std::runtime_error("Error value from config");
    }
    
    m_helper = std::make_unique<NetworkHelper>(host, port, this);
    connect(
        m_helper.get(), &NetworkHelper::sigServerMessage,
        this,           &ClientBackend::slotGetServerMessage
    );
    m_helper->connect2host();
}

/**
 * @brief ClientBackend::~ClientBackend
 *        后台类析构函数
 */
ClientBackend::~ClientBackend() {}


/**
 * @brief ClientBackend::slotGetServerMessage
 *        接收到server信息时调用
 * @param {QByteArray} data 由网络辅助类送来的封装数据
 */

#define GEN_JSONOBJ QJsonObject resp = QJsonDocument::fromJson(QByteArray(data)).object()

void ClientBackend::slotGetServerMessage(QByteArray data) {
    GEN_JSONOBJ;
    if (resp["type"] != TypeAirConditionerFindAllRes && resp["type"] != TypeAirConditionerFindByRoomRes) {
        LOG(Log, "Got server respones") << QString(data);
    }
    
    static QHash<QString, std::function<void(QVariantMap&&)>> reflector = {};
    
    // install event handler functions
    std::once_flag init;
    std::call_once(init, [this] {
        // 注册
        reflector[TypeAdminRegister] = [this](QVariantMap&& var) {
            emit sigUserSignUp(var["code"].toInt(), var["msg"].toString());
        };
        // 登录
        reflector[TypeAdminLogin] = [this](QVariantMap&& var) {
            emit sigUserLogin(var["code"].toInt(), var["msg"].toString());
        };
        // 所有房间信息
        reflector[TypeAirConditionerFindAllRes] = [this](QVariantMap&& var) {
            auto&& rawRoomList = var["air_conditioners"].toList();
            QList<QVariantMap> roomList;
            
            foreach(auto room, rawRoomList) {
                roomList.append(room.toMap());
            }
            
            emit sigGetAllRoomData(roomList);
        };
        // 普通提示
        reflector[TypeNormalRes] = [this](QVariantMap&& var) {
            if (var["code"].toInt() == 200) {
                emit sigShowPopup(var["msg"].toString(), "OK");
            } else {
                emit sigShowPopup(QString::number(var["code"].toInt()) + ": " + var["msg"].toString(), "Retry");
            }
        };
        // 详单
        reflector[TypeGetDetailListRes] = [this](QVariantMap&& var) {
            if (var["code"] == 200) {
                
            } else {
                emit sigShowPopup(QString::number(var["code"].toInt()) + ": " + var["msg"].toString(), "Retry");
            }
        };
        // 账单
        reflector[TypeFeeQueryRes] = [this](QVariantMap&& var) {
            if (var["code"] == 200) {
                emit sigShowPopup("客户需支付: " + var["msg"].toString() + "元", "Retry");
            }
        };
        // 客户登入
        reflector[TypeUserLogin] = [this](QVariantMap&& var) {
            emit sigUserLogin(0, var["room_number"].toString());
        };
        // 获取单个房间信息
        reflector[TypeAirConditionerFindByRoomRes] = [this](QVariantMap&& var) {
            emit sigGetRoomData(var["air_conditioner"].toMap());
        };
        // 获取房间账单
        reflector[TypeFeeQueryRes] = [this](QVariantMap&& var) {
            emit sigGetRoomBill(var["fee"].toMap()["cost"].toDouble());
        };
    });
    
    
    auto magic = QJsonDocument::fromJson(resp["data"].toString().toUtf8());
    reflector[resp["type"].toString()](magic.object().toVariantMap());
}

/**
 * @brief ClientBackend::sendSignInRequest
 *        发送登录请求
 * @param username 用户名
 * @param password 密码
 */
void ClientBackend::sendSignInRequest(
    QString     username,
    QString     password,
    int         authorityLevel
) {
    CHECK_SOCKET_STATUS;
    LOG(Log, "Try Signing in") << username << password << authorityLevel;
    
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    if (authorityLevel != 3) {
        _data.insert("user_name", username);
        _data.insert("password",  password);
        _data.insert("authority_level", authorityLevel);
        
        obj.insert("type", TypeAdminLogin);
    } else {
        _data.insert("phone", username);
        _data.insert("password",  password);
        
        obj.insert("type", TypeUserLogin);
    }
    
    data.setObject(_data);
    
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

/**
 * @brief ClientBackend::sendSignUpRequest
 *        发送注册请求
 * @param username 用户名
 * @param password 密码
 */
void ClientBackend::sendSignUpRequest(
    QString     username,
    QString     password,
    int         authorityLevel
) {
    CHECK_SOCKET_STATUS;
    LOG(Log, "Try signing up") << username << password << authorityLevel;

    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    _data.insert("user_name", username);
    _data.insert("password",  password);
    _data.insert("authority_level", authorityLevel);
    data.setObject(_data);
    
    obj.insert("type", TypeAdminRegister);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendGetAllRoomInfoRequest() {
    LOG(Log, "Get all room info routine");
    
    QJsonDocument req;
    
    QJsonObject obj;
    
    obj.insert("type", TypeAirConditionerFindAll);
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendFlipPowerRequest(bool powerOn, int roomCode) {
    LOG(Log, "Flip airconditioner power") << powerOn;
    
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    if (powerOn) {
        _data.insert("room_num", roomCode);
        _data.insert("mode",  "cold");
        _data.insert("wind_level", "high");
        _data.insert("temperature", 25.5);
        _data.insert("wind_flag", 1);               // 是否改变风速
        _data.insert("open_time", static_cast<int>(QDateTime::currentDateTime().toTime_t()));
        obj.insert("type", TypeAirConditionerOn);
    } else {
        _data.insert("room_num", roomCode);
        _data.insert("close_time", static_cast<int>(QDateTime::currentDateTime().toTime_t()));
        obj.insert("type", TypeAirConditionerOff);
    }
    
    data.setObject(_data);
    
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendSetParamRequest(
    int         room_num, 
    QString     mode, 
    QString     wind_level, 
    double      temperature,
    int         wind_flag
) {
    LOG(Log, "Set airCondition params");
    
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    _data.insert("room_num", room_num);
    _data.insert("mode", mode);
    _data.insert("wind_level", wind_level);
    _data.insert("temperature", temperature);
    _data.insert("wind_flag", wind_flag);
    
    data.setObject(_data);
    
    obj.insert("type", TypeAirConditionerSetParam);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendRegisterCustomerRequest(int room_num, QString phone_number, QString password) {
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    _data.insert("room_num", room_num);
    _data.insert("phone", phone_number);
    _data.insert("password", password);
    
    data.setObject(_data);
    
    obj.insert("type", TypeUserRegister);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendUserCheckoutRequest(int room_num) {
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    _data.insert("room_num", room_num);
    
    data.setObject(_data);
    
    obj.insert("type", TypeUserCheckout);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendGetBillRequest(int room_num) {
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    _data.insert("room_num", room_num);
    
    data.setObject(_data);
    
    obj.insert("type", TypeFeeQuery);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendGetDetailRequest(int room_num) {
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    _data.insert("room_num", room_num);
    
    data.setObject(_data);
    
    obj.insert("type", TypeGetDetailList);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendUpdateRoomInfoRequest(int room_num) {
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    _data.insert("room_num", room_num);
    
    data.setObject(_data);
    
    obj.insert("type", TypeAirConditionerFindByRoom);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}

void ClientBackend::sendGetRoomBillRequest(int room_num) {
    QJsonDocument req;
    QJsonDocument data;
    
    QJsonObject obj;
    QJsonObject _data;
    
    _data.insert("room_num", room_num);
    
    data.setObject(_data);
    
    obj.insert("type", TypeFeeQuery);
    obj.insert("data", QString(data.toJson()));
    
    req.setObject(obj);
    
    m_helper->sendToServer(req.toJson());
}
