//
//  NSSServer.m
//  iDocShare
//
//  Created by tywang on 2014/12/19.
//
//

#import "NSSServer.h"
#include "ConfigurationDefs.h"
#import "PMPBCAppleTranslator.h"
#include "NSSCommandDefs.h"

#define PMPFEATURE_CONFIG_SHIFT_DisplayMode 16
#define PMPFEATURE_CONFIG_SHIFT_DisplayView 20

@interface NSSServer ()<PMPBCGUIDelegateApple>
{
    PMPBCAppleTranslator* m_CSPBC;
    void* m_hCSPBC;
    dispatch_semaphore_t m_CallSemaphore;
    dispatch_semaphore_t m_LogoutCompleteSemaphore;
    int m_WorkingCallError;
    
    void* m_hFeatureDT;
    PMJobApple* m_pWorkingJob;
    void* cmdHandleChangeToConfCtrl;
    void* cmdHandleChangeToNormal;

}
- (int)StartScreenMirrorSelf;
- (int)StopScreenMirrorSelf;

- (void)SetOutContextInMainThread;
@end

@implementation NSSServer


#pragma mark -
#pragma mark Application lifecycle

- (id)init
{
    self =[super init];
    if(!self)
        return nil;
    
    // get PMSystem if non, create one
    PMSystem* pSystem = [PMSystem defaultPMSystem];
    if (!pSystem)
    {
        // init PMS system
        pSystem = [[PMSystem alloc] init];
        if (!pSystem)
            return nil;
    }

    m_CSPBC = nil;
    m_hCSPBC = NULL;
    m_CallSemaphore = dispatch_semaphore_create(0);
    m_LogoutCompleteSemaphore = dispatch_semaphore_create(0);
    self.m_Mode = kNSSServer_Mode_Basic;
    self.m_bAdmin = false;
    m_pWorkingJob = nil;
    self.Status = kNSSServer_Out;
    return self;
}

- (void)dealloc
{
    dispatch_release(m_CallSemaphore);
    dispatch_release(m_LogoutCompleteSemaphore);
    if (m_pWorkingJob)
        [m_pWorkingJob dealloc];
    [super dealloc];
}

