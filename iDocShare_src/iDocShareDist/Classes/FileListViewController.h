//
//  FIleListViewController.h

#import <UIKit/UIKit.h>



@interface FIleListViewController : UITableViewController
{
    NSURL *fileURL;
}
@property(nonatomic,retain) NSURL *fileURL;
@property (nonatomic, copy) NSArray *FileNames;
@property (retain, nonatomic) IBOutlet UITableView *FileListTableView;

-(void) actionDone:(enum ActionResult)ActionResult errorCode:(int)ErrorCode;

@end
