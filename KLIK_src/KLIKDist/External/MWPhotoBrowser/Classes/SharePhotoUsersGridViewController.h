//
//  SharePhotoUsersGridViewController.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "MWGridViewController.h"


@interface SharePhotoUsersGridViewController : MWGridViewController <UIActionSheetDelegate>
{
}

@property (nonatomic, assign) MWPhotoBrowser *browser;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint initialContentOffset;
@property (nonatomic) BOOL m_bBatchLoadThumbnails;
- (CGFloat)getGutter;
- (CGFloat)getMargin;
- (CGFloat)getColumns;

-(void)BatchLoadThumbnail:(UICollectionView *)collectionView;
-(void)BatchLoadThumbnailTask;
-(NSString*) GetTitle;
@end
