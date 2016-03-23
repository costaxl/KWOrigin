//
//  NSSServer.h
//  iDocShare
//
//  Created by tywang on 2014/12/19.
//
//

#import <Foundation/Foundation.h>
#import "PMSystem.h"
#import "NSSCommandDefs.h"

enum
{
    kNSSServer_In,
    kNSSServer_Out,
    kNSSServer_LoginProgress,
    kNSSServer_LogoutProgress
};
enum
{
    kNSSServer_ScreenMirror_Init,
    kNSSServer_ScreenMirrorPreparing,
    kNSSServer_ScreenMirroring,
    kNSSServer_ScreenMirrorStopping,
    kNSSServer_ScreenMirrorNone
};

enum
{
    kNSSServer_Mode_Basic,
    kNSSServer_Mode_ConferenceControl
};

// operate resources in GUI thread
@interface NSSServer : NSObject
{
}
- (PMSystem*) GetPMSystem;
// connect to NSS server and login
- (PMPlayer_Error)Login:(BelongingsRecordApple*)Record;
// disconnect/logout current connected server
- (void)Logout;
// Start mirroring screen to nssserver
- (int)StartScreenMirror;
// stop mirroring screen to nssserver
- (int)StopScreenMirror;
- (int)ChangeVideoDimension:(int)Width height:(int)Height;
// EnableBlankView - as enabled, send blank view to NSSServer
- (void) EnableBlankView:(bool)enable;

//Send status change notification via KVO mechanism, assume status change in GUI thread
@property (assign) int Status;
@property (assign) int ScreenMirrorStatus;
@property (assign) int m_Mode;
@property (assign) bool m_bAdmin;

@end
