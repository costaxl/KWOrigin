//
//  SettingPageViewController.m
//  PMPlayer
//
//  Created by James_hsieh on 12/8/13.
//
//

#import "SettingPageViewController.h"

#import "ActionSheetPicker.h"
#import "ActionSheetPickerCustomPickerDelegate.h"
#import "GUIModelService.h"
#import "ConfigurationDefs.h"


@interface SettingPageViewController ()
{
    dispatch_semaphore_t m_CallSemaphore;
    int m_WorkingErrorCode;
    
}
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,assign) NSInteger selectedSSIndex;
@property (nonatomic,copy) BelongingsRecordApple* m_FileServerRecord;
@property (nonatomic,copy) BelongingsRecordApple* m_SSServerRecord;

@end

static NSUInteger const kDBSignInAlertViewTag = 1;
static NSUInteger const kDBSignOutAlertViewTag = 3;

@implementation SettingPageViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedIndex = 0;
        self.selectedSSIndex = 0;
        m_CallSemaphore = dispatch_semaphore_create(0);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // add property observer
    [[GUIModelService defaultModelService].m_NSSserver addObserver:self forKeyPath: @"Status" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: NULL];
    [[GUIModelService defaultModelService].m_NSSserver addObserver:self forKeyPath: @"ScreenMirrorStatus" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: NULL];
    [[GUIModelService defaultModelService].m_NSSserver addObserver:self forKeyPath: @"m_Mode" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: NULL];

    // reflect the status of login and screen mirror
    if ([GUIModelService defaultModelService].m_NSSserver.Status == kNSSServer_Out)
    {
        self.m_btnSSLogin.enabled  = YES;
        [self.m_btnSSLogin setTitle:@"Login" forState:UIControlStateNormal];
    }
    else if ([GUIModelService defaultModelService].m_NSSserver.Status == kNSSServer_In)
    {
        self.m_btnSSLogin.enabled  = YES;
        [self.m_btnSSLogin setTitle:@"Logout" forState:UIControlStateNormal];
    }
    else
    {
        self.m_btnSSLogin.enabled  = NO;
    }
    
    if ([GUIModelService defaultModelService].m_NSSserver.ScreenMirrorStatus == kNSSServer_ScreenMirroring)
    {
        self.m_btnSSPlayControl.enabled  = YES;
        self.m_btnSSPlayControl.imageView.image = [[UIImage imageNamed:@"PlayControl_Stop_50.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else if (([GUIModelService defaultModelService].m_NSSserver.ScreenMirrorStatus == kNSSServer_ScreenMirrorNone) && ([GUIModelService defaultModelService].m_NSSserver.m_Mode == kNSSServer_Mode_Basic))
    {
        self.m_btnSSPlayControl.enabled  = YES;
        self.m_btnSSPlayControl.imageView.image = [[UIImage imageNamed:@"PlayControl_Play_50.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else
    {
        self.m_btnSSPlayControl.enabled  = NO;
    }
    if ([self isDropboxLinked]) {
        [self.m_DropBoxStatus setOn:YES];
    }
    else
    {
        [self.m_DropBoxStatus setOn:NO];
    }
    [self.m_DropBoxStatus addTarget:self action:@selector(DropBoxServerConnection:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *version = [[NSString alloc] init];
    version = [[[[version stringByAppendingString:appVersion] stringByAppendingString:@"("] stringByAppendingString:buildNumber] stringByAppendingString:@")"];
    self.m_version.text = version;

}

-(void)viewWillAppear:(BOOL)animated
{
    if (([GUIModelService defaultModelService]).m_AppSetting.m_FileServerRecord)
    {
        self.m_FileServerRecord = ([GUIModelService defaultModelService]).m_AppSetting.m_FileServerRecord;
        self.m_txtServerName.text = self.m_FileServerRecord.m_Name;
        self.m_txtLoginCode.text = self.m_FileServerRecord.m_Password;
    }
    
    if (([GUIModelService defaultModelService]).m_AppSetting.m_ScreenShareServerRecord)
    {
        self.m_SSServerRecord = ([GUIModelService defaultModelService]).m_AppSetting.m_ScreenShareServerRecord;
        self.m_txtSSServerName.text = self.m_SSServerRecord.m_Name;
        self.m_txtSSLoginCode.text = self.m_SSServerRecord.m_Password;
    }
    if ([self isDropboxLinked]) {
        [self.m_DropBoxStatus setOn:YES];
    }
    else
    {
        [self.m_DropBoxStatus setOn:NO];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // send the state - presentable view absent
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Absent];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:self.view userInfo:dic];
    
}

- (void)viewDidUnload
{
    // remote property observer
    [[GUIModelService defaultModelService].m_NSSserver removeObserver:self forKeyPath: @"Status"];
    [[GUIModelService defaultModelService].m_NSSserver removeObserver:self forKeyPath: @"ScreenMirrorStatus"];
    [[GUIModelService defaultModelService].m_NSSserver removeObserver:self forKeyPath: @"m_Mode"];
   
    [super viewDidUnload];
}

- (void)dealloc {
    [_m_txtServerName release];
    [_m_txtLoginCode release];
    dispatch_release(m_CallSemaphore);

    [_m_txtTestMsg release];

    [_m_txtSSLoginCode release];
    [_m_btnSSLogin release];
    [_m_btnSSPlayControl release];
    [super dealloc];
}

-(NSString *)filePath:(NSString*)name{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:name];
}


- (IBAction)selectSSServer:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        NSString* SelectServerName = selectedValue;
        
        NSRange rangeToSearch = NSMakeRange(0, [SelectServerName length]); // get a range without the space character
        NSRange rangeOfSecondToLastSpace = [SelectServerName rangeOfString:@" *" options:NSBackwardsSearch range:rangeToSearch];
        if (([SelectServerName length] - 2) == rangeOfSecondToLastSpace.location)
        {
            // show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error - compatibility"
                                                            message:@"New Version of firmware is avalible. Please update to the newest version or connect to another server."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            return;
        }
        
        self.m_txtSSServerName.text = selectedValue;
        self.selectedSSIndex = selectedIndex;
        GUIPeerManager* PeerManager = ([GUIModelService defaultModelService]).m_PeerManager;
        BelongingsRecordApple* Record = nil;
        for (NSUInteger i = 0; i < [PeerManager.m_DiscoverRecords count]; i++)
        {
            // find the server name which matched
            Record = [PeerManager.m_DiscoverRecords objectAtIndex:i];
            if ([Record.m_Name compare:selectedValue] == NSOrderedSame)
                break;
        }
        self.m_SSServerRecord = Record;
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    
    // get belonging records
    GUIPeerManager* PeerManager = ([GUIModelService defaultModelService]).m_PeerManager;
    NSMutableArray* deviceNames = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < [PeerManager.m_DiscoverRecords count]; i++)
    {
        BelongingsRecordApple* Record = [PeerManager.m_DiscoverRecords objectAtIndex:i];
        // filter out the device without file transport feature
        if (Record.m_SupportedFeatures & kFeatureTypePushDesktopFlag)
        {
            NSString* deviceName =nil;
            if (Record.m_Version == 1)
            {
                deviceName =[NSString stringWithFormat:@"%@ *", Record.m_Name];
            }
            else
            {
                deviceName =[NSString stringWithString:Record.m_Name];
            }
            [deviceNames addObject:deviceName];
        }
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Device" rows:deviceNames initialSelection:self.selectedSSIndex doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)loginSSServer:(id)sender
{
    if ([GUIModelService defaultModelService].m_NSSserver.Status == kNSSServer_In)
    {
        // logout procedure
        [[GUIModelService defaultModelService].m_NSSserver Logout];
        return;
    }
    assert([GUIModelService defaultModelService].m_NSSserver.Status == kNSSServer_Out);
    // login procedure
    NSString *ErrMsg = nil;
    
    do
    {
        if (!self.m_SSServerRecord)
        {
            
            ErrMsg = @"Select a device to login first!!!";
            break;
        }
        // login server
        self.m_SSServerRecord.m_Password = self.m_txtSSLoginCode.text;
        PMPlayer_Error result = [[GUIModelService defaultModelService].m_NSSserver Login:self.m_SSServerRecord];
        
        //keep recorder in setting
        if (result==0)
        {
            ([GUIModelService defaultModelService]).m_AppSetting.m_ScreenShareServerRecord = self.m_SSServerRecord;
            ErrMsg = @"Login successfully!!!";
            
        }
        else
        {
            ErrMsg = @"Login failed!!!";
        }
    }while(false);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ErrMsg
                                                             delegate:nil
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];


}

- (IBAction)onbtnSSPlayControlDown:(id)sender
{
    if ([GUIModelService defaultModelService].m_NSSserver.ScreenMirrorStatus == kNSSServer_ScreenMirroring)
    {
        // stop screen mirror
        [[GUIModelService defaultModelService].m_NSSserver StopScreenMirror];
        return;
    }
    assert([GUIModelService defaultModelService].m_NSSserver.ScreenMirrorStatus == kNSSServer_ScreenMirrorNone);
    assert([GUIModelService defaultModelService].m_NSSserver.m_Mode == kNSSServer_Mode_Basic);
    // start screen mirror
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
        [actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
    }
     [[GUIModelService defaultModelService].m_NSSserver EnableBlankView:true];
}

- (IBAction)saveSetting:(id)sender
{
    ([GUIModelService defaultModelService]).m_AppSetting.m_FileServerRecord = self.m_FileServerRecord;
    ([GUIModelService defaultModelService]).m_AppSetting.m_ScreenShareServerRecord = self.m_SSServerRecord;

    [[GUIModelService defaultModelService] SaveSetting];
    
    NSString *Msg = @"Setting Saved!!!";

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:Msg
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];

}

- (IBAction)returnButPressed:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)selectFileServer:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        self.m_txtServerName.text = selectedValue;
        self.selectedIndex = selectedIndex;
        GUIPeerManager* PeerManager = ([GUIModelService defaultModelService]).m_PeerManager;
        BelongingsRecordApple* Record = nil;
        for (NSUInteger i = 0; i < [PeerManager.m_DiscoverRecords count]; i++)
        {
            // find the server name which matched
            Record = [PeerManager.m_DiscoverRecords objectAtIndex:i];
            if ([Record.m_Name compare:selectedValue] == NSOrderedSame)
                break;
        }
        self.m_FileServerRecord = Record;
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    
    // get belonging records
    GUIPeerManager* PeerManager = ([GUIModelService defaultModelService]).m_PeerManager;
    NSMutableArray* deviceNames = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < [PeerManager.m_DiscoverRecords count]; i++)
    {
        BelongingsRecordApple* Record = [PeerManager.m_DiscoverRecords objectAtIndex:i];
        // filter out the device without file transport feature
        if (Record.m_SupportedFeatures & kFeatureTypeFileTransporterFlag)
        {
            NSString* deviceName = [NSString stringWithString:Record.m_Name];
            [deviceNames addObject:deviceName];
        }
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a FileShare Server" rows:deviceNames initialSelection:self.selectedIndex doneBlock:done cancelBlock:cancel origin:sender];
}
#define PMPFEATURE_FileTransporter  (0x00000001 << 8)

- (IBAction)testFileServerConnection:(id)sender
{
    NSString *ErrMsg = nil;
    do
    {
        if (!self.m_FileServerRecord)
        {
            
            ErrMsg = @"Select a FileShare server first!!!";
            break;
        }
        // login server
        m_WorkingErrorCode = 0;
        self.m_FileServerRecord.m_WantedFeature = PMPFEATURE_FileTransporter;
        self.m_FileServerRecord.m_Password = self.m_txtLoginCode.text;
        
        PMPlayer_Error noerr = [[GUIModelService defaultModelService].m_FSServer Login:self.m_FileServerRecord];
        
        switch (noerr)
        {
            case kPMSError_NoError:
                ErrMsg = @"Connect to FileShare server successfully!!!";
                break;
            case kPMSError_AuthenticationFailed:
                ErrMsg = @"Error: AuthenticationFailed";
                break;
            case kPMSError_Command_HandlerNotFound:
                ErrMsg = @"Error: Command_HandlerNotFound";
                break;
            case kPMSError_Command_ParseError:
                ErrMsg = @"Error: Command_ParseError";
                break;
            case kPMSError_FeatureNotSupport:
                ErrMsg = @"Error: FeatureNotSupport";
                break;
            case kPMSError_PeerNotAccept:
                ErrMsg = @"Connection already occupied";
                break;
            case kPMSError_PeerUnreachable:
                ErrMsg = @"Error: Can not find FileShare server";
                break;
            case kPMSError_OtherError:
            default:
                ErrMsg = @"Error: OtherError";
                break;
        }
        
        // disconnect
        if (noerr == kPMSError_NoError)
            [[GUIModelService defaultModelService].m_FSServer Logout];

    }while(false);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ErrMsg
                                                             delegate:nil
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)


}

