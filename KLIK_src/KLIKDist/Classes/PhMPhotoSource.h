
#import <Foundation/Foundation.h>

#import "PhMPhotoItem.h"
#import "AssetBrowserSource.h"


@interface PhMPhotoSource : AssetBrowserSource
{
}

+ (id)assetBrowserSourceOfType:(AssetBrowserSourceType)sourceType;
- (id)initWithSourceType:(AssetBrowserSourceType)sourceType;

- (void)buildSourceLibrary;
- (AssetBrowserItem*) newAssetBrowserItem:(NSURL*)URL title:(NSString*)title;
- (AssetBrowserItem*) newAssetBrowserItem:(NSURL*)URL;
- (NSString*) getFileSharingDirectory;

@end

