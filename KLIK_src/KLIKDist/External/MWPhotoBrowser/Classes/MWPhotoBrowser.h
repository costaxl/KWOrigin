//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MWPhoto.h"
#import "MWPhotoProtocol.h"
#import "MWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif

@class MWPhotoBrowser;

@protocol MWPhotoBrowserDelegate <NSObject>

enum ActionType
{
    kAction_Non,
    kAction_Share,
    kAction_NotShare,
    kAction_Download,
    kAction_Delete,
    kAction_DBDownload,
    kAction_PCDownload
};

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
// with section
- (NSInteger)numberOfSectionsInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (NSUInteger)numberOfPhotosInSection:(NSInteger)section inPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index section:(NSInteger)section;

@optional

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;

// batch thumbnail loading
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser prepareThumbnails:(NSArray*)indexes;
- (BOOL)isThumbnailsLoading:(MWPhotoBrowser *)photoBrowser;
- (BOOL)prepareThumbnailsLoading:(MWPhotoBrowser *)photoBrowser;

// with section
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index section:(NSInteger)section;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForSection:(NSInteger)section;

// ui related
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser hideBottomBar:(BOOL)bHide;
// if photo, target=0 else if thumbnail, target=1
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser layoutNavigatorItems:(UINavigationItem*)Items contentType:(NSInteger) target;
// photo actions
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser action:(enum ActionType)Action with:(id)Parameters;

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didSelectPhotoAtIndex:(NSInteger)index;
- (void)willShowGrid;
- (void)willHideGrid;
- (void)photoBrowserShowView;
- (void)photoBrowserWillHideView;



@end

@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet id<MWPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableGrid;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL startOnGrid;

@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;

@property (nonatomic) BOOL enableBatchLoadThumbnails;

// Init
- (id)initWithPhotos:(NSArray *)photosArray  __attribute__((deprecated("Use initWithDelegate: instead"))); // Depreciated
- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate;
- (id)initWithDelegateAndGridController:(id <MWPhotoBrowserDelegate>)delegate gridController:(Class)ControllerClass;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;
- (void)setInitialPageIndex:(NSUInteger)index  __attribute__((deprecated("Use setCurrentPhotoIndex: instead"))); // Depreciated

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
