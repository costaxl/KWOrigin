//
//  FileShareBrowserViewController.h
//
//

// Check for Objective-C Modules
#if __has_feature(objc_modules)
    // We recommend enabling Objective-C Modules in your project Build Settings for numerous benefits over regular #imports. Read more from the Modules documentation: http://clang.llvm.org/docs/Modules.html
    @import Foundation;
    @import UIKit;
    @import QuartzCore;
#else
    #import <Foundation/Foundation.h>
    #import <UIKit/UIKit.h>
    #import <QuartzCore/QuartzCore.h>
#endif
#import "PMFolderInfoCollectorApple.h"


/** @typedef kFSFileConflictError
 @abstract Error codes for file conflicts with Dropbox and Local files.
 @param kDBDropboxFileNewerError The Dropbox file was modified more recently than the local file, and is therefore newer.
 @param kDBDropboxFileOlderError The Dropbox file was modified after the local file, and is therefore older.
 @param kDBDropboxFileSameAsLocalFileError Both the Dropbox file and the local file were modified at the same time.
 @discussion These error codes are used with the \p FileShareBrowser:fileConflictWithLocalFile:withDropboxFile:withError: delegate method's error parameter. That delegate method is caled when there is a file conflict between a local file and a Dropbox file. */
typedef NS_ENUM(NSInteger, kFSFileConflictError) {
    /// The Dropbox file was modified more recently than the local file, and is therefore newer.
    kFileShareFileNewerError = 1,
    /// The Dropbox file was modified after the local file, and is therefore older.
    kFileShareFileOlderError = 2,
    /// Both the Dropbox file and the local file were modified at the same time.
    kFileShareFileSameAsLocalFileError = 3
};

@protocol FileShareBrowserDelegate;


@interface FileShareBrowserViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate>


- (instancetype)init;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;


/// Dropbox Delegate Property
@property (nonatomic, strong) id <FileShareBrowserDelegate> rootViewDelegate;


/// The current or most recently selected file name
@property (nonatomic, strong, readonly) NSString *currentFileName;

/// The current file path of the FileShareBrowserViewController
@property (nonatomic, strong, readonly) NSString *currentPath;


/// The list of files currently being displayed in the FileShareBrowserViewController
@property (nonatomic, copy, readwrite) NSMutableArray *fileList;

/// Allowed file types (like a filter). Create an array of allowed file extensions. Leave this property nil to allow all files.
@property (nonatomic, strong) NSArray *allowedFileTypes;


/// The tableview cell ID for dequeueing
@property (nonatomic, strong) NSString *tableCellID;

/// Download indicator in UINavigationBar to indicate progress of file download
@property (nonatomic, strong, readonly) UIProgressView *downloadProgressView;


/// Deliver notifications to the user about file downloads
@property (nonatomic, assign) BOOL deliverDownloadNotifications;

/// Display a search bar in the DropboxBrowser
@property (nonatomic, assign) BOOL shouldDisplaySearchBar;


/** Check if the current app is linked to Dropbox.
 @return YES if the current app is linked to Dropbox with a valid API Key, Secret, and User Account. NO if one or more of the API Key, Secret, or User Account is not valid. */
- (BOOL)isFileServerLinked;

/** Force a content update of the current directory. 
 @discussion This is usually not necessary because the DropboxSDK will asynchronously update content. Additionally, the DropboxBrowser supplies a Refresh Control to allow the user to force an update. However, there may be points when it is useful to force a content update of the current directory. */
- (void)updateContent;

/** Download a file from File server and specify whether or not it should be overwritten.
 @param file File name.
 @param replaceLocalVersion When set to YES, FileShareBrowser will overwrite any local version of the file without checking for conflicts. When set to NO, conflict handling will be preserved.
 @return YES if the download is successful. NO if the download fails. */
- (BOOL)downloadFile:(PMFolderEntryInfoApple *)file replaceLocalVersion:(BOOL)replaceLocalVersion;

/** Create a share link for a specifc file. 
 @param file File metadata from dropbox. 
 */
- (void)loadShareLinkForFile:(NSString *)file;

/** Logout of Dropbox and dismiss the DropboxBrowser.
 @discussion The current user will be signed out of Dropbox. This implicitly calls \p removeDropboxBrowser if the DropboxBrowser is presented. */
- (void)logoutOfFileServer;

/** Remove DropboxBrowser from the view hierarchy.
 @discussion Dismisses FileShareBrowserViewController from the view hierarchy. Do not attempt to call \p dismissViewControllerAnimated:completion: on the FileShareBrowserViewController before or after calling this method. When dismissed the appropriate method is sent to the delegate. */
- (void)removeFileShareBrowser;


@end



/// The DropboxBrowser Delegate can be used to recieve download notifications, failures, successes, errors, file conflicts, and even handle the download yourself.
@protocol FileShareBrowserDelegate <NSObject>

@optional

//----------------------------------------------------------------------------------------//
// Available Methods - Use these delegate methods for a variety of operations and events  //
//----------------------------------------------------------------------------------------//
/// Sent to the delegate if there was an error creating or loading share link
- (NSString*)getFileShareBrowserDownloadFolder:(FileShareBrowserViewController *)browser;

/// Sent to the delegate when there is a successful file download
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten;

/// Sent to the delegate if DropboxBrowser failed to download file from Dropbox
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser didFailToDownloadFile:(PMFolderEntryInfoApple *)file;

/// Sent to the delegate if the selected file already exists locally
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withFSFile:(PMFolderEntryInfoApple *)File withError:(NSError *)error;

/// Sent to the delegate when the user selects a file. Implementing this method will require you to download or manage the selection on your own. Otherwise, automatically downloads file if not implemented.
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser didSelectFile:(PMFolderEntryInfoApple *)file;

/// Sent to the delegate if the share link is successfully loaded
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser didLoadShareLink:(NSString *)link;

/// Sent to the delegate if there was an error creating or loading share link
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser didFailToLoadShareLinkWithError:(NSError *)error;

/// Sent to the delegate when a file download notification is delivered to the user. You can use this method to record the notification ID so you can clear the notification if ncessary.
- (void)FileShareBrowser:(FileShareBrowserViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification;

/// Sent to the delegate after the FileShareBrowserViewController is dismissed by the user - Do \b NOT use this method to dismiss the DropboxBrowser
- (void)FileShareBrowserDismissed:(FileShareBrowserViewController *)browser;


@end
