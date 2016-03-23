
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AssetBrowserItem.h"
#import "MWPhotoProtocol.h"


@interface PhMPhotoItem : AssetBrowserItem <NSCopying, MWPhoto>
{
}

- (void)generateThumbnailAsynchronouslyWithSize:(CGSize)size fillMode:(AssetBrowserItemFillMode) mode completionHandler:(void (^)(UIImage *thumbnail))handler;


@end
