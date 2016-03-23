//
//  CommandDefs.h
//
//  Created by tywang on 13/11/6.
//  Desc. Definitions of all commands used by GUI
//

#ifndef _CommandDefs_h
#define _CommandDefs_h

#define PM_ReturnCode "ErrorCode"
#define PM_ErrorCode_Success 0
#define PM_ErrorCode_GenericError -1
#define PM_ErrorCode_ArgError -2

//
//
// ******** Playback controller related **********
//
//
// General return code
#define PM_PBC_CMD_CR_SUCCESS PM_ErrorCode_Success
#define PM_PBC_CMD_CR_NOTSUPPORT -3
#define PM_PBC_CMD_CR_FEATURE_EXIST -4
#define PM_PBC_CMD_CR_FEATURE_NOT_RUNNING -5

// MultiModeController
#define PM_PBC_CMD_SET_STREAMMODE "PM_PBC_CMD_Set_StreamMode"
#define PM_PBC_CMD_SET_STREAMMODE_ARG_MODE "Mode"
#define PM_PBC_CMD_SET_STREAMMODE_ARG_FEATUREID "FeatureID"

#define PM_PBC_STREAMMODE_PRESENTATION 1
#define PM_PBC_STREAMMODE_VIDEO 2
#define PM_PBC_CHANGE_RESOLUTION 3

#define PM_PBC_CHANGE_RESOLUTION_ARG_Width "Width"
#define PM_PBC_CHANGE_RESOLUTION_ARG_Height "Height"
#define PM_PBC_CHANGE_RESOLUTION_ARG_FEATUREID "FeatureID"

// return code of Set StreamMode
#define PM_PBC_CMD_CHANGERESOLUTION "PM_PBC_CMD_ChangeResolution"

// Conference Control
#define PM_PBC_CMD_SET_ATTRIBUTES "PM_PBC_CMD_Set_Attributes"
#define PM_PBC_CMD_SET_ATTRIBUTES_ARG_ROLETYPE "RoleType"
#define PM_PBC_CMD_SET_ATTRIBUTES_ARG_USERNAME "UserName"
#define PM_PBC_CMD_SET_ATTRIBUTES_ARG_PASSWORD "Password"

#define PM_PBC_CMD_SetAdminPasswd "SetAdminPassword"
#define PM_PBC_CMD_SetAdminPasswd_Arg_OldPassword "OldPassword"
#define PM_PBC_CMD_SetAdminPasswd_Arg_NewPassword "NewPassword"
#define PM_PBC_CMD_SetAdminPasswd_Arg_Password "Password"
#define PM_PBC_CMD_ResetAdminPasswd "ResetAdminPassword"


#define PM_PBC_CMD_STARTFEATURE "PM_PBC_CMD_StartFeature"
#define PM_PBC_CMD_STARTFEATURE_ARG_JOINERID "JoinerID"
#define PM_PBC_CMD_STARTFEATURE_ARG_FEATUREID "FeatureID"
#define PM_PBC_CMD_STARTFEATURE_ARG_FEATURENAME "FeatureName"
#define PM_PBC_CMD_STARTFEATURE_ARG_DISPLAYMODE "DisplayMode"
#define PM_PBC_CMD_STARTFEATURE_ARG_DISPLAYID "DisplayID"
#define PM_PBC_CMD_STARTFEATURE_ARG_USEHOSTRESOLUTION "UseHostResolution"
#define PM_PBC_CMD_STARTFEATURE_ARG_LEFT "Left"
#define PM_PBC_CMD_STARTFEATURE_ARG_TOP "Top"
#define PM_PBC_CMD_STARTFEATURE_ARG_WIDTH "Width"
#define PM_PBC_CMD_STARTFEATURE_ARG_HEIGHT "Height"

#define PM_PBC_CMD_SUSPENDFEATURE "PM_PBC_CMD_SuspendFeature"
#define PM_PBC_CMD_SUSPENDFEATURE_ARG_FEATUREID "FeatureID"
#define PM_PBC_CMD_SUSPENDFEATURE_ARG_FEATURENAME "FeatureName"
#define PM_PBC_CMD_SUSPENDFEATURE_ARG_JOINERID "JoinerID"

#define PM_PBC_CMD_RESUMEFEATURE "PM_PBC_CMD_ResumeFeature"
#define PM_PBC_CMD_RESUMEFEATURE_ARG_FEATUREID "FeatureID"
#define PM_PBC_CMD_RESUMEFEATURE_ARG_FEATURENAME "FeatureName"
#define PM_PBC_CMD_RESUMEFEATURE_ARG_JOINERID "JoinerID"

