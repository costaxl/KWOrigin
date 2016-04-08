//
//  PhotoBrowserController.m
//  PhMImportTest
//
//  Created by tywang on 14/5/8.
//
//

#import "PhotoBrowserController.h"
#import "MWCommon.h"
#import "GUIAPPDelegate.h"
#import "GUIModelService.h"
#import "PhMPhotoSource.h"
#import "PersonalPhotoGridViewController.h"
#import "MWPhotoBrowser.h"
#import "ShareFolderPhotoGridViewController.h"
#import "DropboxBrowserViewController.h"
#import "FileShareBrowserViewController.h"
#import "ConfigurationDefs.h"

#include <pthread.h>


@interface PhotoBrowserController () <AssetBrowserSourceDelegate, MWPhotoBrowserDelegate, DropboxBrowserDelegate, FileShareBrowserDelegate>
{
    dispatch_semaphore_t m_CallSemaphore;
    bool m_bAlbumLoadSucess;
    bool m_bProjection;
    
    PhMPhotoSource* m_CameraRoll;
    PhMPhotoSource* m_PhotoFolder;
    MWPhotoBrowser *m_PhotoBrowser;
    PhMPhotoSource* m_CurrentSource;
    CGFloat thumbnailScale;
    bool m_TaskRunning;
    __block NSInteger m_RunningRequests;
    pthread_mutex_t m_TaskMutex;
}
- (void) Project2Device;
@end

