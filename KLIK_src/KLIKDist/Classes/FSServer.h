//
//  FSServer.h
//  iDocShare
//
//  Created by tywang on 2014/12/19.
//
//

#import <Foundation/Foundation.h>
#import "PMSystem.h"
#import "NSSCommandDefs.h"
#import "PMPBCAppleTranslator.h"
enum
{
    kFSServer_Init,
    kFSServer_In,
    kFSServer_Out,
    kFSServer_LoginProgress,
    kFSServer_LogoutProgress
};

// operate resources in GUI thread
@interface FSServer : NSObject
{
}
- (PMSystem*) GetPMSystem;
// connect to NSS server and login
- (PMPlayer_Error)Login:(BelongingsRecordApple*)Record;
// disconnect/logout current connected server
- (void)Logout;

//Send status change notification via KVO mechanism, assume status change in GUI thread
@property (assign) int Status;
@property (atomic, readonly) PMPBCAppleTranslator* FileSharePBC;

@end
