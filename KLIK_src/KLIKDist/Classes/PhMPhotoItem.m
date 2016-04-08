
#import "PhMPhotoItem.h"


@interface PhMPhotoItem ()
{
    BOOL _loadingInProgress;

}
@end

@implementation PhMPhotoItem
@synthesize underlyingImage = _underlyingImage; // synth property from protocol


- (void)generateThumbnailAsynchronouslyWithSize:(CGSize)size fillMode:(AssetBrowserItemFillMode)mode completionHandler:(void (^)(UIImage *thumbnail))handler
{
    [super generateThumbnailAsynchronouslyWithSize:size fillMode:mode completionHandler:^(UIImage *thumbnail)
    {
        self.underlyingImage = thumbnail;
        
        [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
        
        if (handler) {
			handler(thumbnail);
		}

    }];
}


- (void)loadUnderlyingImageAndNotify
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try
    {
        if (self.underlyingImage)
        {
            [self imageLoadingComplete];
        }
        else
        {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify
{
    
    // Get underlying image
    if (self.thumbnailImage)
    {
        // We have UIImage!
        self.underlyingImage = self.thumbnailImage;
        [self imageLoadingComplete];
        
    }
    else
    {
        //NSLog(@"performLoadUnderlyingImageAndNotify - do nothing!!!");
    }
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
	self.underlyingImage = nil;
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelAnyLoading
{
}

@end
