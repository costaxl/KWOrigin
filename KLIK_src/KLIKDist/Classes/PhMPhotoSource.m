
#import "PhMPhotoSource.h"

#import "DirectoryWatcher.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
//static NSString* g_PhotoPath = @"Photo";
static NSString* g_PhotoPath = @".";


@interface PhMPhotoSource ()

@end


@implementation PhMPhotoSource

+ (id)assetBrowserSourceOfType:(AssetBrowserSourceType)sourceType
{
	return [[self alloc] initWithSourceType:sourceType];
}

- (id)initWithSourceType:(AssetBrowserSourceType)type
{
    if (self != [super initWithSourceType:type])
        return self;
    
    
	return self;
}


- (void)dealloc 
{	

	[super dealloc];
}

- (void)buildSourceLibrary
{
    [super buildSourceLibrary];
}

- (AssetBrowserItem*) newAssetBrowserItem:(NSURL*)URL title:(NSString*)title
{
    return [[PhMPhotoItem alloc] initWithURL:URL title:title];
}
- (AssetBrowserItem*) newAssetBrowserItem:(NSURL*)URL
{
    return [[PhMPhotoItem alloc] initWithURL:URL];
}
- (NSString*) getFileSharingDirectory
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:g_PhotoPath];
}

@end
