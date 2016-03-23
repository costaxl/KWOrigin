//
//  GmailSetting.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/13.
//
//

#import <Foundation/Foundation.h>

@interface GmailSetting : NSObject <NSCoding>
{
    NSString *m_ID;
    NSString *m_Password;
}
@property (copy) NSString *ID;
@property (copy) NSString *Password;
@end
