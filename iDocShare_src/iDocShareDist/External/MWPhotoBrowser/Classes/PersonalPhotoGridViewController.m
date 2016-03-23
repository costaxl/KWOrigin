//
//  PersonalPhotoGridViewController.m
//

#import "PersonalPhotoGridViewController.h"
#import "MWGridCell.h"
#import "MWPhotoBrowserPrivate.h"
#import "MWCommon.h"
#import <objc/runtime.h>


@interface PersonalPhotoGridViewController ()
{
    UIToolbar *m_ToolBar;
	NSTimer *m_ControlVisibilityTimer;
	UIBarButtonItem *m_PreviousButton, *m_NextButton, *m_ActionButton, *m_DoneButton;
    NSMutableArray* m_SizesOfSections;
    UIBarButtonItem* m_SelectModeButton, *m_UploadButton, *m_SelectionModeReturn;
    UIBarButtonItem* m_ShareActionButton, *m_DownloadActionButton, *m_DeleteActionButton;
    bool m_bSelection;
}
-(NSInteger) GetAbsoluteIndex:(NSInteger)index section:(NSInteger)Section;
- (void)enterSelectionMode;
- (void)leaveSelectionMode;
- (void)uploadAction;

- (void)ShareAction;
- (void)DownloadAction;
- (void)DeleteAction;
@end

@implementation PersonalPhotoGridViewController

