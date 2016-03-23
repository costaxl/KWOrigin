//
//  SelectServerDetialViewController.m
//  PMPlayer
//
//  Created by James_hsieh on 12/8/22.
//
//

#import "SelectServerDetialViewController.h"


@interface SelectServerDetialViewController ()

@end

@implementation SelectServerDetialViewController
{
    NSString*feature;
}
@synthesize server;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateInterface];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setAddressTextField:nil];
    [self setPasswordTextField:nil];
    [self setFeatureLabel:nil];
    [self setServerNameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(id)initWithCoder:(NSCoder*)aDecoder
{
    if((self =[super initWithCoder:aDecoder]))
    {
        NSLog(@"init ServerDetailsViewController");
        feature =@"Desktop";
    }
    return self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PickFeature"])
    {
        FeaturePickerViewController *featurePickerViewController =
        segue.destinationViewController;
        featurePickerViewController.delegate = self;
        featurePickerViewController.feature = feature;
        
        //featurePickerViewController.supportfeature = server.m_SupportedFeatures;
        featurePickerViewController.supportfeature = 7; //all features
    }
}


- (void)featurePickerViewController:(FeaturePickerViewController *)controller didSelectFeature:(NSString *)theFeature
{
    feature = theFeature;
    self.featureLabel.text = feature;
    
    if ([self.featureLabel.text isEqualToString:@"Desktop"])
    {
        server.m_WantedFeature = kFeatureTypeDesktopFlag;
    }
    else if ([self.featureLabel.text isEqualToString:@"Cam"])
    {
        server.m_WantedFeature = kFeatureTypeCamFlag;
    }
    else if ([self.featureLabel.text isEqualToString:@"PushCam"])
    {
        server.m_WantedFeature = kFeatureTypePushCamFlag;
    }
    else
    {
        //default
        server.m_WantedFeature = kFeatureTypeDesktopFlag;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateInterface
{
    self.serverNameLabel.text = self.server.m_Name;
    self.addressTextField.text = self.server.m_Address;
    self.passwordTextField.text = self.server.m_Password;
    
    if (self.server.m_WantedFeature == kFeatureTypeDesktopFlag)
    {
        self.featureLabel.text = @"Desktop";
        feature =@"Desktop";
    }
    else if (self.server.m_WantedFeature == kFeatureTypeCamFlag)
    {
        self.featureLabel.text = @"Cam";
        feature =@"Cam";
    }
    else if (self.server.m_WantedFeature == kFeatureTypePushCamFlag)
    {
        self.featureLabel.text = @"PushCam";
        feature =@"PushCam";
    }

}

- (IBAction)done:(id)sender {
    
    
    if ([self.server.jid isEqualToString:@""])
    {
     if(([self ipValidationUsingRegex:self.addressTextField.text] == NO) )
     {
        self.addressTextField.placeholder =  @"Please Enter the correct IP Address";
        self.addressTextField.text = @"";
        [self.addressTextField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        NSLog(@"Please Enter the correct IP Address");
        return;
     }
    }
    
    
    self.server.m_Name = self.serverNameLabel.text;
    self.server.m_Address = self.addressTextField.text;
    self.server.m_Password = self.passwordTextField.text;
    
    if ([self.featureLabel.text isEqualToString:@"Desktop"])
    {
        server.m_WantedFeature = kFeatureTypeDesktopFlag;
    }
    else if ([self.featureLabel.text isEqualToString:@"Cam"])
    {
        server.m_WantedFeature = kFeatureTypeCamFlag;
    }
    else if ([self.featureLabel.text isEqualToString:@"PushCam"])
    {
        server.m_WantedFeature = kFeatureTypePushCamFlag;
    }
    else
    {
        //default
        server.m_WantedFeature = kFeatureTypeDesktopFlag;
    }
    
   [self.delegate selectServerDetialViewControllerDidDone:self didUpdateServer:server];
}

- (IBAction)returnButPressed:(id)sender
{
    [sender resignFirstResponder];
}

-(BOOL)ipValidationUsingRegex:(NSString *)ipAddressStr
{
    NSString *ipValidStr = ipAddressStr;
    NSString *ipRegEx =
    @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:ipValidStr];
    
    NSLog(@"myStringMatchesRegEx = %d ",myStringMatchesRegEx);
    return myStringMatchesRegEx;
}

@end
