//
//  ServerDetialViewController.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/17.
//
//

#import <UIKit/UIKit.h>
#import "FeaturePickerViewController.h"
@class ServerDetialViewController;
@class BelongingsRecordApple;
@protocol ServerDetialViewControllerDelegate <NSObject>
- (void)serverDetialViewControllerDidCancel:(ServerDetialViewController *)controller;
- (void)serverDetialViewControllerDidDone:(ServerDetialViewController *)controller didAddServer:(BelongingsRecordApple *)server;
@end

@interface ServerDetialViewController : UITableViewController <FeaturePickerViewControllerDelegate>
@property (nonatomic,retain) id <ServerDetialViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)returnButPressed :(id)sender;
@end
