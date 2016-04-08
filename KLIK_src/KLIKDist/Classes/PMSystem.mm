//
//  PMSystem.m
//  iDocShare
//
//  Created by tywang on 2014/12/19.
//
//

#import "PMSystem.h"
#import "ConfigurationDefs.h"
#import "OperationManagerApple.h"
#import "CommandDefs.h"
#import "PMPlayerSDK.h"


#define PM_NOTIFICATION_DOMAIN_STATUS_CHANGE "PM_Notification_Domain_Status_Changed"
#define PM_NOTIFICATION_JINGLEDOMAIN_STATUS_CHANGE "PM_Notification_JingleDomain_Status_Changed"
#define LIVEDOMAIN_LAN "LiveDomain_Lan"
#define LIVEDOMAIN_JINGLE "LiveDomain_Jingle"

#define TestUserName "kworldcompanytest@gmail.com"
#define TestUserPassword "kworldoem"

@interface PMSystem ()
{
    void* m_DomainHandle;

}

- (void)OnLanDomainStatusChanged:(NotificationInfo*)info;
- (void)OnJingleDomainStatusChanged:(NotificationInfo*)info;

- (void)OnBelongingsScanReport:(NSDictionary*)info;
- (void)ExecOperation:(OperationApple*) anOperation WaitUntilDone:(NSNumber*) bWait;


@end

@implementation PMSystem

static PMSystem* defaultPMS=nil;
+ (PMSystem*) defaultPMSystem
{
    return defaultPMS;

}
+ (void) releaseDefaultPMSystem
{
    if (defaultPMS)
        [defaultPMS dealloc];
    defaultPMS = nil;
}

#pragma mark -
#pragma mark property synthesize

- (PMPlayerAppleTranslator*)m_pPMPlayer
{
    return m_pPMPlayer;
}
- (void*)m_DomainHandle
{
    return m_DomainHandle;
}

#pragma mark -
#pragma mark Application lifecycle

