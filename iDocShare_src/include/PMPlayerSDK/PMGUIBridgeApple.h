//
//  PMGUIBridgeApple.h
//
//
#ifndef __PMGUIBridgeApple__
#define __PMGUIBridgeApple__

#import <Foundation/Foundation.h>
#import "PMGUIBridgeParentApple.h"

@interface PMGUIBridgeApple : PMGUIBridgeParentApple
{
#if !defined(_LP64) //  work around 32 bit compiler issues
    void *_m_pGUIBridge;
#endif

}
- (id) init;
- (id) initWithBridge:(void*) Bridge;
- (id) initWithBridge:(void*) Bridge parent:(PMGUIBridgeApple*) Parent;
- (void*)AddObserver:(NSString*)EventName Observer:(id)anObserver selector:(SEL)aSelector;
- (void)RemoveObserver:(NSString*)EventName Handle:(void*)theHandle;

@end
#endif
