//
//  PMFolderApple.h
//

#import <Foundation/Foundation.h>
#import "PMGUIBridgeApple.h"
#import "PMFolderInfoCollectorApple.h"

@interface PMFolderApple : PMGUIBridgeApple
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pFolder;
#endif
}

-(PMFolderInfoCollectorApple*) OpenFolder:(NSDictionary*)inData  ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;
-(void) CloseFolder:(id)anObserver ReturnSelector:(SEL)aSelector;
-(void) SetFullPathName:(NSString*)PathName;
-(NSString*) GetFullPathName;
// interface of PMGUIBridgeParentApple
- (bool) handleNotify:(NSDictionary*)Info;
@end
