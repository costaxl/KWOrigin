//
//  SharedPhotoUserCell.h
//  iFamios
//
//  Created by tywang on 14/5/26.
//
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWGridViewController.h"

@interface SharedPhotoUserCell : UICollectionViewCell
{
    
}

@property (nonatomic, weak) MWGridViewController *gridController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) id <MWPhoto> photo;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL isSelected;

- (void)displayImage;
@end
