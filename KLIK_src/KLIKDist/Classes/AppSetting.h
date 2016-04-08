//
//  AppSetting.h
//

#import <Foundation/Foundation.h>
#import "BelongingsManagerApple.h"

#if defined(IOS)
@interface AppSetting : NSObject <NSCoding>
#else
@interface AppSetting : NSObject
#endif
{
}

@property (copy) BelongingsRecordApple *m_FileServerRecord;
@property (copy) BelongingsRecordApple *m_ScreenShareServerRecord;

#if defined (IOS)
- (id)initWithCoder:(NSKeyedUnarchiver *)coder;
- (void)encodeWithCoder:(NSKeyedArchiver *)coder;
#endif

@end
