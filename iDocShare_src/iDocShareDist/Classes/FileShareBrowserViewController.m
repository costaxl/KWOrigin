//
//  FileShareBrowserViewController.m
//
//
//

#import "FileShareBrowserViewController.h"
#import "GUIModelService.h"
#import "PMFileTransporterApple.h"
#import "PMPBCAppleTranslator.h"
#include "ConfigurationDefs.h"
#include "CommandDefs.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

// Check for ARC
#if !__has_feature(objc_arc)
    // Add the -fobjc-arc flag to enable ARC for only these files, as described in the ARC documentation: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
//    #error DropboxBrowser is built with Objective-C ARC. You must enable ARC for DropboxBrowser.
#endif

// View tags to differeniate alert views
static NSUInteger const kDBSignInAlertViewTag = 1;
static NSUInteger const kFileExistsAlertViewTag = 2;
static NSUInteger const kDBSignOutAlertViewTag = 3;


@interface FileShareBrowserViewController ()
{
    PMFolderApple* m_CurrentFolderApple;
    dispatch_semaphore_t m_CallSemaphore;
    void* m_hFolderOpenDoneEvent;
    void* m_hFolderOpenErrorEvent;
    bool m_bFolderOpenSucess;
    PMFolderInfoCollectorApple* m_FolderInfoCollector;
    PMTaskObserverApple* m_pOpenFolderTaskObs;
    bool m_bWorkingDownloadFileSucess;


}

@property (nonatomic, strong, readwrite) UIProgressView *downloadProgressView;

@property (nonatomic, strong, readwrite) NSString *currentFileName;
@property (nonatomic, strong, readwrite) NSString *currentPath;

//@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) PMFolderEntryInfoApple *selectedEntry;

@property (nonatomic, assign) BOOL isLocalFileOverwritten;
@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundProcess;

@property (nonatomic, strong) FileShareBrowserViewController *subdirectoryController;

+ (PMFileTransporterApple *) fileTransporter;
+ (void) setFileTransporter:(PMFileTransporterApple *)val;

- (void)updateTableData;

- (void)downloadedFile;
- (void)startDownloadFile;
- (void)downloadedFileFailed;
- (void)updateDownloadProgressTo:(CGFloat)progress;

- (BOOL)listDirectoryAtPath:(NSString *)path;

- (void)OnFolderOpenEvent:(NSString*)eventName Info:(NSDictionary*)anInData;

@end

@implementation FileShareBrowserViewController
static PMFileTransporterApple *g_fileTransporter = NULL;
+ (PMFileTransporterApple *) fileTransporter
{
    @synchronized(self)
    {
        return g_fileTransporter;
    }
}
+ (void) setFileTransporter:(PMFileTransporterApple *)val
{
    @synchronized(self)
    {
        g_fileTransporter = val;
    }
}
- (NSString*) getFileThumbnailName:(NSString*)FileName
{
    
    if (([FileName hasSuffix:@".doc"]) || ([FileName hasSuffix:@".docx"]))
        return [[NSString alloc] initWithString:@"page_white_word"];
    if (([FileName hasSuffix:@".ppt"]) || ([FileName hasSuffix:@".pps"]) || ([FileName hasSuffix:@".pptm"])|| ([FileName hasSuffix:@".pptx"]))
        return [[NSString alloc] initWithString:@"page_white_powerpoint"];
    if (([FileName hasSuffix:@".xls"]) || ([FileName hasSuffix:@".xlc"])|| ([FileName hasSuffix:@".xlm"])|| ([FileName hasSuffix:@".xlw"])|| ([FileName hasSuffix:@".xlsx"])|| ([FileName hasSuffix:@".xlsm"]))
        return [[NSString alloc] initWithString:@"page_white_excel"];
    
    NSString *extension = [FileName pathExtension];
    CFStringRef preferredUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)extension, NULL);
    // test file type
    
    
    if (UTTypeConformsTo(preferredUTI, kUTTypeAudio))
        return [[NSString alloc] initWithString:@"page_white_sound"];
    else if (UTTypeConformsTo(preferredUTI, kUTTypeMovie))
        return [[NSString alloc] initWithString:@"page_white_film"];
    else if (UTTypeConformsTo(preferredUTI, kUTTypeImage))
        return [[NSString alloc] initWithString:@"page_white_picture"];
    else if (UTTypeConformsTo(preferredUTI, kUTTypePDF))
        return [[NSString alloc] initWithString:@"page_white_acrobat_import"];
    else if (UTTypeConformsTo(preferredUTI, kUTTypeText))
        return [[NSString alloc] initWithString:@"page_white_word"];
    else if (UTTypeConformsTo(preferredUTI, kUTTypePlainText))
        return [[NSString alloc] initWithString:@"page_white_text"];
    
    CFRelease(preferredUTI);
    
    return  [[NSString alloc] initWithString:@"pages"];
}

