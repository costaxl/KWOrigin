//
//  MWGridViewController.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface MWGridViewController : UICollectionViewController
{
}

@property (nonatomic, assign) MWPhotoBrowser *browser;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint initialContentOffset;
@property (nonatomic) BOOL m_bBatchLoadThumbnails;
@property (nonatomic) BOOL isModal;

- (CGFloat)getGutter;
- (CGFloat)getMargin;
- (CGFloat)getColumns;

-(void)BatchLoadThumbnail:(UICollectionView *)collectionView;
-(void)BatchLoadThumbnailTask;
-(NSString*) GetTitle;
-(void) reloadData;

@end
