//
//  ServerDetialViewController.m
//  PMPlayer
//
//  Created by James_hsieh on 12/8/17.
//
//

#import "ServerDetialViewController.h"
#import "BelongingsManagerApple.h"

@interface ServerDetialViewController ()

@end


@implementation ServerDetialViewController
{
   NSString*feature;
}
@synthesize delegate;
@synthesize nameTextField;
@synthesize addressTextField;
@synthesize passwordTextField;
@synthesize featureLabel;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setAddressTextField:nil];
    [self setPasswordTextField:nil];
    [self setFeatureLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.section ==0)
        [self.nameTextField becomeFirstResponder];
}


- (IBAction)cancel:(id)sender {
    [self.delegate serverDetialViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    
    if([self.nameTextField.text isEqualToString:@""])
    {
        self.nameTextField.placeholder =  @"Please Enter the Server Name!";
        [self.nameTextField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        NSLog(@"Please Enter the Server Name!");
        return;
    }

    if(([self ipValidationUsingRegex:self.addressTextField.text] == NO) )
    {
        self.addressTextField.placeholder =  @"Please Enter the correct IP Address";
        self.addressTextField.text = @"";
        [self.addressTextField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        NSLog(@"Please Enter the correct IP Address");
        return;
    }
        BelongingsRecordApple *server =[[BelongingsRecordApple alloc] init];
        server.m_Name = self.nameTextField.text;
        server.m_Address =self.addressTextField.text;
        server.m_Password = self.passwordTextField.text;
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
        [self.delegate serverDetialViewControllerDidDone:self didAddServer:server];

}
- (void)dealloc {
    [nameTextField release];
    [addressTextField release];
    [passwordTextField release];
    [featureLabel release];
    [super dealloc];
}


-(id)initWithCoder:(NSCoder*)aDecoder
{
    if((self =[super initWithCoder:aDecoder]))
    {
        NSLog(@"init ServerDetailsViewController");
        feature =@"Cam";
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
    }
}


- (void)featurePickerViewController:(FeaturePickerViewController *)controller didSelectFeature:(NSString *)theFeature
{
    feature = theFeature;
    self.featureLabel.text = feature;
    [self.navigationController popViewControllerAnimated:YES];
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
