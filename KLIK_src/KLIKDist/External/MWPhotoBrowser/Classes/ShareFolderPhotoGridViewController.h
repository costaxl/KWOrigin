//
//  ShareFolderPhotoGridViewController.h
//

#import <UIKit/UIKit.h>
#import "MWGridViewController.h"

@interface ShareFolderPhotoGridViewController : MWGridViewController <UIActionSheetDelegate>
{
}
-(void)BatchLoadThumbnailTask;
-(NSString*) GetTitle;
@end
