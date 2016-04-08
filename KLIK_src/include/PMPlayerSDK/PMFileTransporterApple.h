//
//  PMFileTransporterApple.h
//

#import <Foundation/Foundation.h>
#import "PMGUIBridgeApple.h"
#import "PMFolderInfoCollectorApple.h"
#import "PMTaskObserverApple.h"
#import "PMFolderApple.h"

@interface PMFileTransporterApple : PMGUIBridgeApple
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pFileTransporter;
    void* _m_pSignalReceiver;

#endif
}
-(PMFolderApple*) GetFolder:(NSString*)FolderPath ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;
-(void) ReturnFolder:(PMFolderApple*)FolderApple ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;
-(void) DownloadFile:(NSString*)TargetFilePath destFolder:(NSString*)DestFolderPath observer:(PMTaskObserverApple*) Observer;
-(void) CancelDownloadFile:(uint32_t) Handle;
// interface of PMGUIBridgeParentApple
- (bool) handleNotify:(NSDictionary*)Info;
// overload the interface of PMGUIBridgeApple
- (id) initWithBridge:(void*) Bridge parent:(PMGUIBridgeApple*) Parent;

@end
