/*
     File: AssetBrowserSource.m
 Abstract: Represents a source like the camera roll and vends AssetBrowserItems.
  Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011-2013 Apple Inc. All Rights Reserved.
 
*/

#import "AssetBrowserSource.h"

#import "DirectoryWatcher.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAsset+Reorder.h"



@interface AssetBrowserSource () <DirectoryWatcherDelegate>
{
    NSArray* m_Groups;
    bool m_bGrouping;
}

@property (nonatomic, copy) NSArray *items; // NSArray of AssetBrowserItems
@property (nonatomic, copy) NSArray *dateGroups; // NSArray of AssetBrowserItems
-(AssetDateGroup*) findGroup:(NSMutableArray*) TargetGroup compareDate:(NSDate*)date;

@end


@implementation AssetDateGroup
-(id) initWithDate:(NSDate*) date
{
    self = [super init];
    if (self == nil)
        return nil;
    
    Date = [date copy];
    Items = [NSMutableArray new];
    UserData1 = nil;
    UserData2 = nil;

    return self;
}
- (void)dealloc
{
    if (Date)
        [Date dealloc];
    if (Items)
    {
        [Items dealloc];
    }
    if (UserData1)
        [UserData1 dealloc];
    if (UserData2)
        [UserData2 dealloc];
  
    [super dealloc];
}
@end


@implementation AssetBrowserSource

@synthesize name = sourceName, items = assetBrowserItems, delegate, type = sourceType;
@synthesize GroupingByDate = m_bGrouping;
@synthesize dateGroups = m_Groups;

- (NSString*)nameForSourceType
{
	NSString *name = nil;
	
	switch (sourceType) {
		case AssetBrowserSourceTypeFileSharing:
			name = NSLocalizedString(@"File Sharing", nil);
			break;
		case AssetBrowserSourceTypeCameraRoll:
			name = NSLocalizedString(@"Camera Roll", nil);
			break;
		case AssetBrowserSourceTypeIPodLibrary:
			name = NSLocalizedString(@"iPod Library", nil);
			break;
		default:
			name = nil;
			break;
	}
	
	return name;
}

+ (AssetBrowserSource*)assetBrowserSourceOfType:(AssetBrowserSourceType)sourceType
{
	return [[[self alloc] initWithSourceType:sourceType] autorelease];
}

- (id)initWithSourceType:(AssetBrowserSourceType)type
{
	if ((self = [super init])) {
		sourceType = type;
		sourceName = [[self nameForSourceType] retain];
		assetBrowserItems = [[NSArray array] retain];
		
		enumerationQueue = dispatch_queue_create("Browser Enumeration Queue", DISPATCH_QUEUE_SERIAL);
		dispatch_set_target_queue(enumerationQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        
        m_bGrouping = false;
        m_Groups = nil;
	}
	return self;
}

- (void)updateBrowserItemsAndSignalDelegate:(NSArray*)newItems dateGroup:(NSArray*)newGroups
{
    
	self.items = newItems;
    self.dateGroups = newGroups;
//    if (m_bGrouping)
//    {
//        
//        if (m_Groups)
//            [m_Groups dealloc];
//        m_Groups = nil;
//        m_Groups = newGroups;
//    }
//
	/* Ideally we would reuse the AssetBrowserItems which remain unchanged between updates.
	 This could be done by maintaining a dictionary of assetURLs -> AssetBrowserItems.
	 This would also allow us to more easily tell our delegate which indices were added/removed
	 so that it could animate the table view updates. */
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(assetBrowserSourceItemsDidChange:)]) {
		[self.delegate assetBrowserSourceItemsDidChange:self];
	}
}

- (void)dealloc 
{	
	[sourceName release];
	[assetBrowserItems release];
	
	if (receivingIPodLibraryNotifications) {
		MPMediaLibrary *iPodLibrary = [MPMediaLibrary defaultMediaLibrary];
		[iPodLibrary endGeneratingLibraryChangeNotifications];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMediaLibraryDidChangeNotification object:nil];
	}
	dispatch_release(enumerationQueue);
	
	if (assetsLibrary) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];	
		[assetsLibrary release];
	}
	
	[directoryWatcher invalidate];
	directoryWatcher.delegate = nil;
	[directoryWatcher release];
	
	[super dealloc];
}

- (void)buildSourceLibrary
{
	if (haveBuiltSourceLibrary)
		return;
	
	switch (sourceType) {
		case AssetBrowserSourceTypeFileSharing:
			[self buildFileSharingLibrary];
			break;
		case AssetBrowserSourceTypeCameraRoll:
			[self buildAssetsLibrary];
			break;
		case AssetBrowserSourceTypeIPodLibrary:
			[self buildIPodLibrary];
			break;
		default:
			break;
	}
	
	haveBuiltSourceLibrary = YES;
}
- (AssetBrowserItem*) newAssetBrowserItem:(NSURL*)URL title:(NSString*)title
{
    return [[AssetBrowserItem alloc] initWithURL:URL title:title];
}
- (AssetBrowserItem*) newAssetBrowserItem:(NSURL*)URL
{
    return [[AssetBrowserItem alloc] initWithURL:URL];
}

