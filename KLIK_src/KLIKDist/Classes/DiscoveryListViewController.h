//
//  DiscoveryListViewController.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/15.
//
//

#import <UIKit/UIKit.h>
#import "BelongingsManagerApple.h"
#import "ServerDetialViewController.h"
#import "SelectServerDetialViewController.h"
@interface DiscoveryListViewController : UITableViewController <ServerDetialViewControllerDelegate,SelectServerDetialViewControllerDelegate, UIAlertViewDelegate>
{
     NSUInteger selectedIndex;
}
@property (nonatomic,strong) NSMutableArray *manualRecords;
@property (nonatomic,strong) NSMutableArray *serverListRecords;

- (void)deleteRecord:(BelongingsRecordApple *)Record;

- (void)addBelongingRecord:(BelongingsRecordApple *)record;
- (void)delBelongingRecord:(BelongingsRecordApple *)record;

- (BelongingsRecordApple *)IsBelongingRecordExist:(BelongingsRecordApple *)record;
@end
