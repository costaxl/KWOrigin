//
//  FIleListViewController.m
//

#import "FIleListViewController.h"
#import "DocBrowserController.h"
#import "DirectoryWatcher.h"
#import "UIViewController+CWPopup.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import "GUIModelService.h"
#import "ConfigurationDefs.h"
#import "FileShareBrowserViewController.h"
#import "DropboxBrowserViewController.h"
#import "LoginPopupViewController.h"



#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

enum
{
    kSortingType_ByAlphabet,
    kSortingType_ByType
};

@interface FIleListViewController() <DirectoryWatcherDelegate, UIActionSheetDelegate, DropboxBrowserDelegate, FileShareBrowserDelegate, LoginPopupViewControllerDelegate>
{
    DirectoryWatcher *directoryWatcher;
    NSInteger m_SelectedIndex;
    LoginPopupViewController* m_pLoginPopup;
    UIBarButtonItem* m_DropboxAccessButton, *m_PCAccessButton;
    UIBarButtonItem *editButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *deleteButton;
    UIBarButtonItem *m_SortByAButton, *m_SortByTypeButton, *m_CurrentSortButton;
    int m_SortingType;
    bool m_bInLoginPhase;

}
@property (nonatomic, copy) NSString *m_DocumentPath;

- (void)buildFileSharingLibrary;
- (NSArray*)browserItemsInDirectory:(NSString*)directoryPath;
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher;
- (void)updateBrowserItemsAndSignalDelegate:(NSArray*)newItems;

- (void)accessDropBox;
- (void)accessPC;
- (NSString*) getFileThumbnailName:(NSString*)FileName;

- (void)updateButtonsToMatchTableState;
@end

@implementation FIleListViewController
@synthesize FileListTableView;
@synthesize FileNames;
@synthesize fileURL;
@synthesize m_DocumentPath;

//static NSString* g_DocumentPath = @"Document";
static NSString* g_DocumentPath = @".";
static NSString* GetFullFilePath(NSString* FileName)
{
    NSString *nsFileName = FileName;
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:g_DocumentPath];

    NSString* nsFullPath = [documentsDirectory stringByAppendingPathComponent:nsFileName];
    return nsFullPath;
    
}