- (NSString*) getFileSharingDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

#pragma mark -
#pragma mark iPod Library

- (void)updateIPodLibrary
{
	dispatch_async(enumerationQueue, ^(void) {
		// Grab videos from the iPod Library
		MPMediaQuery *videoQuery = [[MPMediaQuery alloc] init];
		
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
		NSArray *mediaItems = [videoQuery items];
		for (MPMediaItem *mediaItem in mediaItems) {
			NSURL *URL = (NSURL*)[mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
			
			if (URL) {
				NSString *title = (NSString*)[mediaItem valueForProperty:MPMediaItemPropertyTitle];
				AssetBrowserItem *item = [self newAssetBrowserItem:URL title:title];
				[items addObject:item];
				[item release];
			}
		}
		[videoQuery release];
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self updateBrowserItemsAndSignalDelegate:items];
		});
	});
}

- (void)iPodLibraryDidChange:(NSNotification*)changeNotification
{
	[self updateIPodLibrary];
}

- (void)buildIPodLibrary
{
	MPMediaLibrary *iPodLibrary = [MPMediaLibrary defaultMediaLibrary];
	receivingIPodLibraryNotifications = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iPodLibraryDidChange:) 
												 name:MPMediaLibraryDidChangeNotification object:nil];
	[iPodLibrary beginGeneratingLibraryChangeNotifications];
	
	[self updateIPodLibrary];	
}

#pragma mark -
#pragma mark Assets Library

- (void)updateAssetsLibrary
{
	NSMutableArray *assetItems = [NSMutableArray arrayWithCapacity:0];
	ALAssetsLibrary *assetLibrary = assetsLibrary;
    NSMutableArray *DateGroups = [NSMutableArray arrayWithCapacity:0];
	__block NSMutableArray *tmpAssets = [@[] mutableCopy];
    __block NSMutableArray *orderAssets = [@[] mutableCopy];
    
    // retrieve asset only from camera roll
	[assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		 if (group) {
			 //[group setAssetsFilter:[ALAssetsFilter allVideos]];
			 [group setAssetsFilter:[ALAssetsFilter allPhotos]];
			 //[group enumerateAssetsWithOptions:NSEnumerationReverse /*enumerateAssetsUsingBlock*/ usingBlock:
              [group enumerateAssetsUsingBlock:
			  ^(ALAsset *asset, NSUInteger index, BOOL *stopIt)
			  {
				  if (asset)
                  {
					  ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                      if (!defaultRepresentation)
                          return;
                      
                      [tmpAssets addObject:asset];
                      
				  }
			  }];
		 }
		// group == nil signals we are done iterating.
		else {
            // sorting and grouping
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
            orderAssets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
            for (ALAsset* asset in orderAssets)
            {
                ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                NSString *uti = [defaultRepresentation UTI];
                if(![[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
                    continue;
                NSURL *URL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                NSString *title = [NSString stringWithFormat:@"%@ %i", NSLocalizedString(@"Video", nil), [assetItems count]+1];
                //NSLog(@"asset url:%@, uti:%@", URL, uti);
                if (URL==nil)
                    continue;
                AssetBrowserItem *item = [[self newAssetBrowserItem:URL title:title] autorelease];
                if (m_bGrouping)
                {
                    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
                    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
                    NSCalendar* calendar = [NSCalendar currentCalendar];
                    
                    NSDateComponents* components = [calendar components:flags fromDate:date];
                    
                    NSDate* dateOnly = [calendar dateFromComponents:components];
                    [self LogDate:dateOnly];
                    AssetDateGroup* DateGroup = [self findGroup:DateGroups compareDate:dateOnly];
                    [DateGroup->Items addObject:item];
                }
                
                [assetItems addObject:item];

            }
            
			dispatch_async(dispatch_get_main_queue(), ^{
                
				[self updateBrowserItemsAndSignalDelegate:assetItems dateGroup:DateGroups];
			});
		}
	}
	failureBlock:^(NSError *error) {
		NSLog(@"error enumerating AssetLibrary groups %@\n", error);
	}];
}
- (void)LogDate:(NSDate*)date
{
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    NSString* formateString = [formatter stringFromDate:date];
    NSLog(@"Date - %@", formateString);

}

- (void)assetsLibraryDidChange:(NSNotification*)changeNotification
{
	[self updateAssetsLibrary];
}

- (void)buildAssetsLibrary
{
	assetsLibrary = [[ALAssetsLibrary alloc] init];
	ALAssetsLibrary *notificationSender = nil;
	
	NSString *minimumSystemVersion = @"4.1";
	NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
	if ([systemVersion compare:minimumSystemVersion options:NSNumericSearch] != NSOrderedAscending)
		notificationSender = assetsLibrary;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryDidChange:) 
												 name:ALAssetsLibraryChangedNotification object:notificationSender];
	[self updateAssetsLibrary];
}
-(AssetDateGroup*) findGroup:(NSMutableArray*) TargetGroup compareDate:(NSDate*)date;
{
    bool bFound = false;
    AssetDateGroup* pSameGroup = nil;
    for (AssetDateGroup* DateGroup in TargetGroup)
    {
        if ([date compare:DateGroup->Date] == NSOrderedSame)
        {
            bFound = true;
            pSameGroup = DateGroup;
            break;
        }
    }
    
    if (bFound)
        return pSameGroup;
    // not found, new one with the date
    AssetDateGroup* newGroup = [[AssetDateGroup alloc] initWithDate:date];
    [TargetGroup addObject:newGroup];
    return newGroup;
}
#pragma mark -
#pragma mark iTunes File Sharing