//------------------------------------------------------------------------------------------------------------//
//------- View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark  - View Lifecycle

- (instancetype)init {
	self = [super init];
	if (self)  {
        // Custom initialization
        [self basicSetup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom Init
        [self basicSetup];
    }
    return self;
}
-(void)dealloc
{
    dispatch_release(m_CallSemaphore);
    [super dealloc];
}

- (void)basicSetup {
    _currentPath = @"/root/";
    _isLocalFileOverwritten = NO;
    m_CurrentFolderApple = nil;
    m_CallSemaphore = dispatch_semaphore_create(0);
    m_FolderInfoCollector = nil;
    m_pOpenFolderTaskObs = nil;
    m_bWorkingDownloadFileSucess = false;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Set Title and Path
    if (self.title == nil || [self.title isEqualToString:@""]) self.title = @"FileShare";
    if (self.currentPath == nil || [self.currentPath isEqualToString:@""]) self.currentPath = @"/root/";
    
    // Setup Navigation Bar, use different styles for iOS 7 and higher
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"FileShare: Done Button to dismiss the FileShare View Controller") style:UIBarButtonItemStyleDone target:self action:@selector(removeFileShareBrowser)];
    // UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutDropbox)];
    self.navigationItem.rightBarButtonItem = rightButton;
    // self.navigationItem.leftBarButtonItem = leftButton;
    
    if (self.shouldDisplaySearchBar == YES) {
        // Create Search Bar
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
        searchBar.delegate = self;
        searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search %@", @"FileShare: Search Field Placeholder Text. Search 'CURRENT FOLDER NAME'"), self.title];
        self.tableView.tableHeaderView = searchBar;
        
        // Setup Search Controller
        UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        searchController.searchResultsDataSource = self;
        searchController.searchResultsDelegate = self;
        searchController.delegate = self;
        self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    }
    
    // Add Download Progress View to Navigation Bar
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // The user is on an iPad - Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        CGFloat yOrigin = self.navigationController.navigationBar.bounds.size.height-newProgressView.bounds.size.height;
        CGFloat widthBoundary = self.navigationController.navigationBar.bounds.size.width;
        CGFloat heigthBoundary = newProgressView.bounds.size.height;
        newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
        
        newProgressView.alpha = 0.0;
        newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        newProgressView.trackTintColor = [UIColor lightGrayColor];
        
        [self.navigationController.navigationBar addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    } else {
        // The user is on an iPhone / iPod Touch - Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        CGFloat yOrigin = self.navigationController.navigationBar.bounds.size.height-newProgressView.bounds.size.height;
        CGFloat widthBoundary = self.navigationController.navigationBar.bounds.size.width;
        CGFloat heigthBoundary = newProgressView.bounds.size.height;
        newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
        
        newProgressView.alpha = 0.0;
        newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        newProgressView.trackTintColor = [UIColor lightGrayColor];
        
        [self.navigationController.navigationBar addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    }
    
#if 0
    // Add a refresh control, pull down to refresh
    if ([UIRefreshControl class])
    {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        [refreshControl addTarget:self action:@selector(updateContent) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
#endif
    
    // Get file transport interface
    if (!FileShareBrowserViewController.fileTransporter)
    {
        PMPBCAppleTranslator* PBC = [GUIModelService defaultModelService].m_FSServer.FileSharePBC;
        if (PBC)
            FileShareBrowserViewController.fileTransporter = [PBC GetFeature:@PM_FEATURE_FileTransporter];

    }
    
    // Initialize Directory Content
    if ([self.currentPath isEqualToString:@"/root/"])
    {
        [self listDirectoryAtPath:@"/root/"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self isFileServerLinked]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login to FileServer", @"FileServerBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ is not login to your FileServer. Would you like to login now and allow access?", @"FileServerBrowser: Alert Message. 'APP NAME' is not linked to FileServer..."), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"FileServerBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Login", @"FileServerBrowser: Alert Button"), nil];
        alertView.tag = kDBSignInAlertViewTag;
        [alertView show];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)logoutOfFileServer {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Logout of FileServer", @"FileServerBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to logout of FileServer ?", @"FileServerBrowser: Alert Message. ...logout FileServer for 'APP NAME'"), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"FileServerBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Logout", @"FileServerBrowser: Alert Button"), nil];
    alertView.tag = kDBSignOutAlertViewTag;
    [alertView show];
}

//------------------------------------------------------------------------------------------------------------//
//------- Table View -----------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!m_bFolderOpenSucess || ([m_FolderInfoCollector GetSize] == 0))
    {
        return 2; // Return cell to show the folder is empty
    }
    else
        return [m_FolderInfoCollector GetSize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!m_bFolderOpenSucess)
    {
        // There are no files in the directory - let the user know
        if (indexPath.row == 1)
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            if (self.isSearching == YES)
            {
                cell.textLabel.text = NSLocalizedString(@"No Search Results", @"FileShare: Empty Search Results Text");
            } else
            {
                cell.textLabel.text = NSLocalizedString(@"Folder Info not loaded", @"FileShare: Folder Info not loaded Text");
            }
            
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    }
    else if ([m_FolderInfoCollector GetSize] == 0)
    {
        // There are no files in the directory - let the user know
        if (indexPath.row == 1)
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            if (self.isSearching == YES)
            {
                cell.textLabel.text = NSLocalizedString(@"No Search Results", @"FileshareBrowser: Empty Search Results Text");
            } else
            {
                cell.textLabel.text = NSLocalizedString(@"Folder is Empty", @"FileshareBrowser: Empty Folder Text");
            }
            
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    }
    else
    {
        // Check if the table cell ID has been set, otherwise create one
        if (!self.tableCellID || [self.tableCellID isEqualToString:@""])
        {
            self.tableCellID = @"FileShareBrowserCell";
        }
        
        // Create the table view cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.tableCellID];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FileShareBrowserCell"];
        }
        
        // Configure the file share Data for the cell
        [m_FolderInfoCollector Goto:indexPath.row];
        PMFolderEntryInfoApple* EntryInfoApple = [m_FolderInfoCollector GetInfo];
        
        // Setup the cell file name
        cell.textLabel.text = EntryInfoApple.Name;
        [cell.textLabel setNeedsDisplay];
        
        // Display icon
        
        // Setup Last Modified Date
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        // Get File Details and Display
        if (EntryInfoApple.Type == 1)
        {
            // Folder
            NSString* iconName = [[NSString alloc] initWithString:@"folder"];
            cell.imageView.image = [UIImage imageNamed:iconName];

            cell.detailTextLabel.text = @"";
            [cell.detailTextLabel setNeedsDisplay];

        }
        else
        {
            NSString* iconName = [self getFileThumbnailName:EntryInfoApple.Name];
            cell.imageView.image = [UIImage imageNamed:iconName];

            // File
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:EntryInfoApple.ModifyTime];
            NSString* strInfo = [NSString stringWithFormat:NSLocalizedString(@"%d, modified %@", @"FileShare: File detail label with the file size and modified date."), EntryInfoApple.Size, [formatter stringFromDate:date]];
           
            cell.detailTextLabel.text = strInfo;
            [cell.detailTextLabel setNeedsDisplay];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == nil)
        return;
    if (!m_bFolderOpenSucess || ([m_FolderInfoCollector GetSize] == 0))
    {
        // Do nothing, there are no items in the list. We don't want to download a file that doesn't exist (that'd cause a crash)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [m_FolderInfoCollector Goto:indexPath.row];
        self.selectedEntry = [m_FolderInfoCollector GetInfo];

        if (self.selectedEntry.Type == 1)
        {
            // folder
            // Create new UITableViewController
            self.subdirectoryController = [[FileShareBrowserViewController alloc] init];
            self.subdirectoryController.rootViewDelegate = self.rootViewDelegate;
            NSString *subpath = [self.currentPath stringByAppendingPathComponent:self.selectedEntry.Name];
            self.subdirectoryController.currentPath = subpath;
            self.subdirectoryController.title = [subpath lastPathComponent];
            self.subdirectoryController.shouldDisplaySearchBar = self.shouldDisplaySearchBar;
            self.subdirectoryController.deliverDownloadNotifications = self.deliverDownloadNotifications;
            self.subdirectoryController.allowedFileTypes = self.allowedFileTypes;
            self.subdirectoryController.tableCellID = self.tableCellID;
            
            [self.subdirectoryController listDirectoryAtPath:subpath];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self.navigationController pushViewController:self.subdirectoryController animated:YES];
        }
        else
        {
            self.currentFileName = self.selectedEntry.Name;
            
            // Check if our delegate handles file selection
            if ([self.rootViewDelegate respondsToSelector:@selector(FileShareBrowser:didSelectFile:)])
            {
                [self.rootViewDelegate FileShareBrowser:self didSelectFile:self.selectedEntry];
            }
            else if ([self.rootViewDelegate respondsToSelector:@selector(FileShareBrowser:selectedFile:)])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [self.rootViewDelegate FileShareBrowser:self selectedFile:self.selectedEntry];
#pragma clang diagnostic pop
            }
            else
            {
                // Download file
                [self downloadFile:self.selectedEntry replaceLocalVersion:NO];
            }
        }
        
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- SearchBar Delegate ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - SearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //[[self restClient] searchPath:self.currentPath forKeyword:searchBar.text];
    [searchBar resignFirstResponder];
    
    // We are no longer searching the directory
    self.isSearching = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // We are no longer searching the directory
    self.isSearching = NO;
    
    // Dismiss the Keyboard
    [searchBar resignFirstResponder];
    
    // Reset the data and reload the table
    [self listDirectoryAtPath:self.currentPath];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // We are searching the directory
    self.isSearching = YES;
    
    if ([searchBar.text isEqualToString:@""] || searchBar.text == nil)
    {
        // [searchBar resignFirstResponder];
        [self listDirectoryAtPath:self.currentPath];
    }
    else if (![searchBar.text isEqualToString:@" "] || ![searchBar.text isEqualToString:@""])
    {
        //[[self restClient] searchPath:self.currentPath forKeyword:searchBar.text];
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- AlertView Delegate ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kDBSignInAlertViewTag) {
        switch (buttonIndex)
        {
            case 0:
                [self removeFileShareBrowser];
                break;
            case 1:
                //[[DBSession sharedSession] linkFromController:self];
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == kFileExistsAlertViewTag)
    {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                // User selected overwrite
                [self downloadFile:self.selectedEntry replaceLocalVersion:YES];
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == kDBSignOutAlertViewTag)
    {
        switch (buttonIndex)
        {
            case 0: break;
            case 1:
            {
                //[[DBSession sharedSession] unlinkAll];
                [self removeFileShareBrowser];
            }
                break;
            default:
                break;
        }
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- Content Refresh ------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Content Refresh

- (void)updateTableData {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)updateContent {
    [self listDirectoryAtPath:self.currentPath];
}

//------------------------------------------------------------------------------------------------------------//
//------- DataController Delegate ----------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DataController Delegate

- (void)removeFileShareBrowser
{
    // logout
    [[GUIModelService defaultModelService].m_FSServer Logout];
    FileShareBrowserViewController.fileTransporter = nil;

    [self dismissViewControllerAnimated:YES completion:^{
        if ([[self rootViewDelegate] respondsToSelector:@selector(FileShareBrowserDismissed:)])
            [[self rootViewDelegate] FileShareBrowserDismissed:self];
    }];
}

- (void)downloadedFile {
    self.tableView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.75 animations:^{
        self.tableView.alpha = 1.0;
        self.downloadProgressView.alpha = 0.0;
    }];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Downloaded", @"FileShareBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ was downloaded from File Server.", @"FileShareBrowser: Alert Message"), self.currentFileName] delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", @"FileShareBrowser: Alert Button") otherButtonTitles:nil];
    [alertView show];
    
    // Deliver File Download Notification
    if (self.deliverDownloadNotifications == YES) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Downloaded %@ from File Server", @"FileShareBrowser: Notification Body Text"), self.currentFileName];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        if ([[self rootViewDelegate] respondsToSelector:@selector(FileShareBrowser:deliveredFileDownloadNotification:)])
            [[self rootViewDelegate] FileShareBrowser:self deliveredFileDownloadNotification:localNotification];
    }
    
    if ([self.rootViewDelegate respondsToSelector:@selector(FileShareBrowser:didDownloadFile:didOverwriteFile:)]) {
        [self.rootViewDelegate FileShareBrowser:self didDownloadFile:self.currentFileName didOverwriteFile:self.isLocalFileOverwritten];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    } else if ([[self rootViewDelegate] respondsToSelector:@selector(FileShareBrowser:downloadedFile:isLocalFileOverwritten:)]) {
        [[self rootViewDelegate] FileShareBrowser:self downloadedFile:self.currentFileName isLocalFileOverwritten:self.isLocalFileOverwritten];
    } else if ([[self rootViewDelegate] respondsToSelector:@selector(FileShareBrowser:downloadedFile:)]) {
        [[self rootViewDelegate] FileShareBrowser:self downloadedFile:self.currentFileName];
    }