- (void)buildFileSharingLibrary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.m_DocumentPath = [documentsDirectory stringByAppendingPathComponent:g_DocumentPath];
    if ([fileManager fileExistsAtPath:self.m_DocumentPath] == NO)
    {
        // create dir
        [fileManager createDirectoryAtPath:self.m_DocumentPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
	NSArray *browserItems = [self browserItemsInDirectory:self.m_DocumentPath];
	[self updateBrowserItemsAndSignalDelegate:browserItems];
	directoryWatcher = [[DirectoryWatcher watchFolderWithPath:self.m_DocumentPath delegate:self] retain];
}
- (NSArray*)browserItemsInDirectory:(NSString*)directoryPath
{
    NSSortDescriptor * sortDesc = nil;
    if (m_SortingType == kSortingType_ByType)
    {
        sortDesc = [[NSSortDescriptor alloc] initWithKey:@"pathExtension" ascending:YES];
    }
    else
    {
        sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    }
   
	NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
	NSArray *subPaths = [[[[NSFileManager alloc] init] autorelease] contentsOfDirectoryAtPath:directoryPath error:nil];
	if (subPaths)
    {
		for (NSString *subPath in subPaths)
        {
			NSString *pathExtension = [subPath pathExtension];
            NSString *path = [directoryPath stringByAppendingPathComponent:subPath];
            [paths addObject:subPath];

////            
//			CFStringRef preferredUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)pathExtension, NULL);
//            // test file type
//			BOOL fileConformsToUTI;
//            // audio or video type
//            fileConformsToUTI = UTTypeConformsTo(preferredUTI, kUTTypeAudiovisualContent);
//            if (!fileConformsToUTI)
//                fileConformsToUTI = UTTypeConformsTo(preferredUTI, kUTTypeImage);
//            
//			CFRelease(preferredUTI);

		}
        [paths sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        [sortDesc release];

	}
	return paths;
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
        return [[NSString alloc] initWithString:@"page_white_acrobat"];
    else if (UTTypeConformsTo(preferredUTI, kUTTypeText))
        return [[NSString alloc] initWithString:@"page_white_word"];
    else if (UTTypeConformsTo(preferredUTI, kUTTypePlainText))
        return [[NSString alloc] initWithString:@"page_white_text"];
   
    CFRelease(preferredUTI);
    
    return  [[NSString alloc] initWithString:@"pages"];
}
- (void)updateBrowserItemsAndSignalDelegate:(NSArray*)newItems
{
	self.FileNames = newItems;
    [self.FileListTableView reloadData];
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{

    NSArray *browserItems = [self browserItemsInDirectory:self.m_DocumentPath];
    [self updateBrowserItemsAndSignalDelegate:browserItems];

//	dispatch_async(enumerationQueue, ^(void) {
//		NSArray *browserItems = [self browserItemsInDirectory:documentsDirectory];
//		dispatch_async(dispatch_get_main_queue(), ^(void) {
//			[self updateBrowserItemsAndSignalDelegate:browserItems];
//		});
//	});
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_pLoginPopup = nil;
        m_bInLoginPhase = false;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.FileNames = [[NSArray array] retain];
    
    NSString *pcAccessImagePath;
    NSString *dbAccessImagePath;
    NSString *deleteImagePath;
    NSString* SortByAImagePath;
    NSString* SortByTypePath;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        pcAccessImagePath = @"174-imac.png";
        dbAccessImagePath = @"AccessDropbox_25.png";
        deleteImagePath = @"kwDelete_25.png";
        SortByAImagePath = @"SortByA_25.png";
        SortByTypePath = @"SortByType_25.png";
    }
    else
    {
        pcAccessImagePath = @"174-imac.png";
        dbAccessImagePath = @"AccessDropbox_25.png";
        deleteImagePath = @"kwDelete_25.png";
        SortByAImagePath = @"SortByA_25.png";
        SortByTypePath = @"SortByType_25.png";

    }
    UIImage* DBAccessImage = [UIImage imageNamed:dbAccessImagePath];
    m_DropboxAccessButton = [[UIBarButtonItem alloc] initWithImage:DBAccessImage style:UIBarButtonItemStylePlain target:self action:@selector(accessDropBox)];
    UIImage* PCAccessImage = [UIImage imageNamed:pcAccessImagePath];
    m_PCAccessButton = [[UIBarButtonItem alloc] initWithImage:PCAccessImage style:UIBarButtonItemStylePlain target:self action:@selector(accessPC)];
    
    UIImage* DeleteImage = [UIImage imageNamed:deleteImagePath];
    editButton = [[UIBarButtonItem alloc] initWithImage:DeleteImage style:UIBarButtonItemStylePlain target:self action:@selector(onEditAction)];
    //editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit   target:self action:@selector(onEditAction)];
    
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel   target:self action:@selector(onCancelAction)];
    
    deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete all" style:UIBarButtonItemStyleBordered target:self action:@selector(onDeleteAction)];
    
    UIImage* SortByAImage = [UIImage imageNamed:SortByAImagePath];
    m_SortByAButton = [[UIBarButtonItem alloc] initWithImage:SortByAImage style:UIBarButtonItemStylePlain target:self action:@selector(actionSortByA)];

    UIImage* SortByTypeImage = [UIImage imageNamed:SortByTypePath];
    m_SortByTypeButton = [[UIBarButtonItem alloc] initWithImage:SortByTypeImage style:UIBarButtonItemStylePlain target:self action:@selector(actionSortByType)];

    m_SortingType = kSortingType_ByAlphabet;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;

}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [self buildFileSharingLibrary];
    m_SelectedIndex = 0;
    if (m_pLoginPopup)
        return;
    
    m_pLoginPopup = [[LoginPopupViewController alloc] initWithNibName:@"LoginPopupViewController" bundle:nil];
    
    CGPoint offset;
    offset.x = 0;
    offset.y = -m_pLoginPopup.view.frame.size.height/2;

    m_pLoginPopup.popupViewOffset = offset;
    self.useBlurForPopup = true;
    m_pLoginPopup.delegate = self;
    // lock tab, changing tab is not allowed
    [([GUIModelService defaultModelService]).m_AppService LockTab];
    [self presentPopupViewController:m_pLoginPopup animated:YES completion:^(void) {
        //NSLog(@"popup view presented");
        m_bInLoginPhase = true;
    }];
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    NSArray* ButtonArray;
    if (m_SortingType == kSortingType_ByAlphabet)
        m_CurrentSortButton = m_SortByTypeButton;
    else
        m_CurrentSortButton = m_SortByAButton;
    
    // Irina
   // ButtonArray = [[NSArray alloc] initWithObjects:m_CurrentSortButton, editButton, m_PCAccessButton, m_DropboxAccessButton, nil];

    ButtonArray = [[NSArray alloc] initWithObjects:editButton, m_DropboxAccessButton, nil];
    
    self.navigationItem.RightBarButtonItems = ButtonArray;

    [self updateButtonsToMatchTableState];

}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
    // send the state - presentable view absent
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Absent];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:self.view userInfo:dic];

}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath)
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)viewWillLayoutSubviews
{
    [self performLayout];
}
- (void)performLayout
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [FileNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString* FileName = [FileNames objectAtIndex:indexPath.row];
    cell.textLabel.text = FileName;
    NSString* iconName = [self getFileThumbnailName:FileName];
    cell.imageView.image = [UIImage imageNamed:iconName];

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (m_bInLoginPhase)
        return;
    
    BOOL inEditingMode = self.tableView.editing;
    if (inEditingMode)
    {
        [self updateButtonsToMatchTableState];
        
        return;
    }

    //initializing the fileURL object with the URL links to be loaded
    m_SelectedIndex = indexPath.row;
    NSString* FullPath = GetFullFilePath([FileNames objectAtIndex:indexPath.row]);
    fileURL = [[NSURL alloc] initFileURLWithPath:FullPath];
    
    [self performSegueWithIdentifier:@"ViewDoc" sender:self];


}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL inEditingMode = self.tableView.editing;
    if (!inEditingMode)
        return;
    
    [self updateButtonsToMatchTableState];
  
}
- (void)updateButtonsToMatchTableState
{
    BOOL inEditingMode = self.tableView.editing;
    if(inEditingMode)
    {
        self.navigationItem.RightBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = cancelButton;
        // update the delete button's title, based on how many items are selected
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        NSInteger numRows;
        
        numRows = [FileNames count];
        BOOL allItemsAreSelected = selectedRows.count == numRows;
        BOOL noItemsAreSelected = selectedRows.count == 0;
        if(allItemsAreSelected || noItemsAreSelected)
        {
            deleteButton.title = @"Delete All";
        }
        else
        {
            deleteButton.title = [NSString stringWithFormat:@"Delete (%d)", selectedRows.count];
        }
        // show the delete button
        self.navigationItem.leftBarButtonItem = deleteButton;
        
    }
    else
    {
        
        //Show the edit button
        self.navigationItem.leftItemsSupplementBackButton = YES;
        NSArray* ButtonArray;
        
        // Irina
   //     ButtonArray = [[NSArray alloc] initWithObjects:m_CurrentSortButton, editButton, m_PCAccessButton, m_DropboxAccessButton, nil];
        
        ButtonArray = [[NSArray alloc] initWithObjects: editButton, m_DropboxAccessButton, nil];
        self.navigationItem.RightBarButtonItems = ButtonArray;

        //self.navigationItem.rightBarButtonItem = editButton;
        self.navigationItem.leftBarButtonItem = nil;
        
        // but disable the edit button if there's nothing to edit
        //NSInteger numRows;
        //numRows = [FileNames count];
        //BOOL thereAreItemsToEdit = (numRows > 0);
        //editButton.enabled = thereAreItemsToEdit;
        
    }
}
#pragma mark Action methods
- (IBAction)onEditAction
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)onCancelAction
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}
- (IBAction)onDeleteAction
{
    // open a dialog with just an OK button
	NSString *actionTitle = ([[self.tableView indexPathsForSelectedRows] count] == 1) ?
    @"Are you sure you want to remove this item?" : @"Are you sure you want to remove these items?";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
    
}
#pragma mark ActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		// delete what the user selected
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        NSError* error;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                NSString* FullPath = GetFullFilePath([FileNames objectAtIndex:selectionIndex.row]);
                fileURL = [[NSURL alloc] initFileURLWithPath:FullPath];

                if ([[NSFileManager defaultManager] isDeletableFileAtPath:FullPath])
                {
                    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:FullPath error:&error];
                    if (!success)
                    {
                        NSLog(@"Error removing file at path: %@", error.localizedDescription);
                    }
                }

            }
            
            
            // Tell the tableView that we deleted the objects
            //[self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else // delete everything
        {
            for (NSString *fileName in FileNames)
            {
                NSString* FullPath = GetFullFilePath(fileName);

                if ([[NSFileManager defaultManager] isDeletableFileAtPath:FullPath])
                {
                    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:FullPath error:&error];
                    if (!success)
                    {
                        NSLog(@"Error removing file at path: %@", error.localizedDescription);
                    }
                }
            }
            
            // Tell the tableView that we deleted the objects.
            // Since we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        // Exit editing mode after the deletion
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
	}
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ViewDoc"])
    {
        DocBrowserController *DocViewer =(DocBrowserController *)[segue destinationViewController];
        DocViewer.title = [FileNames objectAtIndex:m_SelectedIndex];
        DocViewer.fileName = GetFullFilePath([FileNames objectAtIndex:m_SelectedIndex]);
    }
    
}

