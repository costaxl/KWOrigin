//
//  FeaturePickerViewController.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/20.
//
//

#import <UIKit/UIKit.h>
@class FeaturePickerViewController;

@protocol FeaturePickerViewControllerDelegate <NSObject>
-(void)featurePickerViewController:(FeaturePickerViewController *)controller didSelectFeature:(NSString *)theFeature;
@end

@interface FeaturePickerViewController : UITableViewController
{
    NSMutableArray *features;
    NSUInteger selectedIndex;
}
@property (nonatomic,retain) id <FeaturePickerViewControllerDelegate> delegate;
@property (nonatomic,strong) NSString *feature;
@property (nonatomic) NSInteger supportfeature;

@end