#define PM_PBC_CMD_STOPFEATURE "PM_PBC_CMD_StopFeature"
#define PM_PBC_CMD_STOPFEATURE_ARG_JOINERID "JoinerID"
#define PM_PBC_CMD_STOPFEATURE_ARG_FEATUREID "FeatureID"
#define PM_PBC_CMD_STOPFEATURE_ARG_FEATURENAME "FeatureName"

#define PM_PBC_CMD_STOPFEATURE_CurrentPresenters "PM_PBC_CMD_StopFeature_CurrentPresenters"
#define PM_PBC_CMD_STOPFEATURE_CurrentPresenters_ARG_FEATUREID "FeatureID"
#define PM_PBC_CMD_STOPFEATURE_CurrentPresenters_ARG_FEATURENAME "FeatureName"

#define PM_PBC_CMD_SET_HOST_ROLEINFO "PM_PBC_CMD_Set_Host_RoleInfo"
#define PM_PBC_CMD_SET_HOST_ROLEINFO_ARG_ROLETYPE "PM_PBC_CMD_Set_Host_RoleType"
#define PM_PBC_CMD_SET_HOST_ROLEINFO_ARG_PASSWORD "PM_PBC_CMD_Set_Host_Password"
#define PM_PBC_CMD_SET_HOST_ROLEINFO_ARG_FIRSTAUTH "PM_PBC_CMD_Set_Host_FirstAuth"

#define PM_PBC_CMD_EnableBlankDesktop "PM_PBC_CMD_EnableBlankDesktop"
#define PM_PBC_CMD_EnableBlankDesktop_ARG_Enable "Enable"

#define PM_PBC_CMD_SetFPS "PM_PBC_CMD_SetFPS"
#define PM_PBC_CMD_SetBitrate "PM_PBC_CMD_SetBitrate"
#define PM_PBC_CMD_OpenExchange "PM_PBC_CMD_OpenExchange"
#define PM_PBC_CMD_OpenExchange_ARG_ExchangeType "ExchangeType"
#define PM_PBC_CMD_OpenExchange_ARG_JoinerCount "JoinerCount"
//PM_PBC_CMD_OpenExchange_ARG_JoinerID_Base + Index
#define PM_PBC_CMD_OpenExchange_ARG_JoinerID_Base "JoinerID_"
#define PM_PBC_CMD_OpenExchange_Return_ExchangeID "ExchangeID"

#define PM_PBC_CMD_OpenMsgDataExchange "PM_PBC_CMD_OpenMsgDataExchange"
#define PM_PBC_CMD_OpenMsgDataExchange_ARG_ExchangeType "ExchangeType"
#define PM_PBC_CMD_OpenMsgDataExchange_ARG_JoinerCount "JoinerCount"
//PM_PBC_CMD_OpenExchange_ARG_JoinerID_Base + Index
#define PM_PBC_CMD_OpenMsgDataExchange_ARG_JoinerID_Base "JoinerID_"
#define PM_PBC_CMD_OpenMsgDataExchange_Return_MsgExchangeID "MsgExchangeID"
#define PM_PBC_CMD_OpenMsgDataExchange_Return_DataExchangeID "DataExchangeID"

#define PM_PBC_CMD_OpenMsgDataExchange_ARG_ExchangeType_One2One 0
#define PM_PBC_CMD_OpenMsgDataExchange_ARG_ExchangeType_One2Other 1

// VideoPlaybackController
#define PM_PBC_PlayMode_LocalFile 1
#define PM_PBC_PlayMode_RemoteFile 2

//
//
// ******** End - Playback controller **********
//
//

#define PM_EXECUTOR_GUITHREAD "GUIThreadExecutor"

#define PM_EXECUTOR_GUITHREAD_OP_PROCESSHIDEVENT "ProcessHIDEvent"


//
//
// ******** PMFolder relative commands and events **********
//
//
// CMD - OpenFolder
#define PMFolder_CMD_OpenFolder "OpenFolder"
#define PMFolder_OpenFolder_ARG_SortingType "SortingType"
#define PMFolder_OpenFolder_ARG_FetchSize "FetchSize"
#define PMFolder_OpenFolder_ARG_Desc "Desc"
#define PMFolder_OpenFolder_ARG_OpenMode "OpenMode"

#define PMFolder_OpenFolder_OpenMode_Read 0
#define PMFolder_OpenFolder_OpenMode_Write 1

