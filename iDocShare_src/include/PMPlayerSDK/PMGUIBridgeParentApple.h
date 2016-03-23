//
//  PMGUIBridgeParentApple.h
//
//

#ifndef __PMGUIBridgeParentApple__
#define __PMGUIBridgeParentApple__
#import <Foundation/Foundation.h>

// scope of life-cycle -> child need to be dealloc before parent
@interface PMGUIBridgeParentApple : NSObject
{
}
- (id) init;
- (id) initWithParent:(PMGUIBridgeParentApple*) parentBridge;
- (PMGUIBridgeParentApple*) GetParent;
// send notify to children
- (void) SendNotify:(NSDictionary*)Info;
// return true, if need to continue the event flow
- (bool) onNotify:(NSDictionary*)Info;
// implement by inherited class
- (bool) handleNotify:(NSDictionary*)Info;
@end


#endif 