- (NSArray*)browserItemsInDirectory:(NSString*)directoryPath
{
	NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *DateGroups = [NSMutableArray arrayWithCapacity:0];
    NSFileManager* fileManager = [[[NSFileManager alloc] init] autorelease];
	NSArray *subPaths = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
	if (subPaths) {
		for (NSString *subPath in subPaths) {
			NSString *pathExtension = [subPath pathExtension];
			CFStringRef preferredUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)pathExtension, NULL);
            // test file type
			BOOL fileConformsToUTI;
            // audio or video type
            fileConformsToUTI = UTTypeConformsTo(preferredUTI, kUTTypeAudiovisualContent);
            if (!fileConformsToUTI)
                fileConformsToUTI = UTTypeConformsTo(preferredUTI, kUTTypeImage);
            
			CFRelease(preferredUTI);
			NSString *path = [directoryPath stringByAppendingPathComponent:subPath];
			
			if (fileConformsToUTI) {
				[paths addObject:path];
			}
		}
	}
	
	NSMutableArray *browserItems = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *tempItems = [NSMutableArray arrayWithCapacity:0];
	for (NSString *path in paths)
    {
		AssetBrowserItem *item = [[self newAssetBrowserItem:[NSURL fileURLWithPath:path] ] autorelease];
		[tempItems addObject:item];
        //[browserItems addObject:item];
        
//        if (m_bGrouping)
//        {
//            NSDictionary* attrs = [fileManager attributesOfItemAtPath:path error:nil];
//
//            NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
//            unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//            NSCalendar* calendar = [NSCalendar currentCalendar];
//            
//            NSDateComponents* components = [calendar components:flags fromDate:date];
//            
//            NSDate* dateOnly = [calendar dateFromComponents:components];
//            AssetDateGroup* DateGroup = [self findGroup:DateGroups compareDate:dateOnly];
//            [DateGroup->Items addObject:item];
//        }
	}
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    browserItems = [tempItems sortedArrayUsingDescriptors:@[sort]];
    if (m_bGrouping)
    {
        for (AssetBrowserItem* item in browserItems)
        {
            NSDate *date = [item date];
            unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
            NSCalendar* calendar = [NSCalendar currentCalendar];
            
            NSDateComponents* components = [calendar components:flags fromDate:date];
            
            NSDate* dateOnly = [calendar dateFromComponents:components];
            AssetDateGroup* DateGroup = [self findGroup:DateGroups compareDate:dateOnly];
            [DateGroup->Items addObject:item];

        }

    }

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self updateBrowserItemsAndSignalDelegate:browserItems  dateGroup:DateGroups];
    });
	return browserItems;
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	NSString *documentsDirectory = [self getFileSharingDirectory];
	dispatch_async(enumerationQueue, ^(void) {
		NSArray *browserItems = [self browserItemsInDirectory:documentsDirectory];
//		dispatch_async(dispatch_get_main_queue(), ^(void) {
//			[self updateBrowserItemsAndSignalDelegate:browserItems];
//		});
	});
}

- (void)buildFileSharingLibrary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *documentsDirectory = [self getFileSharingDirectory];
    
    if ([fileManager fileExistsAtPath:documentsDirectory] == NO)
    {
        // create dir
        [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
    }

	NSArray *browserItems = [self browserItemsInDirectory:documentsDirectory];
	//[self updateBrowserItemsAndSignalDelegate:browserItems];
	directoryWatcher = [[DirectoryWatcher watchFolderWithPath:documentsDirectory delegate:self] retain];
}


@end