#pragma clang diagnostic pop
    
    // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundProcess];
}

- (void)startDownloadFile {
    [self.downloadProgressView setProgress:0.0];
    [UIView animateWithDuration:0.75 animations:^{
        self.downloadProgressView.alpha = 1.0;
    }];
}

- (void)downloadedFileFailed {
    self.tableView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.75 animations:^{
        self.tableView.alpha = 1.0;
        self.downloadProgressView.alpha = 0.0;
    }];
    
    self.navigationItem.title = [self.currentPath lastPathComponent];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // Deliver File Download Notification
    if (self.deliverDownloadNotifications == YES) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Failed to download %@ from File Server.", @"FileShareBrowser: Notification Body Text"), self.currentFileName];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        if ([[self rootViewDelegate] respondsToSelector:@selector(FileShareBrowser:deliveredFileDownloadNotification:)])
            [[self rootViewDelegate] FileShareBrowser:self deliveredFileDownloadNotification:localNotification];
    }
    
    if ([self.rootViewDelegate respondsToSelector:@selector(FileShareBrowser:didFailToDownloadFile:)]) {
        [self.rootViewDelegate FileShareBrowser:self didFailToDownloadFile:self.selectedEntry];
    }
    // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundProcess];
}

- (void)updateDownloadProgressTo:(CGFloat)progress {
    [self.downloadProgressView setProgress:progress];
}

