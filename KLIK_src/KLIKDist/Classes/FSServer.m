//
//  FSServer.m
//  iDocShare
//
//  Created by tywang on 2014/12/19.
//
//

#import "FSServer.h"
#include "ConfigurationDefs.h"
#include "NSSCommandDefs.h"

#define PMPFEATURE_CONFIG_SHIFT_DisplayMode 16
#define PMPFEATURE_CONFIG_SHIFT_DisplayView 20

@interface FSServer ()<PMPBCGUIDelegateApple>
{
    PMPBCAppleTranslator* m_FSPBC;
    void* m_hFSPBC;
    dispatch_semaphore_t m_CallSemaphore;
    dispatch_semaphore_t m_LogoutCompleteSemaphore;
    
    void* m_hFeatureDT;

}

- (void)SetOutContextInMainThread;
@end

@implementation FSServer

#pragma mark -
#pragma mark property synthesize

- (PMPBCAppleTranslator*)FileSharePBC
{
    return m_FSPBC;
}


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

    m_FSPBC = nil;
    m_hFSPBC = NULL;
    m_CallSemaphore = dispatch_semaphore_create(0);
    m_LogoutCompleteSemaphore = dispatch_semaphore_create(0);
    self.Status = kFSServer_Init;
    return self;
}

- (void)dealloc
{
    dispatch_release(m_CallSemaphore);
    dispatch_release(m_LogoutCompleteSemaphore);

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
    if ((self.Status != kFSServer_Init) && (self.Status != kFSServer_Out))
        return kPMSError_PeerNotAccept;
    
    PMPlayerAppleTranslator *pPMPlayer = [PMSystem defaultPMSystem].m_pPMPlayer;
    
    if (!Record.DomainHandle)
    {
        Record.DomainHandle = [PMSystem defaultPMSystem].m_DomainHandle;
    }
    Record.m_bValid = true;
    Record.m_Port = 6618;
    Record.m_WantedFeature = kFeatureTypeFileTransporterFlag;
    
    self.Status = kFSServer_LoginProgress;

    //PMPlayer_Error hr = [pPMPlayer PlayMedia:Record withPlayback:@PM_PLAYBACKCONTROL_FileShare];
    void* pTemPBC = NULL;
    PMPlayer_Error hr = [pPMPlayer Connect:Record withPlayback:@PM_PLAYBACKCONTROL_FileShare returnPBC:&(pTemPBC)];

    if (hr !=kPMSError_NoError)
    {
        self.Status = kFSServer_Out;
        return hr;
    }
    // set pbc gui delegate
//    NSArray* PBCList = [pPMPlayer GetPlaybackControllers];
//    PMPBCAppleTranslator* PBC = [PBCList objectAtIndex:0];
    m_FSPBC = (PMPBCAppleTranslator*)pTemPBC;
    [m_FSPBC SetGUIDelegate:self];
    m_hFSPBC = [m_FSPBC GetHandle];


    self.Status = kFSServer_In;
    return kPMSError_NoError;

}
// disconnect/logout current connected server
- (void)Logout
{
    if (self.Status != kFSServer_In)
        return;
    
    self.Status = kFSServer_LogoutProgress;
    PMPlayerAppleTranslator *pPMPlayer = [PMSystem defaultPMSystem].m_pPMPlayer;
    //[pPMPlayer StopMedia];
    [pPMPlayer Disconnect:(void *)m_FSPBC];
    while (dispatch_semaphore_wait(m_LogoutCompleteSemaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    [self SetOutContextInMainThread];
}

#pragma mark -
#pragma mark MirrorScreen

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


#pragma mark PMPBCGUIDelegateApple

- (void) OnPBCStatusChanged:(void*) theHandle state:(int)currentState info:(NSDictionary*)theInfo
{
    if (m_hFSPBC != theHandle)
        return;
    
    switch (currentState) {
        case kState_Stopped:
        {
            // cs pbc has stopped... logouted
            do
            {
                if(self.Status == kFSServer_LogoutProgress)
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
    self.Status = kFSServer_Out;
    if (m_FSPBC)
    {
        [m_FSPBC dealloc];
        m_FSPBC = nil;
        m_hFSPBC = NULL;
    }

}

- (void) OnFeatureStatusChanged: (NSString*)FeatureName handle:(void*) theHandle state:(int)currentState info:(NSDictionary*)theInfo
{
}

#pragma mark FSServer command/return handler



@end