- (PMSystem*) GetPMSystem
{
    return [PMSystem defaultPMSystem];
}
#pragma mark -
#pragma mark login/out
- (PMPlayer_Error)Login:(BelongingsRecordApple*)Record
{
    if (self.Status != kNSSServer_Out)
        return kPMSError_PeerNotAccept;
    
    PMPlayerAppleTranslator *pPMPlayer = [PMSystem defaultPMSystem].m_pPMPlayer;
    
    Record.m_bValid = true;
    Record.m_Port = 6618;
    Record.m_WantedFeature = kFeatureTypeConferenceInfoFlag;
    
    // test multiple view, display mode = kOneView, display view = 0
//    Record.m_FeatureOptions = Record.m_FeatureOptions |(1 << PMPFEATURE_CONFIG_SHIFT_DisplayMode) ;
//    Record.m_FeatureOptions = Record.m_FeatureOptions | (0 << PMPFEATURE_CONFIG_SHIFT_DisplayView) ;
    self.Status = kNSSServer_LoginProgress;
    self.m_Mode = kNSSServer_Mode_Basic;
    self.m_bAdmin = false;

    //PMPlayer_Error hr = [pPMPlayer PlayMedia:Record withPlayback:@PM_PLAYBACKCONTROL_CONFERENCESERVICE];
    void* pTemPBC = NULL;
    PMPlayer_Error hr = [pPMPlayer Connect:Record withPlayback:@PM_PLAYBACKCONTROL_CONFERENCESERVICE returnPBC:&(pTemPBC)];
   if (hr !=kPMSError_NoError)
    {
        self.Status = kNSSServer_Out;
        return hr;
    }
    // set pbc gui delegate
//    NSArray* PBCList = [pPMPlayer GetPlaybackControllers];
//    PMPBCAppleTranslator* PBC = [PBCList objectAtIndex:0];
//    m_CSPBC = (PMPBCAppleTranslator*)PBC;
    m_CSPBC = (PMPBCAppleTranslator*)pTemPBC;
    [m_CSPBC SetGUIDelegate:self];
    m_hCSPBC = [m_CSPBC GetHandle];

    //check whether Adm exist. to determine mode and role
    CommandManagerApple* pCommandManager = [pPMPlayer GetCommandManager];

    [pCommandManager IssueAuthorizedCommand:Record CommandName:@NSS_CMD_CheckAdminExist Argument:nil ReturnObserver:self ReturnSelector:@selector(OnCheckAdminExistReturn:OutData:)];
    while (dispatch_semaphore_wait(m_CallSemaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }

    cmdHandleChangeToConfCtrl = [pCommandManager AddCommandHandler:@"ChangeToConfCtrl" Observer:self selector:@selector(OnChangeToConfCtrl:OutData:)];
    cmdHandleChangeToNormal = [pCommandManager AddCommandHandler:@"ChangeToNormal" Observer:self selector:@selector(OnChangeToNormal:OutData:)];

    self.Status = kNSSServer_In;
    self.ScreenMirrorStatus = kNSSServer_ScreenMirrorNone;
    return kPMSError_NoError;

}
// disconnect/logout current connected server
- (void)Logout
{
    if (self.Status != kNSSServer_In)
        return;
    if (self.ScreenMirrorStatus != kNSSServer_ScreenMirrorNone)
        return;
    
    self.Status = kNSSServer_LogoutProgress;
    PMPlayerAppleTranslator *pPMPlayer = [PMSystem defaultPMSystem].m_pPMPlayer;
    //[pPMPlayer StopMedia];
    [pPMPlayer Disconnect:(void *)m_CSPBC];
    while (dispatch_semaphore_wait(m_LogoutCompleteSemaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    [self SetOutContextInMainThread];
}

#pragma mark -
#pragma mark MirrorScreen

// Start mirroring screen to nssserver
- (int)StartScreenMirror
{
    if (self.m_Mode == kNSSServer_Mode_Basic)
    {
        return [self StartScreenMirrorSelf];
    }
    else if (self.m_bAdmin)
    {
        // in conference control mode and self is admin, not support now
        return NSS_ErrorCode_GenericError;
    }
    else
    {
        // logic error - in conference control mode and self is not admin
        assert(false);
    }
}
// stop mirroring screen to nssserver
- (int)StopScreenMirror
{
    if (!m_CSPBC)
        return 0;
    if (self.ScreenMirrorStatus != kNSSServer_ScreenMirroring)
        return 0;
    
    if (self.m_Mode == kNSSServer_Mode_Basic)
    {
        return [self StopScreenMirrorSelf];
    }
    else if (self.m_bAdmin)
    {
        // in conference control mode and self is admin, not support now
        return NSS_ErrorCode_GenericError;
    }
    else
    {
        // in conference control mode and self is not admin
        return [self StopScreenMirrorSelf];
    }

}
- (NSString *)GetHostName
{
    char tmp_hostname[64];
    memset(tmp_hostname, 0, sizeof(tmp_hostname));
    if( ! gethostname(tmp_hostname, sizeof(tmp_hostname) - 1)) {
        char *p = strchr(tmp_hostname, '.' );
        if( p ){
            *p = '\0';
        }
    }else{
        strcpy(tmp_hostname, "PMPlayer" );
    }
    NSString* hostname = [NSString stringWithCString:tmp_hostname encoding:NSUTF8StringEncoding];
    return hostname;
}

- (int)StartScreenMirrorSelf
{
    assert (self.ScreenMirrorStatus == kNSSServer_ScreenMirrorNone);
    assert(m_CSPBC);
    
    NSMutableDictionary* dicJob = [[[NSMutableDictionary alloc] init] autorelease];
    dicJob[@"JobName"] = @NSS_CMD_Transfer;
    dicJob[@NSS_CMD_Transfer_ARG_NextName] = [self GetHostName];
    self.ScreenMirrorStatus = kNSSServer_ScreenMirrorPreparing;
    
    m_WorkingCallError = 0;
    if (m_pWorkingJob)
    {
        // remove last working job
        [m_pWorkingJob dealloc];
        m_pWorkingJob = nil;
    }
    m_pWorkingJob = [m_CSPBC IssueJob2Peer:@NSS_CMD_Transfer Argument:dicJob EventObserver:self EventSelector:@selector(OnTransferJobReturn:OutData:)];
    while (dispatch_semaphore_wait(m_CallSemaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    if (m_WorkingCallError < 0)
        self.ScreenMirrorStatus = kNSSServer_ScreenMirrorNone;
    return m_WorkingCallError;
}
- (int)StopScreenMirrorSelf
{
    assert (self.ScreenMirrorStatus == kNSSServer_ScreenMirroring);
    
    NSMutableDictionary* dicJob = [[[NSMutableDictionary alloc] init] autorelease];
    dicJob[@"JobName"] = @NSS_CMD_StopFeature;
    dicJob[@NSS_CMD_StopFeature_ARG_Requester] = [self GetHostName];
    self.ScreenMirrorStatus = kNSSServer_ScreenMirrorStopping;
    m_WorkingCallError = 0;
    if (m_pWorkingJob)
    {
        // remove last working job
        [m_pWorkingJob dealloc];
        m_pWorkingJob = nil;
    }
    m_pWorkingJob = [m_CSPBC IssueJob2Peer:@NSS_CMD_StopFeature Argument:dicJob EventObserver:self EventSelector:@selector(OnStopFeatureReturn:OutData:)];
    while (dispatch_semaphore_wait(m_CallSemaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    return m_WorkingCallError;
}

- (int)ChangeVideoDimension:(int)Width height:(int)Height
{
    assert(m_CSPBC);
    
    NSMutableDictionary* dicArg = [[[NSMutableDictionary alloc] init] autorelease];
    dicArg[@PM_PBC_CMD_SET_STREAMMODE_ARG_MODE] = [NSNumber numberWithInt:PM_PBC_CHANGE_RESOLUTION];
    dicArg[@PM_PBC_CHANGE_RESOLUTION_ARG_Width] = [NSNumber numberWithInt:Width];
    dicArg[@PM_PBC_CHANGE_RESOLUTION_ARG_Height] = [NSNumber numberWithInt:Height];
    dicArg[@PM_PBC_CMD_RESUMEFEATURE_ARG_FEATUREID] = [NSNumber numberWithUnsignedInt:kFeatureTypeDesktopFlag];

    bool noerr = [m_CSPBC Command:@PM_PBC_CMD_SET_STREAMMODE Argument:dicArg ReturnObserver:self ReturnSelector:@selector(OnSetStreamModeReturn:OutData:)];
    if (noerr)
        return 0;
    else
        return -1;
}

- (void) EnableBlankView:(bool)enable
{
    NSMutableDictionary* dicArg = [[[NSMutableDictionary alloc] init] autorelease];
    dicArg[@PM_PBC_CMD_EnableBlankDesktop_ARG_Enable] = [NSNumber numberWithBool:enable];

    bool noerr = [m_CSPBC Command:@PM_PBC_CMD_EnableBlankDesktop Argument:dicArg ReturnObserver:nil ReturnSelector:nil];
}

#pragma mark PMPBCGUIDelegateApple

- (void) OnPBCStatusChanged:(void*) theHandle state:(int)currentState info:(NSDictionary*)theInfo
{
    if (m_hCSPBC != theHandle)
        return;
    
    switch (currentState) {
        case kState_Stopped:
        {
            // cs pbc has stopped... logouted
            do
            {
                if(self.Status == kNSSServer_LogoutProgress)
                {
                    // logout by user
                     dispatch_semaphore_signal(m_LogoutCompleteSemaphore);
                    break;
                }
                
                // logout due to other reason... lost connection/component failed
                [self performSelectorOnMainThread:@selector(SetOutContextInMainThread) withObject:nil waitUntilDone:true];
            } while (false);
            break;
        }
            
        default:
            break;
    }

}
- (void)SetOutContextInMainThread
{
    self.Status = kNSSServer_Out;
    if (m_CSPBC)
    {
        [m_CSPBC dealloc];
        m_CSPBC = nil;
        m_hCSPBC = NULL;
    }

}
- (void)SetScreenMirroringContextInMainThread:(NotificationInfo*)Info
{
    m_hFeatureDT = Info->theData;
    self.ScreenMirrorStatus = kNSSServer_ScreenMirroring;

    
}
- (void)SetScreenMirrorStoppedContextInMainThread
{
    m_hFeatureDT = NULL;
    self.ScreenMirrorStatus = kNSSServer_ScreenMirrorNone;
    
}

- (void) OnFeatureStatusChanged: (NSString*)FeatureName handle:(void*) theHandle state:(int)currentState info:(NSDictionary*)theInfo
{
    if (([FeatureName compare:@PM_FEATURE_DESKTOP] == 0) && (currentState == kState_Running))
    {
        // ScreenMirror running
        NotificationInfo* pNotificationData = [[NotificationInfo alloc] init];
        pNotificationData->theData = theHandle;
        
        [self performSelectorOnMainThread:@selector(SetScreenMirroringContextInMainThread:) withObject:pNotificationData waitUntilDone:true];

        return;
    }
    if ((theHandle == m_hFeatureDT) && (currentState == kState_Stopped))
    {
        // Screen mirror stopped
        
        [self performSelectorOnMainThread:@selector(SetScreenMirrorStoppedContextInMainThread) withObject:nil waitUntilDone:true];
        return;
    }
}

#pragma mark NSSServer command/return handler


- (void)OnCheckAdminExistReturn:(NSDictionary*)anInData OutData:(NSDictionary*)anOutData
{
    bool bAdminExist = [anInData[@NSS_CMD_CheckAdminExist_ARG_AdminExist] boolValue];
    
    if (bAdminExist)
    {
        self.m_Mode = kNSSServer_Mode_ConferenceControl;
        self.m_bAdmin = false;
    }
    else
    {
        self.m_Mode = kNSSServer_Mode_Basic;
        self.m_bAdmin = false;
    }
    
    dispatch_semaphore_signal(m_CallSemaphore);
}

- (void)OnTransferJobReturn:(NSDictionary*)anInData OutData:(NSDictionary*)anOutData
{
    m_WorkingCallError = [anInData[@NSS_ReturnCode] integerValue];
    dispatch_semaphore_signal(m_CallSemaphore);
}
- (void)OnStopFeatureReturn:(NSDictionary*)anInData OutData:(NSDictionary*)anOutData
{
    m_WorkingCallError = [anInData[@NSS_ReturnCode] integerValue];
    dispatch_semaphore_signal(m_CallSemaphore);
}
- (void)OnChangeToConfCtrl:(NSDictionary *)anInData OutData:(NSDictionary *)anOutData
{
    
    NotificationInfo* pNotificationData = [[NotificationInfo alloc] init];
    pNotificationData->theData = (void*)kNSSServer_Mode_ConferenceControl;
    
    [self performSelectorOnMainThread:@selector(SetModeContextInMainThread:) withObject:pNotificationData waitUntilDone:true];
    [pNotificationData dealloc];
}

- (void)OnChangeToNormal:(NSDictionary *)anInData OutData:(NSDictionary *)anOutData
{
    NotificationInfo* pNotificationData = [[NotificationInfo alloc] init];
    pNotificationData->theData = (void*)kNSSServer_Mode_Basic;
    
    [self performSelectorOnMainThread:@selector(SetModeContextInMainThread:) withObject:pNotificationData waitUntilDone:true];
    [pNotificationData dealloc];
}
- (void)SetModeContextInMainThread:(NotificationInfo*)Info
{
    self.m_Mode = (int)(Info->theData);
    self.m_bAdmin = false;
}

- (void)OnSetStreamModeReturn:(NSDictionary*)anInData OutData:(NSDictionary*)anOutData
{
    
}



@end
