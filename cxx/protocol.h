#ifndef PROTOCOL_H
#define PROTOCOL_H

#include <stdint.h>

#include <QString>

// 内存对齐去死
using AirConditionerData = struct {
	int         RoomNum;                // json:"room_num"         // 空调所在房间号，默认一个房间一个空调(中央空调形式)
	int         Power;                  // json:"power"            // 电源开关：0关 1开
	int         Mode;                   // json:"mode"             // 模式
	int         WindLevel;              // json:"wind_level"       // 风速
	double      Temperature;            // json:"temperature"      // 温度
	double      RoomTemperature;        // json:"room_temperature" // 室温
	double      TotalPower;             // json:"total_power"      // 该次入住的总耗电量
	QString     StartWind;              // json:"start_wind"       // 开始送风时间，时间戳格式
	QString     StopWind;               // json:"stop_wind"        // 停止送风时间
	QString     OpenTime;               // json:"open_time"        // 开机时间，数组，如 [1,2,3,4] ，由于mysql不支持切片类型，转换为string存储
	QString     CloseTime;              // json:"close_time"       // 关机时间，数组
	int         SetParamNum;            // json:"set_param_num"    // 调整次数，用于报表展示
};

constexpr auto TypeNormalRes        = "NormalRes";
    
constexpr auto TypeUserRegister     = "UserRegister";
constexpr auto TypeUserLogin        = "UserLogin";
constexpr auto TypeAdminRegister	= "AdminRegister";
constexpr auto TypeAdminLogin       = "AdminLogin";
constexpr auto TypeUserCheckout     = "UserCheckout";
constexpr auto TypeUserCheckoutRes  = "UserCheckoutRes";
constexpr auto TypeUserFindById     = "UserFindById";
constexpr auto TypeUserFindByIdRes  = "UserFindByIdRes";
constexpr auto TypeUserFindAll      = "UserFindAll";
constexpr auto TypeUserFindAllRes   = "UserFindAllRes";
constexpr auto TypeUserUpdate       = "UserUpdate";
    
constexpr auto TypeAirConditionerFindByRoom     = "AirConditionerFindByRoom";
constexpr auto TypeAirConditionerFindByRoomRes  = "AirConditionerFindByRoomRes";
constexpr auto TypeAirConditionerFindAll        = "AirConditionerFindAll";
constexpr auto TypeAirConditionerFindAllRes     = "AirConditionerFindAllRes";
constexpr auto TypeAirConditionerCreate         = "AirConditionerCreate";
constexpr auto TypeAirConditionerUpdate         = "AirConditionerUpdate";
constexpr auto TypeAirConditionerOn             = "AirConditionerOn";
constexpr auto TypeAirConditionerOff            = "AirConditionerOff";
constexpr auto TypeAirConditionerSetParam       = "AirConditionerSetParam";
constexpr auto TypeAirConditionerStopWind       = "AirConditionerStopWind";
constexpr auto TypeGetReport                    = "GetReport";
constexpr auto TypeGetReportRes                 = "GetReportRes";
constexpr auto TypeSetRoomData					= "SetRoomData";
constexpr auto TypeGetDetailList				= "GetDetailList";
constexpr auto TypeGetDetailListRes             = "GetDetailListRes";
    
constexpr auto TypeFeeAdd       = "FeeAdd";
constexpr auto TypeFeeQuery     = "FeeQuery";
constexpr auto TypeFeeQueryRes  = "FeeQueryRes";
constexpr auto TypeFeeDelete    = "FeeDelete";
    
constexpr auto TypeGetServingQueue      = "GetServingQueue";
constexpr auto TypeGetServingQueueRes   = "GetServingQueueRes";
    
#endif // PROTOCOL_H
