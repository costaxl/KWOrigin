//
//  ALAsset+Reorder.m
//  iDocShare
//
//  Created by tywang on 2014/10/28.
//
//

#import "ALAsset+Reorder.h"

@implementation ALAsset (Reorder)
- (NSDate *) date
{
    return [self valueForProperty:ALAssetPropertyDate];
}
@end
