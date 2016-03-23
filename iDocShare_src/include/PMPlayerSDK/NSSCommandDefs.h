//
//  NSSCommandDefs.h
//
//

#ifndef _NSSCommandDefs_h
#define _NSSCommandDefs_h
#include "CommandDefs.h"


#define NSS_ReturnCode PM_ReturnCode
#define NSS_EventName "EventName"

#define NSS_ErrorCode_Success PM_ErrorCode_Success
#define NSS_ErrorCode_GenericError PM_ErrorCode_GenericError
#define NSS_ErrorCode_ArgError PM_ErrorCode_ArgError
#define NSS_ErrorCode_JoinerNotExist -3
#define NSS_ErrorCode_PresenterNotExist -4
#define NSS_ErrorCode_FeatureNotSupport -5
#define NSS_ErrorCode_FeatureExist -6
#define NSS_ErrorCode_OtherTaskInprogress -7
#define NSS_ErrorCode_PresenterExist -8
#define NSS_ErrorCode_TimeOut -9
#define NSS_ErrorCode_SendCommandFailed -10

#define NSS_ErrorCode_Last -10
//
//
//
//
#define NSS_CMD_ARG_JobName "JobName"
// Command - Transfer
#define NSS_CMD_Transfer "NS_CMD_Transfer"
#define NSS_CMD_Transfer_ARG_NextName "NextName"
#define NSS_CMD_Transfer_ARG_FeatureID PM_PBC_CMD_STARTFEATURE_ARG_FEATUREID
#define NSS_CMD_Transfer_ARG_Force "Force"


#define NSS_CMD_StopFeature "NSS_CMD_StopFeature"
#define NSS_CMD_StopFeature_ARG_TargetJoiner PM_PBC_CMD_STOPFEATURE_ARG_JOINERID
#define NSS_CMD_StopFeature_ARG_Requester "Requester"
#define NSS_CMD_StopFeature_ARG_FeatureID PM_PBC_CMD_STOPFEATURE_ARG_FEATUREID

#define NSS_CMD_SuspendFeature "NSS_CMD_SuspendFeature"
#define NSS_CMD_SuspendFeature_ARG_TargetJoiner PM_PBC_CMD_SUSPENDFEATURE_ARG_JOINERID
#define NSS_CMD_SuspendFeature_ARG_Requester "Requester"
#define NSS_CMD_SuspendFeature_ARG_FeatureID PM_PBC_CMD_SUSPENDFEATURE_ARG_FEATUREID

#define NSS_CMD_ResumeFeature "NSS_CMD_ResumeFeature"
#define NSS_CMD_ResumeFeature_ARG_TargetJoiner PM_PBC_CMD_RESUMEFEATURE_ARG_JOINERID
#define NSS_CMD_ResumeFeature_ARG_Requester "Requester"
#define NSS_CMD_ResumeFeature_ARG_FeatureID PM_PBC_CMD_RESUMEFEATURE_ARG_FEATUREID

// Events of Transfer
#define NSS_CMD_Transfer_Event_Name NSS_EventName
#define NSS_CMD_Transfer_Event_Done "EventDone"
#define NSS_CMD_Transfer_RetCode PM_ReturnCode
//#define NSS_CMD_Transfer_Exception_TransferInprogress PM_ErrorCode_Last-1


// Command - CheckAdminExist
#define NSS_CMD_CheckAdminExist "CheckAdminExist"
#define NSS_CMD_CheckAdminExist_ARG_AdminExist "AdminExist"

// command - GetJoinerList
#define NSS_CMD_GetJoinerList "GetJoinerList"

//cmd handler
#define NSS_CMDHandler_ControlMode_Change2ConfCtrl "ChangeToConfCtrl"
#define NSS_CMDHandler_ControlMode_Change2ConfNormal "ChangeToNormal"

#define NSS_CMDHandler_Adm_AddJoiner "AddJoiner"
#define NSS_CMDHandler_Adm_RemoveJoiner "RemoveJoiner"
#define NSS_CMDHandler_Adm_UpdateAdmUIPlay "UpdateAdmUIPlay"
#define NSS_CMDHandler_Adm_UpdateAdmUIPlay_ARG_Presenter "Presenter"
#define NSS_CMDHandler_Adm_UpdateAdmUIPlay_ARG_FeatureName "FeatureName"

#define NSS_CMDHandler_Adm_UpdateAdmUIStop "UpdateAdmUIStop"
#define NSS_CMDHandler_Adm_UpdateAdmUIStop_ARG_Presenter "Presenter"
#define NSS_CMDHandler_Adm_UpdateAdmUIStop_ARG_FeatureName "FeatureName"

// Device configuration
#define NSS_CMD_SetAudioMute "SetAudioMute"
#define NSS_CMD_SetAudioMute_ARG_Index "Index"
#define NSS_CMD_GetAudioMute "GetAudioMute"
#define NSS_CMD_GetAudioMute_ARG_Mute "Mute"

#define NSS_CMD_SetAudioVolume "SetAudioVolume"
#define NSS_CMD_SetAudioVolume_ARG_Index "Index"
#define NSS_CMD_GetAudioVolume "GetAudioVolume"
#define NSS_CMD_GetAudioVolume_ARG_Volume "Volume"

#define NSS_CMD_EnableUSBBackChannel "USBBackChannelEnable"
#define NSS_CMD_EnableUSBBackChannel_ARG_Enable "Enable"
#define NSS_CMD_EnableRemoteCursor "RemoteCursorEnable"
#define NSS_CMD_EnableRemoteCursor_ARG_Enable "Enable"

#define NSS_CMD_SetRadioBand "SetRadioBand"
#define NSS_CMD_SetRadioBand_ARG_Index "Index"
#define NSS_CMD_GetRadioBand "GetRadioBand"
#define NSS_CMD_GetRadioBand_ARG_Index "Index"


#endif