#pragma mark -

- (void)viewDidUnload
{
    [FileListTableView release];
    FileListTableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [FileNames release];
    
    [directoryWatcher invalidate];
	directoryWatcher.delegate = nil;
	[directoryWatcher release];
    [editButton dealloc];
    [cancelButton dealloc];
    [deleteButton dealloc];
    [m_DropboxAccessButton dealloc];
    [m_PCAccessButton dealloc];
    [m_SortByAButton dealloc];
    [m_SortByTypeButton dealloc];
    [super dealloc];
}

-(void) actionDone:(enum ActionResult)ActionResult errorCode:(int)ErrorCode
{
    // dissmiss the popup
    [self dismissPopupViewControllerAnimated:YES completion:^{
        //NSLog(@"popup view dismissed");
        [([GUIModelService defaultModelService]).m_AppService UnlockTab];
        m_bInLoginPhase = false;
    }];
    
    /* Display the error. */
    NSString* alterMessage=nil;
    if (ActionResult == kAction_Success)
    {
        alterMessage = @"Login Successful";
    }
    else if (ActionResult == kAction_Failed)
    {
        if (ErrorCode == kPMSError_PeerNotAccept_NotCompatible)
            alterMessage =  @"New Version of firmware is avalible. Please update to the newest version or connect to another server.";
        else
            alterMessage = @"Login Failed";
    }
    if (alterMessage)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil	message:alterMessage delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
        [alertView show];
        
        // Irina alert times out in 2 min
        [self performSelector:@selector(dismiss:) withObject:alertView afterDelay:2];
        
        [alertView release];
    }
    

}