- (id)init {
    if ((self = [super init]))
    {
        m_bSelection = false;
    }
    return self;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    // add header view
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    // prepare action buttons
    NSString *selectImagePathFormat;
    NSString *uploadImagePathFormat;
    NSString *selectModeReturnImagePathFormat;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        //arrowPathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemArrowOutline%@.png";
        selectImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemSelect.png";
        uploadImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemUpload.png";
        selectModeReturnImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemReturn.png";
    }
    else
    {
        //arrowPathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemArrow%@.png";
        selectImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemSelect.png";
        uploadImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemUpload.png";
        selectModeReturnImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemReturn.png";
    }
    UIImage* uploadImage = [UIImage imageNamed:uploadImagePathFormat];
    m_UploadButton = [[UIBarButtonItem alloc] initWithImage:uploadImage style:UIBarButtonItemStylePlain target:self action:@selector(uploadAction)];
    UIImage* selectImage = [UIImage imageNamed:selectImagePathFormat];
    m_SelectModeButton = [[UIBarButtonItem alloc] initWithImage:selectImage style:UIBarButtonItemStylePlain target:self action:@selector(enterSelectionMode)];
    UIImage* selectReturnImage = [UIImage imageNamed:selectModeReturnImagePathFormat];
    //m_SelectionModeReturn = [[UIBarButtonItem alloc] initWithImage:selectReturnImage style:UIBarButtonItemStylePlain target:self action:@selector(leaveSelectionMode)];
    m_SelectionModeReturn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(leaveSelectionMode)];

    // tool bar item
    NSString *shareImagePathFormat;
    NSString *downloadImagePathFormat;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        //arrowPathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemArrowOutline%@.png";
        shareImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemShare.png";
        downloadImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemDownload.png";
    }
    else
    {
        //arrowPathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemArrow%@.png";
        shareImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemShare.png";
        downloadImagePathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemDownload.png";
    }
    UIImage* shareImage = [UIImage imageNamed:shareImagePathFormat];
    m_ShareActionButton = [[UIBarButtonItem alloc] initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(ShareAction)];
    UIImage* downloadImage = [UIImage imageNamed:downloadImagePathFormat];
    m_DownloadActionButton = [[UIBarButtonItem alloc] initWithImage:downloadImage style:UIBarButtonItemStylePlain target:self action:@selector(DownloadAction)];
    m_DeleteActionButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(DeleteAction)];
    
    m_DoneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    //_doneButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(doneButtonPressed:)];
    // Set appearance
    if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
        [m_DoneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [m_DoneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        [m_DoneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [m_DoneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
        [m_DoneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
        [m_DoneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
    }

 
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Cancel outstanding loading
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    //[super viewWillLayoutSubviews];
    Class granny = [[self superclass] superclass];
    IMP grannyImp = class_getMethodImplementation(granny, _cmd);
    grannyImp(self, _cmd);

    [self performLayout];
}

- (void)viewDidLayoutSubviews
{
    Class granny = [[self superclass] superclass];
    IMP grannyImp = class_getMethodImplementation(granny, _cmd);
    grannyImp(self, _cmd);
    //[super.super viewDidLayoutSubviews];
    // Move to previous content offset
//    if (self.initialContentOffset.y != CGFLOAT_MAX)
//    {
//        self.collectionView.contentOffset = self.initialContentOffset;
//    }
//    CGPoint currentContentOffset = self.collectionView.contentOffset;
//    
//    // Get scroll position to have the current photo on screen
//    if (self.browser.numberOfPhotos > 0)
//    {
//        NSIndexPath *currentPhotoIndexPath = [NSIndexPath indexPathForItem:self.browser.currentIndex inSection:0];
//        //[self.collectionView scrollToItemAtIndexPath:currentPhotoIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//    }
//    CGPoint offsetToShowCurrent = self.collectionView.contentOffset;
//    
//    // Only commit to using the scrolled position if it differs from the initial content offset
//    if (!CGPointEqualToPoint(offsetToShowCurrent, currentContentOffset)) {
//        // Use offset to show current
//        self.collectionView.contentOffset = offsetToShowCurrent;
//    } else {
//        // Stick with initial
//        self.collectionView.contentOffset = currentContentOffset;
//    }
//    

}

- (void)performLayout
{
    

    UINavigationBar *navBar = self.navigationController.navigationBar;
    self.browser.navigationItem.leftItemsSupplementBackButton = YES;
    NSArray* ButtonArray;
    if (!m_bSelection)
    {
        ButtonArray = [[NSArray alloc] initWithObjects:/*m_UploadButton, */m_SelectModeButton, nil];
        [self.navigationController setToolbarHidden:YES animated:YES];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
        {
            //[self.navigationController.tabBarController.tabBar setTranslucent:NO];
            [self.navigationController.tabBarController.tabBar setHidden:NO];
        }
        else
        {
            [self showTabBar:self.navigationController.tabBarController];
        }
    }
    else
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
        {
            
            //[self.navigationController.tabBarController.tabBar setTranslucent:YES];
            [self.navigationController.tabBarController.tabBar setHidden:YES];
        }
        else
        {
            [self hideTabBar:self.navigationController.tabBarController];

        }
        

        // test tool bar
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

        NSArray *items = [NSArray arrayWithObjects: flexSpace, m_ShareActionButton, flexSpace/*, m_DownloadActionButton, flexSpace*/, m_DeleteActionButton, flexSpace, nil];
        [self.browser setToolbarItems:items animated:NO];
        CGRect frame = [self.browser frameForToolbarAtOrientation:self.browser.interfaceOrientation];
        [self.navigationController.toolbar setFrame:frame];
        [self.navigationController setToolbarHidden:NO animated:YES];

        
        ButtonArray = [[NSArray alloc] initWithObjects:m_SelectionModeReturn, nil];
      
    }
        
    self.browser.navigationItem.RightBarButtonItems = ButtonArray;

    if (self.isModal)
    {
        if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:layoutNavigatorItems:contentType:)])
        {
            [self.browser.delegate photoBrowser:self.browser layoutNavigatorItems:self.browser.navigationItem contentType:1];
        }
        else
        {
            self.browser.navigationItem.leftBarButtonItem = m_DoneButton;
        }
    }

    CGFloat yAdjust = 0;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (SYSTEM_VERSION_LESS_THAN(@"7") && !self.browser.wantsFullScreenLayout) yAdjust = -20;
#endif
    self.collectionView.contentInset = UIEdgeInsetsMake(navBar.frame.origin.y + navBar.frame.size.height + [self getGutter] + yAdjust, 0, 0, 0);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Layout


#pragma mark - Collection View


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (m_SizesOfSections)
        m_SizesOfSections = nil;
    
    m_SizesOfSections = [[NSMutableArray alloc] init];
    
    int size = [self.browser numberOfSection];
    for (NSInteger i = 0; i < size; ++i)
    {
        [m_SizesOfSections addObject:[NSNull null]];
    }

    return size;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    NSInteger size = [self.browser numberOfPhotosInSection:section];
    [m_SizesOfSections replaceObjectAtIndex:section withObject:[NSNumber numberWithInt:size]];
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // per section
    MWGridCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[MWGridCell alloc] init];
    }
    id <MWPhoto> photo = [self.browser thumbPhotoAtIndex:indexPath.row section:indexPath.section];
    cell.photo = photo;
    cell.gridController = self;
    cell.selectionMode = self.selectionMode;
    NSInteger absIndex = [self GetAbsoluteIndex:indexPath.row section:indexPath.section];
    cell.isSelected = [self.browser photoIsSelectedAtIndex:absIndex];
    cell.index = absIndex;
    UIImage *img = [self.browser imageForPhoto:photo];
    if (img) {
        [cell displayImage];
    } else
    {
        if (!self.m_bBatchLoadThumbnails)
            [photo loadUnderlyingImageAndNotify];
        else
        {
            [self BatchLoadThumbnail:cv];
            
        }
    }
    return cell;
    
}
// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        UILabel *label=nil;
        if (reusableview==nil)
        {
            reusableview=[[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        }
        else
            label=(UILabel *)[reusableview viewWithTag:100];
        
        if (label==nil)
        {
            label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            label.tag = 100;
            [reusableview addSubview:label];

        }
        
        NSString* SectionTitle = [self.browser titleOfSection:indexPath.section];
        label.text=SectionTitle;
        [label setTextColor:[UIColor blackColor]];
        return reusableview;
    }
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collecView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    return CGSizeMake(flowLayout.itemSize.width, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger absIndex = [self GetAbsoluteIndex:indexPath.row section:indexPath.section];
    [self.browser setCurrentPhotoIndex:absIndex];
    if (!self.selectionMode)
        [self.browser hideGrid];
}


- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
	return CGRectIntegral(CGRectMake(0, 0, self.view.bounds.size.width, height));
}

