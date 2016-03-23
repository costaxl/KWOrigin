//
//  PMPlayerCommonTypes.h
//

#ifndef _PMPlayerCommonTypes_h
#define _PMPlayerCommonTypes_h
#include "PMConstants.h"

// Define system notification
#define PM_NOTIFICATION_CHECKPOINTS "Notification_CheckPoints"
#define PM_NOTIFICATION_FEATURE_REQUEST_INIT "Notification_Feature_Request_Init"
#define PM_NOTIFICATION_FEATURE_REQUEST_PLAY "Notification_Feature_Request_Play"
#define PM_NOTIFICATION_FPS_UPDATE "Notification_FPS_Update"
#define PM_NOTIFICATION_BPS_UPDATE "Notification_BPS_Update"

// Define system command
#define PM_COMMAND_CAL_STATISTICS "PMS_Command_Cal_Statistics"
#define PM_COMMAND_CAL_STATISTICS_ARG_Enable "Cal_Statistics"

#define PM_COMMAND_LAUNCH_IPERF "PMS_Command_Launch_Iperf"

// Define system properties
#define PM_PROPERTY_ENCODER_HAS_MFX264 "PM_Property_Encoder_HasMFX264"


enum {
	PMMSG_TYPE_AUTH_RESPONSE = 0,
    PMMSG_TYPE_AUTH_REQUEST,
    PMMSG_TYPE_COMMAND_CALL,
    PMMSG_TYPE_COMMAND_CALL2,
    PMMSG_TYPE_COMMAND_RETURN,
    PMMSG_TYPE_COMMAND_RETURN2,
    PMMSG_TYPE_COMMAND_PING,
    PMMSG_TYPE_COMMAND_INTERNAL,
    PMMSG_TYPE_DATA,
    PMMSG_TYPE_CHANNELCREATE_REQUEST,
    PMMSG_TYPE_CHANNELCREATE_RESPONSE,
    PMMSG_TYPE_JOB_CALL,
    PMMSG_TYPE_JOB_RETURN,
    PMMSG_TYPE_PROB_REQUEST,
    PMMSG_TYPE_PROB_RESPONSE,
    PMMSG_TYPE_ALIVE_CHECK,
    PMMSG_TYPE_ALIVE_REPONSE
    // [Arthur TODO] for compatibility with b28... need to move PMMSG_TYPE_COMMAND_INTERNAL to last

};

typedef enum 
{
    kDevice_iPad=0, 
    kDevice_iPad2,
    kDevice_iPhone,
    kDevice_iPod_touch,
	kDevice_WinPC,
	kDevice_MacPC,
	kDevice_LinuxDevice,
    kDevice_RTD1185v1,
    kDevice_RTD1185v2,
#ifdef ANDROID
    kDevice_AndroidPhone,
    kDevice_AndroidTablet,
#endif
    kDevice_Unknown = 0xffff
} TDeviceType;
#define NOTIFICATION_COMMAND  "Notification_Command"
typedef enum {
    kCommand_PMS = 0, 
    kCommand_Show,
    kCommand_Feature_Specific = 100,
    kCommand_Feature_Request_Init,
    kCommand_Feature_Request_StopInit,
    kCommand_Feature_Request_Play
} CommandType;
typedef struct {
    int Cmd;
    void* Value;
} Command_Notification;




struct PMLiveDomainStateInfo
{
    void* DomainHandle;
    int State;
};




#ifdef HAS_NO_UUID
typedef unsigned char uuid_t[16];
#endif
#endif
