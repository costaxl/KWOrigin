//
//  CommandManagerApple.h
//  PMPlayerMac
//
//  Created by tywang on 12/12/12.
//
//

#ifndef _CommandManagerApple_h
#define _CommandManagerApple_h
#import "BelongingsManagerApple.h"

@interface PMJobApple : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pJob;
    
#endif
}
- (bool) RaiseEvent:(NSDictionary*) inData;
- (bool) Control:(NSDictionary*) inData;
- (void) SetTimeOut:(uint32_t) cms;
- (uint32_t) GetTimeOut;
@end


@interface CommandManagerApple : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pManager;
    
#endif
}
- (void*)AddCommandHandler:(NSString*)CommandName Observer:(id)anObserver selector:(SEL)aSelector;
- (void)RemoveCommandHandler:(NSString*)CommandName Handle:(void*)theHandle;
- (bool)IssueCommand:(NSString*)CommandName Argument:(NSDictionary*)inData ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;
- (bool)IssueAuthorizedCommand:(BelongingsRecordApple*)Record CommandName:(NSString*)aCommandName Argument:(NSDictionary*)inData ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;

- (PMJobApple*)IssueJob:(NSString*)JobName Argument:(NSDictionary*)inData EventObserver:(id)anObserver EventSelector:(SEL)aSelector;

-(bool)CanSendCommand;
-(bool)CanReceiveCommand;
@end


#endif