@implementation PhotoBrowserController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
		self.title = @"Import Test";
        m_bProjection = false;

    }
    return self;
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        // Do something
        m_bProjection = false;
        m_PhotoFolder = [PhMPhotoSource assetBrowserSourceOfType:AssetBrowserSourceTypeFileSharing];
        m_CameraRoll = [PhMPhotoSource assetBrowserSourceOfType:AssetBrowserSourceTypeCameraRoll];
        thumbnailScale = [[UIScreen mainScreen] scale];
        m_TaskRunning = false;
        m_PhotoBrowser = nil;
        m_Selections = nil;
        self.photos = nil;
        pthread_mutex_init(&m_TaskMutex, NULL);
    }
    return self;
}
-(void) dealloc
{
    [m_CameraRoll dealloc];
    [m_PhotoFolder dealloc];
    if (m_Selections)
        [m_Selections dealloc];
    if (self.photos)
        [self.photos dealloc];
    [super dealloc];
    
}
#pragma mark -
#pragma mark View

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.tableView.rowHeight = 65.0; // 1 point is for the divider, we want our thumbnails to have an even height.

    // Test toolbar hiding
    //    [self setToolbarItems: @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil]]];
    //    [[self navigationController] setToolbarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
    //    self.navigationController.navigationBar.translucent = NO;
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    m_CameraRoll.GroupingByDate = true;
    m_PhotoFolder.GroupingByDate = true;
    
    [m_CameraRoll buildSourceLibrary];
    [m_PhotoFolder buildSourceLibrary];
   
    [self.tableView reloadData];
    m_CameraRoll.delegate = self;
    m_PhotoFolder.delegate = self;

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // send the state - presentable view absent
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Absent];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:self.view userInfo:dic];

    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure
	switch (indexPath.row) {
		case 0:
        {
            cell.textLabel.text = @"Camera Roll";
            cell.detailTextLabel.text = @"Photos from Camera";
            break;
            
        }
		/*case 1:
        {
            cell.textLabel.text = @"Photo Folder";
            cell.detailTextLabel.text = @"Photos from internal Folder";
            break;
            
        }*/
		default: break;
	}
    return cell;
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MWPhotoBrowser *browser = NULL;
    
    switch (indexPath.row) {
        case 0:
            // current source is camera roll
            m_CurrentSource = m_CameraRoll;
            browser = [[MWPhotoBrowser alloc] initWithDelegateAndGridController:self gridController:[PersonalPhotoGridViewController class]];
            break;
        case 1:
            // current source is camera roll
            m_CurrentSource = m_PhotoFolder;
            browser = [[MWPhotoBrowser alloc] initWithDelegateAndGridController:self gridController:[ShareFolderPhotoGridViewController class]];
            break;
            
        default:
            return;
    }
    // show photo browser
    NSString* title = self.navigationController.tabBarItem.title;
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
    

    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    browser.enableBatchLoadThumbnails = YES;
    browser.title = title;
    [browser setCurrentPhotoIndex:0];
    [browser setHidesBottomBarWhenPushed:false];
    m_PhotoBrowser = browser;
    
    if (m_Selections)
        [m_Selections dealloc];
    m_Selections = [NSMutableArray new];
    self.photos = [NSMutableArray new];

    for (int i = 0; i < [[m_CurrentSource items] count]; i++)
    {
        [m_Selections addObject:[NSNumber numberWithBool:NO]];
        PhMPhotoItem* item = [[m_CurrentSource items] objectAtIndex:i];
        [self.photos addObject:[MWPhoto photoWithURL:item.URL]];
    }
    
    browser.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:m_PhotoBrowser animated:YES];
    
}
#pragma mark - AssetBrowserSourceDelegate
- (void)assetBrowserSourceItemsDidChange:(AssetBrowserSource*)source
{
    NSLog(@"Photo items changed!!!");
    if (m_CurrentSource != source)
        return;
    // for each group add photo objects and selection objects
    if (m_Selections)
        [m_Selections dealloc];
    m_Selections = [NSMutableArray new];
    self.photos = [NSMutableArray new];
    
    for (int i = 0; i < [[m_CurrentSource items] count]; i++)
    {
        [m_Selections addObject:[NSNumber numberWithBool:NO]];
        PhMPhotoItem* item = [[m_CurrentSource items] objectAtIndex:i];
        [self.photos addObject:[MWPhoto photoWithURL:item.URL]];
    }
    [m_PhotoBrowser performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

}

#pragma mark - MWPhotoBrowserDelegate
- (NSInteger)numberOfSectionsInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [[m_CurrentSource dateGroups] count];
}
- (NSUInteger)numberOfPhotosInSection:(NSInteger)section inPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    AssetDateGroup* DateGroup = [m_CurrentSource.dateGroups objectAtIndex:section];
    return [DateGroup->Items count];
}
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [[m_CurrentSource items] count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index section:(NSInteger)section
{
    AssetDateGroup* DateGroup = [m_CurrentSource.dateGroups objectAtIndex:section];
    return [DateGroup->UserData1 objectAtIndex:index];
    
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < [[m_CurrentSource items] count])
    {
        PhMPhotoItem* item = [[m_CurrentSource items] objectAtIndex:index];
        return item;
    }
    return nil;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index section:(NSInteger)section
{
    AssetDateGroup* DateGroup = [m_CurrentSource.dateGroups objectAtIndex:section];
    return [DateGroup->Items objectAtIndex:index];
}
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForSection:(NSInteger)section
{
    AssetDateGroup* DateGroup = [m_CurrentSource.dateGroups objectAtIndex:section];
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    NSString* formateString = [formatter stringFromDate:DateGroup->Date];
    return formateString;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    if ([m_Selections count] <=0)
        return false;
    return [[m_Selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    if ([m_Selections count] <=0)
        return;

    [m_Selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self.navigationController popViewControllerAnimated:true];
    
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser prepareThumbnails:(NSArray*)indexes
{
    //
    pthread_mutex_lock(&m_TaskMutex);
    
    m_RunningRequests = 0;
    for (NSNumber *num in indexes)
    {
        NSArray *assetItemsInSection = [m_CurrentSource items];
		PhMPhotoItem *assetItem = ((NSInteger)[assetItemsInSection count] > [num integerValue]) ? [assetItemsInSection objectAtIndex:[num integerValue]] : nil;

        
        if (assetItem)
        {
			if (assetItem.thumbnailImage == nil)
            {
                CGFloat test = self.tableView.rowHeight;
				CGFloat targetHeight = self.tableView.rowHeight -1.0; // The contentView is one point smaller than the cell because of the divider.
				targetHeight *= thumbnailScale;
				
				CGFloat targetAspectRatio = 1.5;
				CGSize targetSize = CGSizeMake(targetHeight*targetAspectRatio, targetHeight);
                m_RunningRequests++;
                
				[assetItem generateThumbnailAsynchronouslyWithSize:targetSize fillMode:AssetBrowserItemFillModeCrop completionHandler:^(UIImage *thumbnail)
				{
                    pthread_mutex_lock(&m_TaskMutex);
                    
                    m_RunningRequests--;
                    
                    if (m_RunningRequests == 0)
                    {
                        m_TaskRunning = false;
                    }
                    pthread_mutex_unlock(&m_TaskMutex);

				}];

                
			}
//			if (!assetItem.haveRichestTitle) {
//				runningRequests++;
//				[assetItem generateTitleFromMetadataAsynchronouslyWithCompletionHandler:^(NSString *title){
//					runningRequests--;
//					if (runningRequests == 0) {
//						[self updateCellForBrowserItemIfVisible:assetItem];
//						// Continue generating until all thumbnails/titles in range have been finished.
//						[self thumbnailsAndTitlesTask];
//					}
//				}];
//			}
		}
    }
    
    if (m_RunningRequests)
        m_TaskRunning = true;
    else
        m_TaskRunning = false;

    pthread_mutex_unlock(&m_TaskMutex);
}

- (BOOL)isThumbnailsLoading:(MWPhotoBrowser *)photoBrowser
{
    //return true;
    return m_TaskRunning;
}
- (BOOL)prepareThumbnailsLoading:(MWPhotoBrowser *)photoBrowser
{
    @synchronized(self)
    {
        m_TaskRunning = YES;
    }
    return true;
}

- (void)willShowGrid
{
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Absent];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:self.view userInfo:dic];

    m_bProjection = false;

}
- (void)willHideGrid
{
    // Show loading spinner after a couple of seconds
    double delayInSeconds = 0.5;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
        [self Project2Device];
    });
    
}
- (void) Project2Device
{
    // send the state - presentable view absent
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Present];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:self.view userInfo:dic];
    m_bProjection = true;
    
}