- (id)init
{
    self =[super init];
    if(!self)
        return nil;
    bool noerr = true;
    do
    {
        noerr = [[PMPlayerSDK alloc] InitPMPlayerSDK];
        if (!noerr)
            break;
        
        m_pPMPlayer = [[PMPlayerAppleTranslator alloc] init];
        if (!m_pPMPlayer)
        {
            noerr = false;
            break;
        }
        m_pBelongingsManager = nil;
        self.m_BelongingsRecordHolder = nil;
        m_DomainHandle = nil;
        
        // register notification handler to reflect in UI
        [[NotificationTranslatorApple defaultNotificationTranslator] AddNotification:@PM_NOTIFICATION_DOMAIN_STATUS_CHANGE Observer:self selector:@selector(OnLanDomainStatusChanged:)];
        
        [[NotificationTranslatorApple defaultNotificationTranslator] AddNotification:@PM_NOTIFICATION_JINGLEDOMAIN_STATUS_CHANGE Observer:self selector:@selector(OnJingleDomainStatusChanged:)];
        
        [m_pPMPlayer LoginDomain:@LIVEDOMAIN_LAN aUserName:@TestUserName aPassword:@TestUserPassword aNotificationStatus:@PM_NOTIFICATION_DOMAIN_STATUS_CHANGE];
        //m_pLanDomain = [m_pPMPlayer GetDomain:@LIVEDOMAIN_LAN aNotificationStatus:@PM_NOTIFICATION_DOMAIN_STATUS_CHANGE];
        
        //m_pJingleDomain = [m_pPMPlayer GetDomain:@LIVEDOMAIN_JINGLE aNotificationStatus:@PM_NOTIFICATION_JINGLEDOMAIN_STATUS_CHANGE];
        
        //    DomainAccountInfo* pAccountInfoLan = [DomainAccountInfo alloc];
        //    pAccountInfoLan.UserName = @TestUserName;
        //    pAccountInfoLan.Password = @TestUserPassword;
        //    [m_pLanDomain performSelectorInBackground:@selector(Login:) withObject:pAccountInfoLan];
        //pAccountInfo.UserName = @TestUserName;
        //pAccountInfo.Password = @TestUserPassword;
        
        [[NotificationTranslatorApple defaultNotificationTranslator] AddNotification:@PM_NOTIFICATION_CHECKPOINTS Observer:self selector:@selector(OnPMSCheckPoint:)];
        
        [[NotificationTranslatorApple defaultNotificationTranslator] AddNotification:@PM_NOTIFICATION_BELONGINGS_SCAN_STATUS Observer:self selector:@selector(OnBelongingsScanReport:)];
        
        // config VSC pipeline
        NSString* key = [[NSString alloc] initWithCString:"VALUE" encoding:NSASCIIStringEncoding];
        NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
        [dic setValue:@VSP_FILTER_ffmpeg_BGRA2YUV420 forKey:key];
        [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@"PM_VSP_VSPFilter_Name" NotificationData:dic];
        // config av pipeline
        key = [[NSString alloc] initWithCString:"VALUE" encoding:NSASCIIStringEncoding];
        dic = [[NSMutableDictionary alloc] init];
        // config audio pipeline
        [dic setValue:@VS_AUDIO_RECEIVER_ACTIVE forKey:key];
        [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@PM_VSC_CONFIG_VSAUDIORECEIVER_NAME NotificationData:dic];
        
        [dic setValue:@VSCONFIG_NONE forKey:key];
        [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@PM_VSC_CONFIG_VSAUDIODECODER_NAME NotificationData:dic];
        
        [dic setValue:@VS_AUDIO_PACKETRENDER forKey:key];
        [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@PM_VSC_CONFIG_VSAUDIORENDER_NAME NotificationData:dic];
        
        [dic setValue:@PM_VS_CONFIG_MODE_PUSH forKey:key];
        [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@PM_VS_CONFIG_AUDIO_MODE NotificationData:dic];
        
#define PMPFEATURE_REQUIRE_AUDIO_CODEC_AAC        (0x00000001 << 13)
        // Config Feature requirement
        uint32_t FeatureRequire = PMPFEATURE_REQUIRE_AUDIO_CODEC_AAC;
        [dic setValue:[NSNumber numberWithUnsignedInt:FeatureRequire] forKey:key];
        [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@PM_FEATURE_REQUIREMENT NotificationData:dic];
        
        //set camera source
        NSMutableDictionary* dicCameraSource = [[[NSMutableDictionary alloc] init] autorelease];
        [dicCameraSource setValue:@"Back" forKey:key];
        [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@"PM_Cam_Config_Video_Source" NotificationData:dicCameraSource];
        
        // register operation executor
        [[OperationManagerApple defaultOperationManager] RegisterExecutor:@PM_EXECUTOR_GUITHREAD Observer:self selector:@selector(ExecOperation:WaitUntilDone:)];
        
        defaultPMS = self;

    }while(false);
    
    if (!noerr)
    {
        if (m_pPMPlayer)
        {
            [m_pPMPlayer dealloc];
        }
        return nil;
    }

    return self;
}
- (void)dealloc
{
    if (m_pPMPlayer)
        [m_pPMPlayer dealloc];

    [super dealloc];
}
- (void)OnLanDomainStatusChanged:(NSDictionary*)info
{
    int State = [(NSNumber*) [info objectForKey:@"STATE"] intValue];
    void* DomainHandle = ((NotificationInfo*)[info objectForKey:@"DOMAINHANDLE"]).Data;
    
    switch (State)
    {
        case kPMSLiveDomain_In:
        {
            if (!m_pBelongingsManager)
                m_pBelongingsManager = [m_pPMPlayer GetBelongingsManager];
            if (m_pBelongingsManager)
            {
                [m_pBelongingsManager StartScanBelongings];
            }
            m_DomainHandle = DomainHandle;
            break;
        }
        case kPMSLiveDomain_Out:
        {
            break;
        }
        case kPMSLiveDomain_LogoutProgress:
        {
            [m_pBelongingsManager StopScanBelongings];
            break;
        }
            
        default:
            break;
    }
    
}
- (void)OnJingleDomainStatusChanged:(NSDictionary*)info
{
    int State = [(NSNumber*) [info objectForKey:@"STATE"] intValue];
    void* DomainHandle = ((NotificationInfo*)[info objectForKey:@"DOMAINHANDLE"]).Data;
    switch (State)
    {
        case kPMSLiveDomain_In:
        {
            m_pBelongingsManager = [m_pPMPlayer GetBelongingsManager];
            if (m_pBelongingsManager)
            {
                [m_pBelongingsManager StartScanBelongings];
            }
            break;
        }
        case kPMSLiveDomain_Out:
        {
            break;
        }
        case kPMSLiveDomain_LogoutProgress:
        {
            [m_pBelongingsManager StopScanBelongings];
            break;
        }
        default:
            break;
    }
    
    
}

