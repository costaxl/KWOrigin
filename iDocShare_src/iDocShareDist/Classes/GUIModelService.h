//
//  GUIModelService.h
//
//

#import <Foundation/Foundation.h>
#import "GUIPeerManager.h"
#import "PMPlayerAppleTranslator.h"
#import "AppSetting.h"
#import "NSSServer.h"
#import "FSServer.h"

@protocol GUIAppService <NSObject>
- (PMPlayer_Error)PlayMedia:(BelongingsRecordApple*) Record;
- (void)StopMedia;
- (PMPlayer_Error)Connect:(BelongingsRecordApple*)Record withPBC:(NSString*) PBCName;
- (void)Disconnect;
- (CommandManagerApple*) GetCommandManager;
- (NSArray*) GetPlaybackControllers;
- (void) LockTab;
- (void) UnlockTab;
@end

enum
{
    // presentable view will present
    kNSSPresentState_WillPresent,
    kNSSPresentState_Present,
    kNSSPresentState_WillAbsent,
    // presentable view is absent
    kNSSPresentState_Absent
};

extern NSString * const NSSPresentStateDidChangeNotification;


@interface GUIModelService : NSObject
{
}
@property (atomic,strong) GUIPeerManager *m_PeerManager;
@property (atomic,strong) NSSServer *m_NSSserver;
@property (atomic,strong) FSServer *m_FSServer;

@property (nonatomic, retain) id<GUIAppService> m_AppService;
@property (atomic,strong) AppSetting *m_AppSetting;


+(GUIModelService*) defaultModelService;
- (void)SaveSetting;

- (void)SaveSetting:(AppSetting*)Setting;
- (BOOL)LoadSetting;

@end