- (IBAction)DropBoxServerConnection:(id)sender
{
    UISwitch *b_DropBoxStatus = (UISwitch *)sender;
    if ([b_DropBoxStatus isOn])
    {
        [[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        if ([self isDropboxLinked]) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"Logout of Dropbox", @"DropboxBrowser: Alert Title")
                                      message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to logout of Dropbox and revoke Dropbox access for %@?", @"DropboxBrowser: Alert Message. ...revoke Dropbox access for 'APP NAME'"), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]]
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button")
                                      otherButtonTitles:NSLocalizedString(@"Logout", @"DropboxBrowser: Alert Button"), nil];
            [alertView show];
            alertView.tag = kDBSignOutAlertViewTag;
        }
    }
}
- (BOOL)isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kDBSignInAlertViewTag) {
        switch (buttonIndex) {
            case 0:
                [self.m_DropBoxStatus setOn:NO];
                break;
            case 1:
                [[DBSession sharedSession] linkFromController:self];
                break;
            default:
                [self.m_DropBoxStatus setOn:NO];
                break;
        }
    } else if (alertView.tag == kDBSignOutAlertViewTag) {
        switch (buttonIndex) {
            case 0:
                [self.m_DropBoxStatus setOn:YES];
                break;
            case 1:
                [[DBSession sharedSession] unlinkAll];
                break;
            default:
                [self.m_DropBoxStatus setOn:YES];
                break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [GUIModelService defaultModelService].m_NSSserver)
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
    NSLog(@"New Screen mirror state:%d, old state:%d", NewState, OldState);
    if (NewState == kNSSServer_ScreenMirroring)
    {
        self.m_btnSSPlayControl.enabled  = YES;
        self.m_btnSSPlayControl.imageView.image = [[UIImage imageNamed:@"PlayControl_Stop_50.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.m_btnSSLogin.enabled  = NO;

    }
    else if (NewState == kNSSServer_ScreenMirrorNone)
    {
        if ([GUIModelService defaultModelService].m_NSSserver.m_Mode == kNSSServer_Mode_Basic)
        {
            self.m_btnSSPlayControl.enabled  = YES;
            self.m_btnSSPlayControl.imageView.image = [[UIImage imageNamed:@"PlayControl_Play_50.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        self.m_btnSSLogin.enabled  = YES;

    }
    else
    {
        self.m_btnSSPlayControl.enabled  = NO;
        self.m_btnSSLogin.enabled  = NO;
    }
}
-(void) OnModeStatusChange:(int) NewState oldState:(int)OldState
{
    if (NewState == kNSSServer_Mode_Basic)
    {
        self.m_btnSSPlayControl.enabled  = YES;
    }
    else if (NewState == kNSSServer_Mode_ConferenceControl)
    {
       self.m_btnSSPlayControl.enabled  = NO;
    }
}

-(void) OnConnectionStatusChange:(int) NewState oldState:(int)OldState
{
    // reflect the status of login and screen mirror
    NSLog(@"New login state:%d", NewState);
    if (NewState == kNSSServer_Out)
    {
        self.m_btnSSLogin.enabled  = YES;
        [self.m_btnSSLogin setTitle:@"Login" forState:UIControlStateNormal];
        self.m_btnSSPlayControl.enabled  = NO;
    }
    else if (NewState == kNSSServer_In)
    {
        self.m_btnSSLogin.enabled  = YES;
        [self.m_btnSSLogin setTitle:@"Logout" forState:UIControlStateNormal];
        self.m_btnSSPlayControl.enabled  = YES;
    }
    else
    {
        self.m_btnSSLogin.enabled  = NO;
        self.m_btnSSPlayControl.enabled  = NO;
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}


@end
