//
//  SharePhotoUsersGridViewController.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import "SharePhotoUsersGridViewController.h"
#import "SharedPhotoUserCell.h"
#import "MWPhotoBrowserPrivate.h"
#import "MWCommon.h"
#import <objc/runtime.h>

@interface SharePhotoUsersGridViewController ()
{
    
    // Store margins for current setup
    CGFloat _margin, _gutter, _marginL, _gutterL, _columns, _columnsL;
    UIBarButtonItem  *_doneButton;
}
@end

@implementation SharePhotoUsersGridViewController

- (id)init {

    if ((self = [super init]))
    {
        
        // Defaults
        _columns = 2, _columnsL = 2;
        _margin = 0, _gutter = 1;
        _marginL = 0, _gutterL = 1;
        
        // For pixel perfection...
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            _columns = 2, _columnsL = 2;
            _margin = 100, _gutter = 100;
            _marginL = 100, _gutterL = 100;
        } else if ([UIScreen mainScreen].bounds.size.height == 480) {
            // iPhone 3.5 inch
            _columns = 2, _columnsL = 2;
            _margin = 0, _gutter = 1;
            _marginL = 1, _gutterL = 2;
        } else {
            // iPhone 4 inch
            _columns = 2, _columnsL = 2;
            _margin = 0, _gutter = 1;
            _marginL = 0, _gutterL = 2;
        }
    }
    return self;
}

#pragma mark - View



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[SharedPhotoUserCell class] forCellWithReuseIdentifier:@"SharedPhotoUserGridCell"];

}

- (void)viewWillDisappear:(BOOL)animated {
    // Cancel outstanding loading
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
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
    
}

- (void)performLayout
{
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    if (self.isModal)
    {
        if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:layoutNavigatorItems:contentType:)])
        {
            [self.browser.delegate photoBrowser:self.browser layoutNavigatorItems:self.browser.navigationItem contentType:1];
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

- (CGFloat)getColumns {
    if ((UIInterfaceOrientationIsPortrait(self.interfaceOrientation))) {
        return _columns;
    } else {
        return _columnsL;
    }
}

- (CGFloat)getMargin {
    if ((UIInterfaceOrientationIsPortrait(self.interfaceOrientation))) {
        return _margin;
    } else {
        return _marginL;
    }
}

- (CGFloat)getGutter {
    if ((UIInterfaceOrientationIsPortrait(self.interfaceOrientation))) {
        return _gutter;
    } else {
        return _gutterL;
    }
}

#pragma mark - Collection View


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [super collectionView:view numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //return [super collectionView:cv cellForItemAtIndexPath:indexPath];
    SharedPhotoUserCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"SharedPhotoUserGridCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[SharedPhotoUserCell alloc] init];
    }
    id <MWPhoto> photo = [self.browser thumbPhotoAtIndex:indexPath.row];
    cell.photo = photo;
    cell.gridController = self;
    cell.selectionMode = self.selectionMode;
    cell.isSelected = [self.browser photoIsSelectedAtIndex:indexPath.row];
    cell.index = indexPath.row;
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

-(void)BatchLoadThumbnail:(UICollectionView *)collectionView
{
    [super BatchLoadThumbnail:collectionView];
 }
-(void)BatchLoadThumbnailTask
{
    [super BatchLoadThumbnailTask];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.browser didSelectPhotoIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat margin = [self getMargin];
    CGFloat gutter = [self getGutter];
    CGFloat columns = [self getColumns];
    CGFloat value = floorf(((self.view.bounds.size.width - (columns - 1) * gutter - 2 * margin) / columns));
    return CGSizeMake(value, value);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [self getGutter];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self getGutter];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat margin = [self getMargin];
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}
-(NSString*) GetTitle
{
    NSString *photosText;
    int numberOfUsers = [self.browser numberOfPhotos];
    if (numberOfUsers == 1) {
        photosText = NSLocalizedString(@"User", @"Used in the context: '1 photo'");
    } else {
        photosText = NSLocalizedString(@"Users", @"Used in the context: '3 photos'");
    }
    return [NSString stringWithFormat:@"%lu %@", (unsigned long)numberOfUsers, photosText];
    
}

@end