//------------------------------------------------------------------------------------------------------------//
//------- Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - call FileTransporter api and events
- (void)OnFolderOpenEvent:(NSString*)eventName Info:(NSDictionary*)anInData
{
    if ([eventName isEqualToString:@PMFolder_Event_FolderLoadError])
    {
        m_bFolderOpenSucess = false;
    }
    else if ([eventName isEqualToString:@PMFolder_Event_FolderLoadDone])
    {
        m_bFolderOpenSucess = true;
    }
    if (([eventName isEqualToString:@PMFolder_Event_FolderLoadError]) || ([eventName isEqualToString:@PMFolder_Event_FolderLoadDone]))
    {
        // remove obs
        [m_CurrentFolderApple RemoveObserver:@PMFolder_Event_FolderLoadDone Handle:m_hFolderOpenDoneEvent];
        [m_CurrentFolderApple RemoveObserver:@PMFolder_Event_FolderLoadError Handle:m_hFolderOpenErrorEvent];
 
    }
    if (!m_bFolderOpenSucess)
        return;
    
    [self performSelectorOnMainThread:@selector(updateTableData) withObject:nil waitUntilDone:true];

}

- (BOOL)listDirectoryAtPath:(NSString *)path
{
    if ([self isFileServerLinked])
    {
        
        m_CurrentFolderApple = [FileShareBrowserViewController.fileTransporter GetFolder:path ReturnObserver:self ReturnSelector:nil];
        
        if (!m_CurrentFolderApple)
            return NO;
        
        m_bFolderOpenSucess = false;
        m_hFolderOpenDoneEvent = [m_CurrentFolderApple AddObserver:@PMFolder_Event_FolderLoadDone Observer:self selector:@selector(OnFolderOpenEvent:Info:)];
        m_hFolderOpenErrorEvent = [m_CurrentFolderApple AddObserver:@PMFolder_Event_FolderLoadError Observer:self selector:@selector(OnFolderOpenEvent:Info:)];
        NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
        m_FolderInfoCollector = [m_CurrentFolderApple OpenFolder:dic ReturnObserver:self ReturnSelector:nil];
        if (!m_FolderInfoCollector)
            return NO;
        
        // set allowed file type
        NSMutableString * allType = [[NSMutableString alloc] init];
        for (NSString* str in self.allowedFileTypes)
        {
            [allType appendString:@" ."];
            [allType appendString:str];
        }
        [m_FolderInfoCollector SetAllowedType:allType];
        
        return YES;
    }
    else
        return NO;
}