- (void)photoBrowserShowView
{
    if (m_bProjection)
    {
        [self Project2Device];
    }
    else
    {
        NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
        dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Absent];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                            object:self.view userInfo:dic];

    }
}
- (void)photoBrowserWillHideView
{
    if (m_bProjection == true)
    {
        // send the state - presentable view absent
        NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
        dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_WillAbsent];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                            object:self.view userInfo:dic];

    }
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser hideBottomBar:(BOOL)bHide
{
    if (bHide)
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
        {
            
            //[self.navigationController.tabBarController.tabBar setTranslucent:YES];
        }
        [self.navigationController.tabBarController.tabBar setHidden:YES];
    }
    else
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
        {
            
            //[self.navigationController.tabBarController.tabBar setTranslucent:NO];
        }
        [self.navigationController.tabBarController.tabBar setHidden:NO];
        
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser action:(enum ActionType)Action with:(id)Parameters
{
    if ((Action == kAction_Share) || (Action == kAction_NotShare))
        [self HandleAction_Share:Action with:Parameters];
    else if (Action == kAction_Delete)
        [self HandleAction_Delete:Action with:Parameters];
    else if (Action == kAction_DBDownload)
        [self HandleAction_DBDownload:Action with:Parameters];
    else if (Action == kAction_PCDownload)
        [self HandleAction_PCDownload:Action with:Parameters];
    
}
-(void)HandleAction_Share:(enum ActionType)Action with:(id)Parameters
{
    
}

