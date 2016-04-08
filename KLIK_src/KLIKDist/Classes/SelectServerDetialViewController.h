//
//  SelectServerDetialViewController.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/22.
//
//

#import <UIKit/UIKit.h>
#import "FeaturePickerViewController.h"
#import "BelongingsManagerApple.h"
@class SelectServerDetialViewController;
@class BelongingsRecordApple;
@protocol SelectServerDetialViewControllerDelegate <NSObject>
- (void)selectServerDetialViewControllerDidDone:(SelectServerDetialViewController *)controller didUpdateServer:(BelongingsRecordApple *)server;
@end

@interface SelectServerDetialViewController : UITableViewController <FeaturePickerViewControllerDelegate>
@property (nonatomic,retain) id <SelectServerDetialViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UILabel *serverNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel;
@property (nonatomic, strong) BelongingsRecordApple* server;
- (IBAction)done:(id)sender;
- (IBAction)returnButPressed :(id)sender;
@end

@interface SelectServerDetialViewController (Private)

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;

@end