- (BOOL)isFileServerLinked
{
    if (FileShareBrowserViewController.fileTransporter)
        return true;
    else
        return false;
}

- (BOOL)downloadFile:(PMFolderEntryInfoApple*)file replaceLocalVersion:(BOOL)replaceLocalVersion
{
    // Begin Background Process
    self.backgroundProcess = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundProcess];
        self.backgroundProcess = UIBackgroundTaskInvalid;
    }];
    
    // Check if the file is a directory
    if (file.Type == 1) return NO;
    
    // Set download success
    // Setup the File Manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create the local file path
    NSString *documentsPath = NULL;
    if ([self.rootViewDelegate respondsToSelector:@selector(getFileShareBrowserDownloadFolder:)])
    {
        documentsPath = [self.rootViewDelegate getFileShareBrowserDownloadFolder:self];
    }
    else
    {
        documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    }
    NSString *localPath = [documentsPath stringByAppendingPathComponent:file.Name];
    
    // Check if the local version should be overwritten
    if (replaceLocalVersion)
    {
        self.isLocalFileOverwritten = YES;
        [fileManager removeItemAtPath:localPath error:nil];
    }
    else
        self.isLocalFileOverwritten = NO;
    
    m_bWorkingDownloadFileSucess = false;

    // Check if a file with the same name already exists locally
    if ([fileManager fileExistsAtPath:localPath] == NO)
    {
        // Prevent the user from downloading any more files while this donwload is in progress
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.75 animations:^{
            self.tableView.alpha = 0.8;
        }];
        
        // Start the file download
        [self startDownloadFile];
        m_pOpenFolderTaskObs = [[PMTaskObserverApple alloc] init];
        [m_pOpenFolderTaskObs SetStateObserver:self selector:@selector(OnOpenFolderTaskStateChanged:)];

        [FileShareBrowserViewController.fileTransporter DownloadFile:file.FullPath destFolder:documentsPath observer:m_pOpenFolderTaskObs];