// Irina
-(void)dismiss:(UIAlertView*)x{
    [x dismissWithClickedButtonIndex:-1 animated:YES];
}

#pragma mark - Cloud action

- (void)accessDropBox
{
    // Pass any objects to the view controller here, like...
    DropboxBrowserViewController *dropboxBrowser = [[DropboxBrowserViewController alloc] init];
    
    dropboxBrowser.allowedFileTypes = @[@"doc", @"docx", @"ppt", @"pps", @"pptm", @"pptx", @"xls", @"xlc", @"xlm", @"xlw", @"xlsx", @"xlsm", @"pdf", @"txt", @"jpg", @"jpeg", @"jpeg-2000", @"tiff", @"pict", @"gif", @"png", @"qtif", @"icns", @"bmp", @"ico"]; // Uncomment to filter file types. Create an array of allowed types. To allow all file types simply don't set the property
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
- (void)accessPC
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

    PMPlayer_Error noerr = [[GUIModelService defaultModelService].m_FSServer Login:([GUIModelService defaultModelService]).m_AppSetting.m_FileServerRecord];
    

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
    
    fileShareBrowser.allowedFileTypes = @[@"doc", @"docx", @"ppt", @"pps", @"pptm", @"pptx", @"xls", @"xlc", @"xlm", @"xlw", @"xlsx", @"xlsm", @"pdf", @"txt", @"jpg", @"jpeg", @"jpeg-2000", @"tiff", @"pict", @"gif", @"png", @"qtif", @"icns", @"bmp", @"ico"];
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

#pragma mark - Sorting action

- (void)actionSortByA
{
    NSArray* ButtonArray;
    m_SortingType = kSortingType_ByAlphabet;
    m_CurrentSortButton = m_SortByTypeButton;
    
    // Irina
    //  ButtonArray = [[NSArray alloc] initWithObjects:m_CurrentSortButton, editButton, m_PCAccessButton, m_DropboxAccessButton, nil];

    ButtonArray = [[NSArray alloc] initWithObjects: editButton, m_DropboxAccessButton, nil];

    
    self.navigationItem.RightBarButtonItems = ButtonArray;
    NSArray *browserItems = [self browserItemsInDirectory:self.m_DocumentPath];
    [self updateBrowserItemsAndSignalDelegate:browserItems];
}
- (void)actionSortByType
{
    NSArray* ButtonArray;
    m_SortingType = kSortingType_ByType;
    m_CurrentSortButton = m_SortByAButton;
    
    // Irina
    ButtonArray = [[NSArray alloc] initWithObjects: editButton, m_DropboxAccessButton, nil];
    self.navigationItem.RightBarButtonItems = ButtonArray;
    NSArray *browserItems = [self browserItemsInDirectory:self.m_DocumentPath];
    [self updateBrowserItemsAndSignalDelegate:browserItems];
}

#pragma mark - DropboxBrowserDelegate

- (NSString*)getDropboxBrowserDownloadFolder:(DropboxBrowserViewController *)browser
{
    return self.m_DocumentPath;
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
    return self.m_DocumentPath;
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

@end
