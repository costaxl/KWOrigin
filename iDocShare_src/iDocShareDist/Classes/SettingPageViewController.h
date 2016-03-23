//
//  SettingPageViewController.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/13.
//
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface SettingPageViewController : UITableViewController <UITextFieldDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UITextField *m_txtServerName;
@property (retain, nonatomic) IBOutlet UITextField *m_txtLoginCode;
@property (retain, nonatomic) IBOutlet UILabel *m_txtTestMsg;

@property (retain, nonatomic) IBOutlet UITextField *m_txtSSServerName;
@property (retain, nonatomic) IBOutlet UITextField *m_txtSSLoginCode;
@property (retain, nonatomic) IBOutlet UIButton *m_btnSSLogin;
@property (retain, nonatomic) IBOutlet UIButton *m_btnSSPlayControl;
@property (retain, nonatomic) IBOutlet UISwitch *m_DropBoxStatus;
@property (retain, nonatomic) IBOutlet UILabel *m_version;

- (IBAction)selectSSServer:(id)sender;
- (IBAction)loginSSServer:(id)sender;
- (IBAction)onbtnSSPlayControlDown:(id)sender;

- (IBAction)saveSetting:(id)sender;
- (IBAction)returnButPressed :(id)sender;
- (IBAction)selectFileServer:(id)sender;
- (IBAction)testFileServerConnection:(id)sender;
- (IBAction)DropBoxServerConnection:(id)sender;
- (BOOL)isDropboxLinked;
@end
