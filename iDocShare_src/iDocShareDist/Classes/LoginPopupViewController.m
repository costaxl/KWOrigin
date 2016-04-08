//
//  LoginPopupViewController.m
//

#import "LoginPopupViewController.h"
#import "ActionSheetPicker.h"
#import "ActionSheetPickerCustomPickerDelegate.h"
#import "GUIModelService.h"

@interface LoginPopupViewController ()
{
}
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,copy) BelongingsRecordApple* m_SSServerRecord;

@end

@implementation LoginPopupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = nil;
        self.selectedIndex = 0;
        self.m_SSServerRecord = nil;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // use toolbar as background because its pretty in iOS7
//    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 44, 200, 106)];
//    [self.view addSubview:toolbarBackground];
//    [self.view sendSubviewToBack:toolbarBackground];
    // set size
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_m_txtServerName release];
    [_m_txtLoginCode release];

    [super dealloc];
}
- (IBAction)selectServerName:(id)sender
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

    [ActionSheetStringPicker showPickerWithTitle:@"Select a Device" rows:deviceNames initialSelection:self.selectedIndex doneBlock:done cancelBlock:cancel origin:self.view];

}
- (IBAction)loginServer:(id)sender
{
    NSString *ErrMsg = nil;
    do
    {
        if (!self.m_SSServerRecord)
        {
            
            ErrMsg = @"Select a device to login first";
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ErrMsg
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                       destructiveButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showInView:self.view];

            break;
        }
        // login server
        self.m_SSServerRecord.m_Password = self.m_txtLoginCode.text;
        PMPlayer_Error result = [[GUIModelService defaultModelService].m_NSSserver Login:self.m_SSServerRecord];
        
        //keep recorder in setting
        if (result==0)
            ([GUIModelService defaultModelService]).m_AppSetting.m_ScreenShareServerRecord = self.m_SSServerRecord;
        // send event to delegate
        if (self.delegate)
        {
            if (result==0)
                [self.delegate actionDone:kAction_Success errorCode:0];
            else
                [self.delegate actionDone:kAction_Failed errorCode:result];
        }

    }while(false);
    
}
- (IBAction)cancelLogin:(id)sender
{
    // send event to delegate
    if (self.delegate)
    {
        [self.delegate actionDone:kAction_Canceled errorCode:0];
    }

}

- (IBAction)loginCodePressReturn:(id)sender
{
    [sender resignFirstResponder];

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}


@end
