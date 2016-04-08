//
//  GmailSetting.m
//  PMPlayer
//
//  Created by James_hsieh on 12/8/13.
//
//

#import "GmailSetting.h"

@implementation GmailSetting

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:m_ID forKey:@"MY_ID"];
    [aCoder encodeObject:m_Password forKey:@"MY_PASSWORD"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self =[super init];
    if(self)
    {
        m_ID = [aDecoder decodeObjectForKey:@"MY_ID"];
        m_Password=[aDecoder decodeObjectForKey:@"MY_PASSWORD"];
        self.ID = m_ID;
        self.Password = m_Password;
    }
    return self;
}

- (NSString*)ID
{
    return [[NSString alloc] initWithString:m_ID];
}
- (void)setID:(NSString*)value
{
   m_ID = [[NSString alloc] initWithString:value];
}

- (NSString*)Password
{
    return [[NSString alloc] initWithString:m_Password];
}
- (void)setPassword:(NSString*)value
{
    m_Password = [[NSString alloc] initWithString:value];
}
@end