- (void)OnBelongingsScanReport:(NSDictionary*)info
{
    int Status = [(NSNumber*) [info objectForKey:@"Status"] intValue];
    BelongingsRecordApple* BelongingsRecord = [[[BelongingsRecordApple alloc] init] autorelease];
    BelongingsRecord.m_bValid = [(NSNumber*) [info objectForKey:@"Status"] boolValue];
    BelongingsRecord.m_SupportedFeatures = [(NSNumber*) [info objectForKey:@"m_SupportedFeatures"] intValue];
    BelongingsRecord.m_WantedFeature = [(NSNumber*) [info objectForKey:@"m_WantedFeature"] intValue];
    BelongingsRecord.m_Name = (NSString*)[info objectForKey:@"m_Name"];
    BelongingsRecord.m_Password = (NSString*)[info objectForKey:@"m_Password"];
    BelongingsRecord.m_Address = (NSString*)[info objectForKey:@"m_Address"];
    BelongingsRecord.m_Options = (NSString*)[info objectForKey:@"m_Options"];
    BelongingsRecord.m_Port = [(NSNumber*) [info objectForKey:@"m_Port"] intValue];
    BelongingsRecord.m_DeviceType = [(NSNumber*) [info objectForKey:@"m_DeviceType"] intValue];
    BelongingsRecord.m_DiscoveringState = [(NSNumber*) [info objectForKey:@"m_DiscoveringState"] intValue];
    BelongingsRecord.m_CommWay = [(NSNumber*) [info objectForKey:@"m_CommWay"] intValue];
    BelongingsRecord.m_UIDLength = [(NSNumber*) [info objectForKey:@"m_UIDLength"] intValue];
    BelongingsRecord.m_UID = (uint8_t*)((NotificationInfo*) [info objectForKey:@"m_UID"]).Data;
    BelongingsRecord.m_MACLength = [(NSNumber*) [info objectForKey:@"m_MACLength"] intValue];
    BelongingsRecord.m_MAC = (uint8_t*)((NotificationInfo*) [info objectForKey:@"m_MAC"]).Data;
    BelongingsRecord.jid = (NSString*)[info objectForKey:@"jid"];
    BelongingsRecord.serverType = (NSString*)[info objectForKey:@"serverType"];
    BelongingsRecord.xmppSupport = [(NSNumber*) [info objectForKey:@"xmppSupport"] boolValue];
    BelongingsRecord.xfOptions = [(NSNumber*) [info objectForKey:@"xfOptions"] intValue];
    BelongingsRecord.wanIP = [(NSNumber*) [info objectForKey:@"wanIP"] unsignedIntValue];
    BelongingsRecord.wanAuthPort = [(NSNumber*) [info objectForKey:@"wanAuthPort"] unsignedIntValue];
    BelongingsRecord.wanAudioPort = [(NSNumber*) [info objectForKey:@"wanAudioPort"] unsignedIntValue];
    BelongingsRecord.wanVideoPort = [(NSNumber*) [info objectForKey:@"wanVideoPort"] unsignedIntValue];
    BelongingsRecord.DomainHandle = ((NotificationInfo*) [info objectForKey:@"DomainHandle"]).Data;
    BelongingsRecord.m_Version = [(NSNumber*) [info objectForKey:@"m_Version"] intValue];
    
    if (BelongingsRecord.m_DiscoveringState == BS_Discovered)
    {
        if (self.m_BelongingsRecordHolder)
            [self.m_BelongingsRecordHolder addDiscoverBelongingRecord:BelongingsRecord];
    }
    else if (BelongingsRecord.m_DiscoveringState == BS_NotExist)
    {
        if (self.m_BelongingsRecordHolder)
            [self.m_BelongingsRecordHolder delDiscoverBelongingRecord:BelongingsRecord];
        
    }
    
    
}

- (void)ExecOperation:(OperationApple*) anOperation WaitUntilDone:(NSNumber*) bWait
{
    if ([bWait boolValue])
        [self performSelectorOnMainThread:@selector(ExecOperationOnMainThread:) withObject:anOperation waitUntilDone:YES];
    else
        [self performSelectorOnMainThread:@selector(ExecOperationOnMainThread:) withObject:anOperation waitUntilDone:NO];
    
    
}
- (void)ExecOperationOnMainThread:(OperationApple*) anOperation
{
    [anOperation ExecOperation];
}

- (void)OnPMSCheckPoint:(NSDictionary*)info
{
    //    NSNumber* type = (NSNumber*) [info objectForKey:@"CHECKPOINT"];
    //    CheckPointType checkpoint = [type intValue];
    //    if (checkpoint == kCP_First_Feature_Stopped)
    //    {
    //        m_isPlayed = false;
    //        if (m_isStopCalled)
    //            dispatch_semaphore_signal(m_CallSemaphore);
    //        return;
    //    }
    //    else if (checkpoint == kCP_PBC_Stopped)
    //    {
    //        m_isPlayed = false;
    //        if (m_isStopCalled)
    //            dispatch_semaphore_signal(m_CallSemaphore);
    //        return;
    //
    //    }
    
    [self performSelectorOnMainThread:@selector(ProcessNotificationOnMainThread:) withObject:info waitUntilDone:YES];
    
}
- (void)ProcessNotificationOnMainThread:(NSDictionary*)info
{
    NSNumber* type = (NSNumber*) [info objectForKey:@"CHECKPOINT"];
    CheckPointType checkpoint = [type intValue];
    if (checkpoint == kCP_First_iFrame_Received)
    {
//        PMVariantApple *pVariant = [[PMVariantApple alloc] initWithptr:(void *)self.DiscoveryNavigator];
//        [m_pPMPlayer Command:kCommand_Show Value:pVariant];
    }
    
}


@end
