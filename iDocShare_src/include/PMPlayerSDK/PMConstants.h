//
//  PMConstants.h
//

#ifndef _PMConstants_h
#define _PMConstants_h
#include "ConfigurationDefs.h"
#include "CommandDefs.h"

enum {
    kState_Uninit = 1000, // Uninit for routine operation but for configuration polling and setting
    kState_Init, // Init state for routine operation
    kState_Running,  // Rutine running
	kState_Stopping,  // [Arthur] Add Stopping state to solve the issue of SignalThread dependency
    kState_Stopped,  // Rutine stopped
    kState_Paused,   // Rutine paused
    kState_Exception, // Exception occur
    kState_Exit,      // Resource to be free
    kState_InSession,
    kState_OutSession
} ;
typedef int PMState;

enum 
{
	kCP_PMS_Inited,
	kCP_PMS_ServiceStarted,
	kCP_PMS_ServiceStopped,
    kCP_First_iFrame_Start, 
    kCP_First_iFrame_Received,
    kCP_First_Feature_Stopped,
    kCP_First_Feature_Wait,
    kCP_PBC_Stopped
};
typedef int CheckPointType;

enum {
    kPMSLiveDomain_Out = 0,
    kPMSLiveDomain_In, 
    kPMSLiveDomain_LoginProgress,
    kPMSLiveDomain_LogoutProgress,
    kPMSLiveDomain_Error_UnAuthorized
};

enum {
    kPMSError_NoError = 0, 
    kPMSError_FeatureNotSupport,
    kPMSError_PeerUnreachable,
    kPMSError_PeerNotAccept,
    kPMSError_AuthenticationFailed,
    kPMSError_Command_HandlerNotFound,
    kPMSError_Command_ParseError,
    kPMSError_OtherError,
    kPMSError_PeerNotAccept_MaxClient,
    kPMSError_PeerNotAccept_FeatureExist,
    kPMSError_Channel_Block,
	kPMSError_PeerNotAccept_JoinerExist,
    kPMSError_PeerNotAccept_NotCompatible
    
};
typedef int PMPlayer_Error;

enum {
    kFeatureTypeNoneFlag = 0,
    kFeatureTypeDesktopFlag	= (1 << 0),
    kFeatureTypeCamFlag			= (1 << 1),
    kFeatureTypePushDesktopFlag = (1 << 2),
    kFeatureTypePushCamFlag = (1 << 3),
    kFeatureTypeDTVFlag	= (1 << 4),
 	kFeatureTypeGrabberFlag	= (1 << 5),
    kFeatureTypeImageCastFlag	= (1 << 6),
    kFeatureTypeConferenceInfoFlag	= (1 << 7),
    kFeatureTypeFileTransporterFlag	= (1 << 8),
	kFeatureTypeOnlyRXFlag	= (1 << 9),
	kFeatureTypePhotoSessionFlag	= (1 << 10)

};

typedef unsigned int PMFeatureTypeFlag;
// DataService
enum
{
    kDSEventNone = 0,
    kDSEventOpenComplete = 1UL << 0,
    kDSEventDataAvailable = 1UL << 1,
    kDSEventSpaceAvailable = 1UL << 2,
    kDSEventErrorOccurred = 1UL << 3,
    kDSEventEndEncountered = 1UL << 4
};

typedef unsigned int PMDataEvent;

enum {
    PMDataError_ChannelBroken = -1000,
    PMDataError_OtherError = -1002
};

#endif