-(NSInteger) GetAbsoluteIndex:(NSInteger)index section:(NSInteger)Section
{
    int totalCount =0;
    int sectionCount = Section;
    for (NSNumber* size in m_SizesOfSections)
    {
        if (sectionCount==0)
            break;
        totalCount += [size intValue];
        sectionCount--;
    }
    totalCount += index;
    return totalCount;
}

-(void)BatchLoadThumbnailTask
{
    // generate photo list via indexPathsForVisibleItems
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
	
    // if we know scroll direction, we can do the following
	//id objOrEnumerator = (lastTableViewScrollDirection == AssetBrowserScrollDirectionDown) ? (id)visibleIndexPaths : (id)[visibleIndexPaths reverseObjectEnumerator];
	id objOrEnumerator = (id)visibleIndexPaths;
    NSMutableArray* indexArray = [[NSMutableArray alloc] init];
	for (NSIndexPath *path in objOrEnumerator)
	{
        NSInteger absIndex = [self GetAbsoluteIndex:path.row section:path.section];
        [indexArray addObject:[[NSNumber alloc] initWithInteger:absIndex]];
    }
    
    // tell browser to batch load
    [self.browser batchLoadThumbnail:indexArray];

}

- (void)enterSelectionMode
{
    m_bSelection = true;
    self.selectionMode = true;
    [self.collectionView reloadData];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7"))
    {
        [self.view setNeedsLayout];
        [self.view setNeedsDisplay];
    }
    
}
- (void)leaveSelectionMode
{
    m_bSelection = false;
    self.selectionMode = false;
    [self.collectionView reloadData];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7"))
    {
        [self.view setNeedsLayout];
        [self.view setNeedsDisplay];
    }

}
- (void)uploadAction
{
    
}

- (void)ShareAction
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Confirm Action:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Share",
                            @"Don't Share", @"Cancel",
                            nil];
    popup.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    popup.actionSheetStyle = UIActionSheetStyleDefault;

    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}
- (void)DownloadAction
{
    
}
- (void)DeleteAction
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Confirm Action:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Delete", @"Cancel",
                            nil];
    popup.tag = 2;
    [popup showInView:[UIApplication sharedApplication].keyWindow];

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    bool isCancel = false;
    switch (popup.tag)
    {
        case 1:
        {
            // this is action sheet for share action
            switch (buttonIndex) {
                case 0:
                    // share
                    [self.browser TakeAction:kAction_Share with:nil];
                    break;
                case 1:
                    // don't share
                    [self.browser TakeAction:kAction_NotShare with:nil];
                    break;
                default:
                    isCancel = true;
                    break;
            }
            break;
        }
        case 2:
        {
            // this is action sheet for share action
            switch (buttonIndex) {
                case 0:
                    // delete
                    [self.browser TakeAction:kAction_Delete with:nil];
                    break;
                default:
                    isCancel = true;
                    break;
            }
            break;
        }

        default:
            isCancel = true;

            break;
    }
    if (!isCancel)
        [self leaveSelectionMode];
}

- (void)doneButtonPressed:(id)sender {
    // Only if we're modal and there's a done button
    if (m_DoneButton)
    {
        [self.browser FinishBrowser];
    }
}


-(NSString*) GetTitle
{
    if (self.selectionMode)
    {
        return NSLocalizedString(@"Select Photos", nil);
    }
    else
    {
        NSString *photosText;
        int numberOfPhotos = [self.browser numberOfPhotos];
        if (numberOfPhotos == 1) {
            photosText = NSLocalizedString(@"photo", @"Used in the context: '1 photo'");
        } else {
            photosText = NSLocalizedString(@"photos", @"Used in the context: '3 photos'");
        }
        return [NSString stringWithFormat:@"%lu %@", (unsigned long)numberOfPhotos, photosText];
    }
    
    
}
- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if([UIScreen mainScreen].bounds.size.height==568)
            {
                [view setFrame:CGRectMake(view.frame.origin.x, 568 +20, view.frame.size.width, view.frame.size.height)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, 480+20, view.frame.size.width, view.frame.size.height)];
            }
            
        }
        else
        {
            if([UIScreen mainScreen].bounds.size.height==568)
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 568)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
            }
        }
    }
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if([UIScreen mainScreen].bounds.size.height==568)
            {
                [view setFrame:CGRectMake(view.frame.origin.x, 519, view.frame.size.width, view.frame.size.height)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            if([UIScreen mainScreen].bounds.size.height==568)
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 519)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
            }
        }
    }
}

@end
