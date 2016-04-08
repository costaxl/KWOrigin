//
//  GUIAPPDelegate.m
//

#import "GUIAPPDelegate.h"
#import "PMPlayerAppleTranslator.h"
#import "NotificationTranslatorApple.h"
#import "DiscoveryListViewController.h"
#import "GmailSetting.h"
#import "ConfigurationDefs.h"
#import "CommandDefs.h"
#import "PMPBCAppleTranslator.h"
#import <DropboxSDK/DropboxSDK.h>

#import "WebBrowserViewController.h"

#import <AVFoundation/AVFoundation.h>


extern UIViewController *_g_testDisplayViewController;
enum
{
    kUIDSScenario_NoShare, // UI DocShare scenario - no share
    kUIDSScenario_SelfShare, // UI DocShare scenario - shared by self
    kUIDSScenario_HostShare // UI DocShare scenario - shared by Host
};

@interface GUIAPPDelegate ()<PMPBCGUIDelegateApple>
{
    GUIModelService* m_pModelService;
    UITabBarController *m_TabBarController;
    WebBrowserViewController* m_WebViewController;
    bool m_bLandscape;

    bool m_bTabLock;
    int m_UIDSScenario;
    int m_LastPresentState;

}
-(void) OnScreenMirrorStatusChange:(int) State;
-(void) OnConnectionStatusChange:(int) NewState oldState:(int)OldState;

@end


@implementation GUIAPPDelegate
@synthesize window=_window, movieListViewController=_movieListViewController,DiscoveryNavigator;

static GUIAPPDelegate* defaultApp=nil;
+ (GUIAPPDelegate*) defaultAppDelegate
{
    return defaultApp;
}
#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //sleep(5);
    // enable show all version of adv packets
    int advprotocol = (0x0001) << 16 | 0x0001;
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@PM_Notification_Value] = [NSNumber numberWithInt:advprotocol];
    [[NotificationTranslatorApple defaultNotificationTranslator] PostNotification:@PM_LANDOMAIN_CONFIG_ADVPROTOCOL NotificationData:dic];

    defaultApp = self;
    m_pModelService = [[GUIModelService alloc] init];
    m_WebViewController = nil;
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.delegate = self;
    m_TabBarController = tabBarController;
    m_bTabLock = false;
    m_UIDSScenario = kUIDSScenario_NoShare;
    m_LastPresentState = kNSSPresentState_Absent;
    
    self.DiscoveryNavigator = (UINavigationController *) self.window.rootViewController;
    _movieListViewController = [[self.DiscoveryNavigator viewControllers] objectAtIndex:0];
        
    
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    AudioSessionInitialize(NULL,
                           NULL,
                           nil,
                           ( void *)(self)
                           );
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory
                            );
    
    AudioSessionSetActive(true);
    
    
    // Setup Dropbox Here with YOUR OWN APP info
    // #error Dropbox App Key and Secret are required for basic functionality. Add them below AND in the Info.plist file in the URL-Schemes section. Replace the "APP_KEY" text with your app key (make sure to leave the "db-" there)
    DBSession *dbSession = [[DBSession alloc] initWithAppKey:@"jcnyo2zkq4mhdtu" appSecret:@"ue5qz8jvnjujsv3" root:kDBRootDropbox];
    [DBSession setSharedSession:dbSession];
    
    // add property observer
    [m_pModelService.m_NSSserver addObserver:self forKeyPath: @"ScreenMirrorStatus" options: NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld  context: NULL];
    [m_pModelService.m_NSSserver addObserver:self forKeyPath: @"Status" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: NULL];
    [m_pModelService.m_NSSserver addObserver:self forKeyPath: @"m_Mode" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: NULL];

    // add view's present state notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ViewPresentStateDidChange:)
                                                 name:NSSPresentStateDidChangeNotification object:nil];



    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [m_pModelService.m_NSSserver Logout];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// The application becomes active after a sync (i.e., file upload)
    if (![GUIModelService defaultModelService].m_AppSetting.m_ScreenShareServerRecord)
        return;
    // login server automatically
    NSString *ErrMsg = nil;
    PMPlayer_Error result = [[GUIModelService defaultModelService].m_NSSserver Login:[GUIModelService defaultModelService].m_AppSetting.m_ScreenShareServerRecord];
    
    //keep recorder in setting
    if (result==0)
    {
        ErrMsg = @"Login Successful";
        
    }
    else
    {
        ErrMsg = @"Login Failed";
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [m_pModelService.m_NSSserver Logout];
    [m_pModelService dealloc];
}

- (void)dealloc {
    [_movieListViewController release];
    [self.DiscoveryNavigator release];
    [_window release];
    
    [m_pModelService dealloc];
    [super dealloc];
}

