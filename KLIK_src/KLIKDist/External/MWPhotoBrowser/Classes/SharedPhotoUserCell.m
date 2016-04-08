//
//  SharedPhotoUserCell.m
//  iFamios
//
//  Created by tywang on 14/5/26.
//
//

#import "SharedPhotoUserCell.h"
#import "MWCommon.h"
#import "MWPhotoBrowserPrivate.h"
#import "DACircularProgressView.h"
#import "CustomBadge.h"

@interface SharedPhotoUserCell ()
{
    
    UIImageView *_imageView;
    UIImageView *_loadingError;
	DACircularProgressView *_loadingIndicator;
    CustomBadge *_customBadge;
    UILabel *_label;
    
}

@end

@implementation SharedPhotoUserCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        // Grey background
        self.backgroundColor = [UIColor whiteColor];//[UIColor colorWithWhite:0.12 alpha:1];
        
        int imgHeight = self.bounds.size.height * (4/5);
        int labelHeight = self.bounds.size.height * (1/5);
        // Image
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake(0, 0, imgHeight, imgHeight);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
        
        
        // custom badge
       _customBadge = [CustomBadge customBadgeWithString:@"0" withStringColor:[UIColor whiteColor] withInsetColor:[UIColor redColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor whiteColor] withScale:1.0 withShining:YES];
        _customBadge.hidden = YES;
        _customBadge.frame = CGRectMake(0, 0, 44, 44);
        [self addSubview:_customBadge];

		// Loading indicator
		_loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 40.0f)];
        _loadingIndicator.userInteractionEnabled = NO;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            _loadingIndicator.thicknessRatio = 0.1;
            _loadingIndicator.roundedCorners = NO;
        } else {
            _loadingIndicator.thicknessRatio = 0.2;
            _loadingIndicator.roundedCorners = YES;
        }
		[self addSubview:_loadingIndicator];
        
        // Name label
        _label = [UILabel new];
        
        _label.frame = CGRectMake(0, 0, self.bounds.size.width, labelHeight);
        [_label setTextColor:[UIColor blackColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];

        // Listen for photo loading notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setProgressFromNotification:)
                                                     name:MWPHOTO_PROGRESS_NOTIFICATION
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                     name:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect test = self.bounds;
    int imgHeight = floorf(self.bounds.size.height * 0.8);
    int labelHeight =  self.bounds.size.height - imgHeight;
    int imgOff_x = floorf((self.bounds.size.width - imgHeight)/2);
    _imageView.frame = CGRectMake(imgOff_x, labelHeight, imgHeight, imgHeight);
    _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                         _loadingIndicator.frame.size.width,
                                         _loadingIndicator.frame.size.height);
    
    _customBadge.frame = CGRectMake(floorf(imgOff_x+imgHeight - _customBadge.frame.size.width/2),
                                       floorf(labelHeight - _customBadge.frame.size.height/2), _customBadge.frame.size.width, _customBadge.frame.size.height);
     _label.frame = CGRectMake(0, 0, self.bounds.size.width, labelHeight);
}

#pragma mark - Cell

- (void)prepareForReuse {
    _photo = nil;
    _gridController = nil;
    _imageView.image = nil;
    _loadingIndicator.progress = 0;
    _customBadge.hidden = YES;
    _label.text = nil;
    [self hideImageFailure];
    [super prepareForReuse];
}

#pragma mark - Image Handling

- (void)setPhoto:(id <MWPhoto>)photo {
    _photo = photo;
    if (_photo)
    {
        if (![_photo underlyingImage])
        {
            [self showLoadingIndicator];
        }
        else
        {
            [self hideLoadingIndicator];
        }
        _label.text = [photo caption];
        int count = [photo GetCountInfo];
        if (count>0)
        {
            [_customBadge autoBadgeSizeWithString:[NSString stringWithFormat:@"%d", count]];
            _customBadge.hidden = NO;
            
        }
    }
    else
    {
        [self showImageFailure];
    }
}

- (void)displayImage {
    _imageView.image = [_photo underlyingImage];
    [self hideImageFailure];
}

#pragma mark - Selection

- (void)setSelectionMode:(BOOL)selectionMode {
    _selectionMode = selectionMode;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
}

- (void)selectionButtonPressed {
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 0.6;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark Indicators

- (void)hideLoadingIndicator {
    _loadingIndicator.hidden = YES;
}

- (void)showLoadingIndicator {
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
    [self hideImageFailure];
}

- (void)showImageFailure {
    if (!_loadingError) {
        _loadingError = [UIImageView new];
        _loadingError.image = [UIImage imageNamed:@"MWPhotoBrowser.bundle/images/ImageError.png"];
        _loadingError.userInteractionEnabled = NO;
        [_loadingError sizeToFit];
        [self addSubview:_loadingError];
    }
    [self hideLoadingIndicator];
    _imageView.image = nil;
    _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                     floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                     _loadingError.frame.size.width,
                                     _loadingError.frame.size.height);
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

#pragma mark - Notifications

- (void)setProgressFromNotification:(NSNotification *)notification {
    NSDictionary *dict = [notification object];
    id <MWPhoto> photoWithProgress = [dict objectForKey:@"photo"];
    if (photoWithProgress == _photo) {
        //        NSLog(@"%f", [[dict valueForKey:@"progress"] floatValue]);
        float progress = [[dict valueForKey:@"progress"] floatValue];
        _loadingIndicator.progress = MAX(MIN(1, progress), 0);
    }
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <MWPhoto> photo = [notification object];
    if (photo == _photo) {
        if ([photo underlyingImage]) {
            // Successful load
            [self displayImage];
        } else {
            // Failed to load
            [self showImageFailure];
        }
        [self hideLoadingIndicator];
    }
}


@end
