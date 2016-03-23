//
//  ServerCell.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/23.
//
//

#import <Foundation/Foundation.h>

@interface ServerCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel *serverName;
@property(nonatomic, strong) IBOutlet UILabel *serverIPAddress;
@property(nonatomic, strong) IBOutlet UIImageView *curentFeature;
@property(nonatomic, strong) IBOutlet UIImageView *desktopFeature;
@property(nonatomic, strong) IBOutlet UIImageView *camFeature;
@property(nonatomic, strong) IBOutlet UIImageView *captureDeviceFeature;
@end