#pragma mark -
#pragma mark Device orientation and dimension

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == m_pModelService.m_NSSserver)
    {
        // monitor ScreenMirror status
        if ([keyPath compare:@"ScreenMirrorStatus"]==0)
        {
            int NewStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            int OldStatus = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
            [self OnScreenMirrorStatusChange:NewStatus oldState:OldStatus];
        }
        // monitor connection status
        else if ([keyPath compare:@"Status"]==0)
        {
            int NewStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            int OldStatus = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
            [self OnConnectionStatusChange:NewStatus oldState:OldStatus];
        }
        // monitor mode (basic mode or conference control) status
        else if ([keyPath compare:@"m_Mode"]==0)
        {
            int NewStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            int OldStatus = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
            [self OnModeStatusChange:NewStatus oldState:OldStatus];
        }

    }
}
-(void) OnScreenMirrorStatusChange:(int) NewState oldState:(int)OldState
{
    if (NewState == kNSSServer_ScreenMirroring)
    {
        // Screen has mirrored
        UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(deviceOrientation))
            m_bLandscape = true;
        else
            m_bLandscape = false;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification object:nil];

        if ((m_pModelService.m_NSSserver.m_Mode == kNSSServer_Mode_ConferenceControl) && (m_pModelService.m_NSSserver.m_bAdmin == false))
        {
            m_UIDSScenario = kUIDSScenario_HostShare;
            if (m_LastPresentState == kNSSPresentState_Present)
                [m_pModelService.m_NSSserver EnableBlankView:false];
            else if (m_LastPresentState == kNSSPresentState_Absent)
                [m_pModelService.m_NSSserver EnableBlankView:true];

        }
    }
    else if (NewState == kNSSServer_ScreenMirrorNone)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        
        if ((m_pModelService.m_NSSserver.m_Mode == kNSSServer_Mode_ConferenceControl) && (m_pModelService.m_NSSserver.m_bAdmin == false))
        {
            m_UIDSScenario = kUIDSScenario_NoShare;
        }

    }
}