//        while (dispatch_semaphore_wait(m_CallSemaphore, DISPATCH_TIME_NOW))
//        {
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//        }
        
    }
    else
    {
        // Create the local URL and get the modification date
        NSURL *fileUrl = [NSURL fileURLWithPath:localPath];
        NSDate *fileDate;
        NSError *error = nil;
        [fileUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
        uint32_t localFileDate =  [@(floor([fileDate timeIntervalSince1970])) unsignedLongValue];
        if (!error)
        {
            
            if (localFileDate < file.ModifyTime)
            {
                // File Server's file is older than local file
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Conflict", @"FileshareBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ has already been downloaded from File Server. You can overwrite the local version with the File Server one. The file in local files is newer than the File Server's file.", @"FileshareBrowser: Alert Message"), file.Name] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"FileshareBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Overwrite", @"FileshareBrowser: Alert Button"), nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in File Server and locally. The local file is newer."};
                NSError *error = [NSError errorWithDomain:@"[FileshareBrowser] File Conflict Error: File already exists in File Server and locally. The local file is newer." code:kFileShareFileOlderError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(FileShareBrowser:fileConflictWithLocalFile:withFSFile:withError:)])
                {
                    [self.rootViewDelegate FileShareBrowser:self fileConflictWithLocalFile:fileUrl withFSFile:file withError:error];
                }
                
            }
            else if (localFileDate > file.ModifyTime)
            {
                // File Server file is newer than local file
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Conflict", @"FileshareBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ has already been downloaded from File Server. You can overwrite the local version with the File server's file. The file in File Server is newer than the local file.", @"FileshareBrowser: Alert Message"), file.Name] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"FileshareBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Overwrite", @"FileshareBrowser: Alert Button"), nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in File Server and locally. The File Server file is newer."};
                NSError *error = [NSError errorWithDomain:@"[FileshareBrowser] File Conflict Error: File already exists in File Server and locally. The File Server's file is newer." code:kFileShareFileNewerError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(FileShareBrowser:fileConflictWithLocalFile:withFSFile:withError:)])
                {
                    [self.rootViewDelegate FileShareBrowser:self fileConflictWithLocalFile:fileUrl withFSFile:file withError:error];
                }
            }
            else
            {
                // File Server's File and local file were both modified at the same time
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Conflict", @"FileshareBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ has already been downloaded from File server. You can overwrite the local version with the File Server's file. Both the local file and the File server's file were modified at the same time.", @"FileshareBrowser: Alert Message"), file.Name] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"FileshareBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Overwrite", @"FileshareBrowser: Alert Button"), nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in File Server and locally. Both files were modified at the same time."};
                NSError *error = [NSError errorWithDomain:@"[FileshareBrowser] File Conflict Error: File already exists in File Server and locally. Both files were modified at the same time." code:kFileShareFileSameAsLocalFileError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(FileShareBrowser:fileConflictWithLocalFile:withFSFile:withError:)])
                {
                    [self.rootViewDelegate FileShareBrowser:self fileConflictWithLocalFile:fileUrl withFSFile:file withError:error];
                }
            }
            
            [self updateTableData];
        }
        else
        {
            m_bWorkingDownloadFileSucess = NO;
        }
    }
    
    return m_bWorkingDownloadFileSucess;
}

- (void)OnOpenFolderTaskStateChanged:(NSDictionary*)anInData
{
    [self performSelectorOnMainThread:@selector(execOnOpenFolderTaskStateChanged:) withObject:anInData waitUntilDone:true];
}

- (void)execOnOpenFolderTaskStateChanged:(NSDictionary*)anInData
{
    int NewState = [anInData[@"State"] intValue];
    uint32_t TaskHandle = [anInData[@"TaskHandle"] unsignedIntValue];
    if (NewState == kStateNewInfo)
    {
        // update progress
        int NewSize = [anInData[@"SIZE"] intValue];
        CGFloat progress = (CGFloat)NewSize/self.selectedEntry.Size;
        NSLog(@"New progress:%f", progress);
        [self updateDownloadProgressTo:progress];
    }
    else if (NewState == kStateStopped)
    {
        //dispatch_semaphore_signal(m_CallSemaphore);
        
    }
    else if (NewState == kStateError)
    {
        [self downloadedFileFailed];
    }
    else if (NewState == kStateDone)
    {
        [self downloadedFile];
    }

}


@end
