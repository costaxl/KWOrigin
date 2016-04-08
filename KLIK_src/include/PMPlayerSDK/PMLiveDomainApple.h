//
//  PMLiveDomainApple.h
//

#ifndef _PMLiveDomainApple_h
#define _PMLiveDomainApple_h
#import <Foundation/Foundation.h>
#import "BelongingsManagerApple.h"

@interface DomainAccountInfo : NSObject
{
@public
    NSString* UserName;
    NSString* Password;
}
@property (copy) NSString*	UserName;
@property (copy) NSString*	Password;

@end

@class PMLiveDomainGroupApple;

@interface PMLiveDomainApple : NSObject
{
    NSString* m_UserName;
    NSString* m_Password;
#if !defined(_LP64) //  work around 32 bit compiler issues
    void* _m_pLiveDomain;
#endif

}
- (id) init:(void*) LiveDomain;
- (void) Login:(NSString*) UserName aPassword:(NSString*) Password;
- (void) Login:(DomainAccountInfo*)AccountInfo;
- (void) Logout;
- (bool) IsLogined;

- (PMLiveDomainGroupApple*) NewGroup:(NSString*)GroupType;
@end


@interface PMLiveDomainGroupApple : NSObject
{
#if !defined(_LP64) //  work around 32 bit compiler issues
    void* _m_pLiveDomainGroup;
#endif
    
}
- (id) init:(void*) LiveDomainGroup;
-(bool) AddMember:(BelongingsRecordApple*)Record;
-(void) RemoveMember:(BelongingsRecordApple*)Record;
-(bool) GetCommonProperties:(BelongingsRecordApple*)Record;
-(bool) SetCommonProperties:(BelongingsRecordApple*)Record;
@end


#endif
