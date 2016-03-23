//
//  PersonalPhotoGridViewController.h
//

#import <UIKit/UIKit.h>
#import "MWGridViewController.h"

@interface PersonalPhotoGridViewController : MWGridViewController <UIActionSheetDelegate>
{
}
-(void)BatchLoadThumbnailTask;
-(NSString*) GetTitle;
@end
