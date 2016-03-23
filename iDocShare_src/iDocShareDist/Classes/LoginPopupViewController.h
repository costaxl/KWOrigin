//
//  LoginPopupViewController
//

#import <UIKit/UIKit.h>
@protocol LoginPopupViewControllerDelegate <NSObject>
enum ActionResult
{
    kAction_Success,
    kAction_Failed,
    kAction_Canceled
};
-(void) actionDone:(enum ActionResult)ActionResult errorCode:(int)ErrorCode;
@end

@interface LoginPopupViewController : UIViewController <UITextFieldDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UITextField *m_txtServerName;
@property (retain, nonatomic) IBOutlet UITextField *m_txtLoginCode;
@property (nonatomic, retain) id<LoginPopupViewControllerDelegate> delegate;

- (IBAction)selectServerName:(id)sender;
- (IBAction)loginServer:(id)sender;
- (IBAction)cancelLogin:(id)sender;
- (IBAction)loginCodePressReturn:(id)sender;

@end