#define PMFolder_Event "Event"

#define PMFolder_Event_FolderLoadNewInfo "FolderLoadNewInfo"
#define PMFolder_Event_FolderLoadNewInfo_Arg_StartIndex "StartIndex"
#define PMFolder_Event_FolderLoadNewInfo_Arg_Size "Size"

#define PMFolder_Event_FolderLoadError "FolderLoadError"
#define PMFolder_Event_FolderLoadError_Arg_ErrorCode "ErrorCode"
#define PMFolder_Event_FolderLoadDone "FolderLoadDone"
#define PMFolder_Event_FolderLoadStart "FolderLoadStart"

#define PMFolder_Event_FolderClosed "FolderClosed"


// CMD - OpenFolder
#define PMFT_CMD_DownloadFile "DownloadFile"

//
//
// ******** End - PMFolder commands and events **********
//
//

//
//
// ******** FileTranspoter Server Task commands **********
//
//
// CMD - GetAlbumPhotoInfo :
// Args : FullPath - the full path of folder. prefix "/root" would be replaced by actual path
//        SortingType - how to sort the entry
//        FetchSize - number of info want to fetch
//        FromValue - not used now
//        Desc - not used now
#define PMFT_Server_CMD_GetFolderInfo "PMFT_Server_CMD_GetFolderInfo"
#define PMFT_Server_CMD_GetFolderInfo_ARG_FullPath "FullPath"
#define PMFT_Server_CMD_GetFolderInfo_ARG_SortingType "SortingType"
#define PMFT_Server_CMD_GetFolderInfo_ARG_FetchSize "FetchSize"
#define PMFT_Server_CMD_GetFolderInfo_ARG_FromValue "FromValue"
#define PMFT_Server_CMD_GetFolderInfo_ARG_Desc "Desc"
#define PMFT_Server_CMD_GetFolderInfo_ARG_Ticket "Ticket"


#define PMFT_Server_CMD_GetFolderInfo_Ret_GenericError PM_ErrorCode_GenericError
#define PMFT_Server_CMD_GetFolderInfo_Ret_ArgError PM_ErrorCode_ArgError

#define PMFT_Server_CMD_GetFolderInfo_Event "Event"
#define PMFT_Server_CMD_GetFolderInfo_Event_Error -1
#define PMFT_Server_CMD_GetFolderInfo_Event_Done 0
#define PMFT_Server_CMD_GetFolderInfo_Event_NewInfo 1

// CMD - GetFile :
// Args : FullPath - the full path of the file. prefix "/root" would be replaced by actual path
//
#define PMFT_Server_CMD_GetFile "PMFT_Server_CMD_GetFile"
#define PMFT_Server_CMD_GetFile_ARG_PathName "FullPathName"
#define PMFT_Server_CMD_GetFile_ARG_Ticket "Ticket"

#define PMFT_Server_CMD_GetFile_Ret_Code PM_ReturnCode
#define PMFT_Server_CMD_GetFile_Ret_GenericError PM_ErrorCode_GenericError
#define PMFT_Server_CMD_GetFile_Ret_ArgError PM_ErrorCode_ArgError

#define PMFT_Server_CMD_GetFile_Event "Event"
#define PMFT_Server_CMD_GetFile_Event_Error -1
#define PMFT_Server_CMD_GetFile_Event_Done 0
#define PMFT_Server_CMD_GetFile_Event_NewInfo 1


//
//
// ******** End - FileTranspoter Server Task commands **********
//
//

//
//
// ******** Common Service related **********
//
//

// Desktop Service - DTS
#define PM_Service_Desktop "PM_Service_Desktop"
#define PM_DTS_CMD_GetPreview "PM_DTS_CMD_GetPreview"
#define PM_DTS_CMD_GetPreview_ARG_Width "Width"
#define PM_DTS_CMD_GetPreview_ARG_Height "Height"
#define PM_DTS_CMD_GetPreview_ARG_Quality "Quality"
#define PM_DTS_CMD_GetPreview_ARG_RxTicket "RxTicket"
#define PM_DTS_CMD_GetPreview_ARG_ExchangeID "ExchangeID"

#define PM_DTS_CMD_GetPreview_Ret_Code PM_ReturnCode
#define PM_DTS_CMD_GetPreview_Ret_GenericError PM_ErrorCode_GenericError
#define PM_DTS_CMD_GetPreview_Ret_ArgError PM_ErrorCode_ArgError


//
//
// ******** End - Common Service **********
//
//


#endif
