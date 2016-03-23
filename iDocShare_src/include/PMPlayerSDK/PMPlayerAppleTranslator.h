//
//  PMPlayerAppleTranslator.h

#import <Foundation/Foundation.h>
#import "BelongingsManagerApple.h"
#import "CommandManagerApple.h"
#import "PMDisplayViewManagerApple.h"
#import "PMLiveDomainApple.h"
#include "PMPlayerCommonTypes.h"

@interface PMVariantApple : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void *_m_pVariant;
#endif

}
@property (readonly) uint32_t intValue;
@property (readonly) bool boolValue;
@property (readonly)void* ptrValue;
-(id) initWithint:(uint32_t)Value;
-(id) initWithbool:(bool)Value;
-(id) initWithptr:(void*)Value;
@end


@interface PMPlayerAppleTranslator : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pPMPlayer;
    void* _m_pPlayerExecThread;
    void* _m_pBelongingsManager;
    void* _m_pCommandManager;
    void* _m_pDisplayViewManager;

#endif
}
// Test for the same machine
-(void) SetHostName:(NSString*) hostName;
// Login live domain
-(void) LoginDomain:(NSString*) DomainName aUserName:(NSString*) UserName aPassword:(NSString*) Password aNotificationStatus:(NSString*) NotificationStatus;
-(void) LogoutDomain:(NSString*) DomainName;
-(PMLiveDomainApple*) GetDomain:(NSString*) DomainName  aNotificationStatus:(NSString*) NotificationStatus;
-(bool) Command:(int)cmd  Value:(PMVariantApple*) value;

// ******* One-Many Set of interface *********
// Desc : use the set of interface. The client app using it can have only one pbc/feature, and server app using it can have many incoming pbc/features
// Note : can not use with Many-Many Set of interface
-(PMPlayer_Error) PlayMedia:(BelongingsRecordApple*)Belongings;
-(PMPlayer_Error) PlayMedia:(BelongingsRecordApple*)Belongings withPlayback:(NSString*)PlaybackName;
-(void) StopMedia;
-(void) SuspendMedia;
-(void) ResumeMedia;
// ******* One-Many Set of interface *********

// ******* Many-Many Set of interface *********
// Desc : use the set of interface. The client app using it can have many outgoing pbc/feature, and server app using it can have many incoming pbc/features
// Note : can not use with Many-Many Set of interface
// Connect : connect to peer and get PBC to control the playback
-(PMPlayer_Error) Connect:(BelongingsRecordApple*)Belongings withPlayback:(NSString*)PlaybackName returnPBC:(void**) pPBC;
-(void) Disconnect:(void*)PBC;
// ******* Many-Many Set of interface *********

// Broadcast media interface
-(PMPlayer_Error) BroadcastMedia:(PMLiveDomainGroupApple*) DomainGroup;


-(bool) StartService;
-(void) StopService;
-(BelongingsManagerApple*) GetBelongingsManager;
-(CommandManagerApple*) GetCommandManager;
-(PMDisplayViewManagerApple*) GetDisplayViewManager;
-(NSArray*) GetPlaybackControllers;

@end