-(void)HandleAction_Delete:(enum ActionType)Action with:(id)Parameters
{
    // only occur in Photo folder
    NSMutableArray* photoArray = [[[NSMutableArray alloc] init] autorelease];
    for (int i=0;i < [m_Selections count];i++)
    {
        NSNumber *isSelect = [m_Selections objectAtIndex:i];
        if ([isSelect boolValue])
        {
            [photoArray addObject:[m_CurrentSource.items objectAtIndex:i]];
        }
    }
    if ([photoArray count] <= 0)
        return;
    NSError* error;

    for (PhMPhotoItem* item in photoArray)
    {
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:item.URL.path])
        {
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:item.URL.path error:&error];
            if (!success)
            {
                NSLog(@"Error removing file at path: %@", error.localizedDescription);
            }
        }
    }

}
-(void)HandleAction_DBDownload:(enum ActionType)Action with:(id)Parameters
{
    // Pass any objects to the view controller here, like...
    DropboxBrowserViewController *dropboxBrowser = [[DropboxBrowserViewController alloc] init];
    
    dropboxBrowser.allowedFileTypes = @[@"jpg", @"jpeg", @"jpeg-2000", @"tiff", @"pict", @"gif", @"png", @"qtif", @"icns", @"bmp", @"ico"]; // Uncomment to filter file types. Create an array of allowed types. To allow all file types simply don't set the property
    // dropboxBrowser.tableCellID = @"DropboxBrowserCell"; // Uncomment to use a custom UITableViewCell ID. This property is not required
    
    // When a file is downloaded (either successfully or unsuccessfully) you can have DBBrowser notify the user with Notification Center. Default property is NO.
    dropboxBrowser.deliverDownloadNotifications = NO;
    
    // Dropbox Browser can display a UISearchBar to allow the user to search their Dropbox for a file or folder. Default property is NO.
    dropboxBrowser.shouldDisplaySearchBar = NO;
    
    // Set the delegate property to recieve delegate method calls
    dropboxBrowser.rootViewDelegate = self;
    
    //[self.navigationController pushViewController:dropboxBrowser animated:YES];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:dropboxBrowser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}
-(void)HandleAction_PCDownload:(enum ActionType)Action with:(id)Parameters
{
    // login to pc server
    BelongingsRecordApple* Candidate = ([GUIModelService defaultModelService]).m_AppSetting.m_FileServerRecord;
    if (!Candidate)
    {
        NSString *ErrMsg = @"Please set the information of FileShare server first";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ErrMsg
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
        return;
    }
    PMPlayer_Error noerr = [[GUIModelService defaultModelService].m_FSServer Login:Candidate];

    if (noerr != kPMSError_NoError)
    {
        NSString *ErrMsg = nil;
        
        switch (noerr)
        {
            case kPMSError_AuthenticationFailed:
                ErrMsg = @"Error: AuthenticationFailed";
                break;
            case kPMSError_Command_HandlerNotFound:
                ErrMsg = @"Error: Command_HandlerNotFound";
                break;
            case kPMSError_Command_ParseError:
                ErrMsg = @"Error: Command_ParseError";
                break;
            case kPMSError_FeatureNotSupport:
                ErrMsg = @"Error: FeatureNotSupport";
                break;
            case kPMSError_PeerNotAccept:
                ErrMsg = @"Connection already occupied";
                break;
            case kPMSError_PeerUnreachable:
                ErrMsg = @"Error: Can not find FileShare server";
                break;
            case kPMSError_OtherError:
            default:
                ErrMsg = @"Error: OtherError";
                break;
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ErrMsg
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
        
        return;
    }

    // show fileshare browser
    // Pass any objects to the view controller here, like...
    FileShareBrowserViewController *fileShareBrowser = [[FileShareBrowserViewController alloc] init];
    
    fileShareBrowser.allowedFileTypes =  @[@"jpg", @"jpeg", @"jpeg-2000", @"tiff", @"pict", @"gif", @"png", @"qtif", @"icns", @"bmp", @"ico"];
    // dropboxBrowser.allowedFileTypes = @[@"doc", @"pdf"]; // Uncomment to filter file types. Create an array of allowed types. To allow all file types simply don't set the property
    // dropboxBrowser.tableCellID = @"DropboxBrowserCell"; // Uncomment to use a custom UITableViewCell ID. This property is not required
    
    // When a file is downloaded (either successfully or unsuccessfully) you can have DBBrowser notify the user with Notification Center. Default property is NO.
    fileShareBrowser.deliverDownloadNotifications = NO;
    
    // Dropbox Browser can display a UISearchBar to allow the user to search their Dropbox for a file or folder. Default property is NO.
    fileShareBrowser.shouldDisplaySearchBar = NO;
    
    // Set the delegate property to recieve delegate method calls
    fileShareBrowser.rootViewDelegate = self;
    
    //[self.navigationController pushViewController:dropboxBrowser animated:YES];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:fileShareBrowser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}



- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser layoutNavigatorItems:(UINavigationItem*)Items contentType:(NSInteger) target
{
//    if (!m_RefreshButton)
//    {
//        // create refresh button
//        m_RefreshButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(RefreshAction)];
//        
//    }
//    Items.leftBarButtonItem = m_RefreshButton;
}
#pragma mark - DropboxBrowserDelegate

- (NSString*)getDropboxBrowserDownloadFolder:(DropboxBrowserViewController *)browser
{
    return [m_PhotoFolder getFileSharingDirectory];
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten {
    if (isLocalFileOverwritten == YES) {
        NSLog(@"Downloaded %@ by overwriting local file", fileName);
    } else {
        NSLog(@"Downloaded %@ without overwriting", fileName);
    }
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToDownloadFile:(NSString *)fileName {
    NSLog(@"Failed to download %@", fileName);
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withDropboxFile:(DBMetadata *)dropboxFile withError:(NSError *)error {
    NSLog(@"File conflict between %@ and %@\n%@ last modified on %@\nError: %@", localFileURL.lastPathComponent, dropboxFile.filename, dropboxFile.filename, dropboxFile.lastModifiedDate, error);
}

- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser {
    // This method is called after Dropbox Browser is dismissed. Do NOT dismiss DropboxBrowser from this method
    // Perform any UI updates here to display any new data from Dropbox Browser
    // ex. Update a UITableView that shows downloaded files or get the name of the most recently selected file:
    //     NSString *fileName = [DropboxBrowserViewController currentFileName];
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification {
//    long badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

#pragma mark - FileShareBrowserDelegate
- (NSString*)getFileShareBrowserDownloadFolder:(FileShareBrowserViewController *)browser
{
    return [m_PhotoFolder getFileSharingDirectory];
}
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten {
    if (isLocalFileOverwritten == YES) {
        NSLog(@"Downloaded %@ by overwriting local file", fileName);
    } else {
        NSLog(@"Downloaded %@ without overwriting", fileName);
    }
}

- (void)FileShareBrowser:(FileShareBrowserViewController *)browser didFailToDownloadFile:(NSString *)fileName {
    NSLog(@"Failed to download %@", fileName);
}

- (void)FileShareBrowser:(FileShareBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withFSFile:(PMFolderEntryInfoApple *)File withError:(NSError *)error
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:File.ModifyTime];
    
    NSLog(@"File conflict between %@ and %@\n%@ last modified on %@\nError: %@", localFileURL.lastPathComponent, File.Name, File.Name, date, error);
}

- (void)FileShareBrowserDismissed:(FileShareBrowserViewController *)browser {
    // This method is called after Dropbox Browser is dismissed. Do NOT dismiss DropboxBrowser from this method
    // Perform any UI updates here to display any new data from Dropbox Browser
    // ex. Update a UITableView that shows downloaded files or get the name of the most recently selected file:
    //     NSString *fileName = [DropboxBrowserViewController currentFileName];
}

- (void)FileShareBrowser:(FileShareBrowserViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification {
    long badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
        {
            if (result != nil)
            {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
                {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)
                    {
                        if (asset)
                        {
                            @synchronized(_assets)
                            {
                                [_assets addObject:asset];
                                if (_assets.count == 1)
                                {
                                    // Added first asset so reload data
                                    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                }
                            }
                        }
                    }
                    failureBlock:^(NSError *error)
                    {
                        NSLog(@"operation was not successfull!");
                    }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}


@end