-(void) OnConnectionStatusChange:(int) NewState oldState:(int)OldState
{
    NSLog(@"Login status, new state:%d, old state:%d", NewState, OldState);
    if ((OldState == kNSSServer_In) && (NewState == kNSSServer_Out))
    {
        // connection broken accedentally
        [self alertConnectionLost];
    }
    if (NewState == kNSSServer_In)
    {
        // login - check conference control mode
        if (m_pModelService.m_NSSserver.m_Mode == kNSSServer_Mode_Basic)
            m_UIDSScenario = kUIDSScenario_SelfShare;
        // enable blank view as default
        [m_pModelService.m_NSSserver EnableBlankView:true];
        //change appearance of tab bar to reflect the status of connection
        UITabBarItem *item = [m_TabBarController.tabBar.items objectAtIndex:3];
        item.image = [[UIImage imageNamed:@"tabConnected_25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else if (NewState == kNSSServer_Out)
    {
        m_UIDSScenario = kUIDSScenario_NoShare;
        UITabBarItem *item = [m_TabBarController.tabBar.items objectAtIndex:3];
        item.image = [[UIImage imageNamed:@"tabSetting_25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    }
}
-(void) OnModeStatusChange:(int) NewState oldState:(int)OldState
{
    if (NewState == kNSSServer_Mode_Basic)
    {
        m_UIDSScenario = kUIDSScenario_SelfShare;
    }
    else if (NewState == kNSSServer_Mode_ConferenceControl)
    {
        m_UIDSScenario = kUIDSScenario_HostShare;
    }
}


- (void)orientationChanged:(NSNotification *)notification
{
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(deviceOrientation) || UIInterfaceOrientationIsPortrait(deviceOrientation))
    {
        if (UIInterfaceOrientationIsLandscape(deviceOrientation) && m_bLandscape)
            return;
        if (UIInterfaceOrientationIsPortrait(deviceOrientation) && !m_bLandscape)
            return;
        
        NSLog(@"orientation changed");
        CGSize imageSize = CGSizeZero;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            imageSize = [UIScreen mainScreen].bounds.size;

        }
        else
        {
            if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
                imageSize = [UIScreen mainScreen].bounds.size;
            } else {
                imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            }

        }


        if (UIInterfaceOrientationIsPortrait(deviceOrientation))
        {
            m_bLandscape = false;
        }
        else
        {
            m_bLandscape = true;
        }

        [m_pModelService.m_NSSserver ChangeVideoDimension:imageSize.width height:imageSize.height];
    }
    

    
}


- (NSArray*) GetPlaybackControllers
{
    return [m_pPMPlayer GetPlaybackControllers];
}
- (void) LockTab
{
    m_bTabLock = true;
}
- (void) UnlockTab
{
    m_bTabLock = false;
}

#pragma mark observers
- (void)PresentActions:(UIView*)currentView
{
    if (m_UIDSScenario == kUIDSScenario_NoShare)
        return;
    if (m_UIDSScenario == kUIDSScenario_HostShare)
    {
        [m_pModelService.m_NSSserver EnableBlankView:false];
        return;
    }
    if (m_UIDSScenario == kUIDSScenario_SelfShare)
    {
        // Start screen mirror
        BelongingsRecordApple* Record = ([GUIModelService defaultModelService]).m_AppSetting.m_ScreenShareServerRecord;
        if (!Record)
            return;
        // check connection
        if ([GUIModelService defaultModelService].m_NSSserver.Status != kNSSServer_In)
            return;
        if ([GUIModelService defaultModelService].m_NSSserver.ScreenMirrorStatus == kNSSServer_ScreenMirroring)
        {
            [m_pModelService.m_NSSserver EnableBlankView:false];
            return;
        }
        // Start screen mirror
        int hr = [[GUIModelService defaultModelService].m_NSSserver StartScreenMirror];
        
        if (hr != NSS_ErrorCode_Success)
        {
            NSString *ErrMsg = nil;
            
            switch (hr)
            {
                case NSS_ErrorCode_JoinerNotExist:
                case NSS_ErrorCode_PresenterNotExist:
                    ErrMsg = @"Error: Not login!";
                    break;
                case NSS_ErrorCode_OtherTaskInprogress:
                case NSS_ErrorCode_FeatureExist:
                case NSS_ErrorCode_PresenterExist:
                    ErrMsg = @"Error: Can not project now! System busy!";
                    break;
                case NSS_ErrorCode_FeatureNotSupport:
                case NSS_ErrorCode_ArgError:
                case NSS_ErrorCode_GenericError:
                default:
                    ErrMsg = @"Error: OtherError";
                    break;
            }
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ErrMsg
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showInView:currentView];	// show from our table view (pops up in the middle of the table)
            
        }
        else
            [m_pModelService.m_NSSserver EnableBlankView:false];

    }
   
}
- (void)WillAbsentActions
{
    if (m_UIDSScenario == kUIDSScenario_NoShare)
        return;
    if (m_UIDSScenario == kUIDSScenario_HostShare)
    {
        [m_pModelService.m_NSSserver EnableBlankView:true];
        return;
    }
    if (m_UIDSScenario == kUIDSScenario_SelfShare)
    {
        [m_pModelService.m_NSSserver EnableBlankView:true];
        return;
    }
}
- (void)AbsentActions
{
    if (m_UIDSScenario == kUIDSScenario_NoShare)
        return;
    if (m_UIDSScenario == kUIDSScenario_HostShare)
        return;
    if (m_UIDSScenario == kUIDSScenario_SelfShare)
    {
        [[GUIModelService defaultModelService].m_NSSserver StopScreenMirror];
        return;
    }

}

- (void)ViewPresentStateDidChange:(NSNotification*)changeNotification
{
    NSDictionary* dic = changeNotification.userInfo;
    int PresentState = [dic[@"PresentState"] integerValue];
    UIView* currentView = changeNotification.object;
    NSLog(@"Last present state %d; current present state %d", m_LastPresentState, PresentState);
    
    if ((m_LastPresentState == kNSSPresentState_Absent) && (PresentState == kNSSPresentState_Present))
    {
        // presentable view absent -> presentable view presented
        // presentSteps
        [self PresentActions:currentView];
     }
    
    if ((m_LastPresentState == kNSSPresentState_Present) && (PresentState == kNSSPresentState_WillAbsent))
    {
        // presentable view present -> presentable view will absent
        // presentSteps
        [self WillAbsentActions];
    }
    if ((m_LastPresentState == kNSSPresentState_WillAbsent) && (PresentState == kNSSPresentState_Present))
    {
        // presentable view absent -> presentable view presented
        // presentSteps
        [self PresentActions:currentView];
    }
    if ((m_LastPresentState == kNSSPresentState_WillAbsent) && (PresentState == kNSSPresentState_Absent))
    {
        // presentable view absent -> presentable view presented
        // presentSteps
        [self AbsentActions];
    }
    if ((m_LastPresentState == kNSSPresentState_Present) && (PresentState == kNSSPresentState_Absent))
    {
        [self WillAbsentActions];
        [self AbsentActions];

    }

    m_LastPresentState = PresentState;
}


#pragma mark tab bar controller

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (m_bTabLock)
        return false;
    NSInteger index = [[m_TabBarController viewControllers] indexOfObject:viewController];
    return true;
    
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger index = [[m_TabBarController viewControllers] indexOfObject:viewController];
    if (index == 2)
    {
        // web browser
        if (!m_WebViewController)
        {
            m_WebViewController = [[WebBrowserViewController alloc] init];
            UINavigationController* nac = (UINavigationController *)viewController;
            [nac pushViewController:m_WebViewController animated:true];
        }
    }
}

#pragma mark PMPBCGUIDelegateApple

-(void) alertConnectionLost
{
    /* Display the error. */
    NSString* alterMessage= @"Lost connection";;
    if (alterMessage)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil	message:alterMessage delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }

}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    NSLog(@"touchesBegin %p",touch);
    if(touch.tapCount==2)
    {
        [m_pPMPlayer StopService];
        [m_pPMPlayer StartService];
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    NSLog(@"touchesBegin %p",touch);
}


@end

