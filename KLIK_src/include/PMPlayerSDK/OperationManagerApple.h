//
//  OperationManagerApple.h
//  Created by tywang on 13/11/11.
//
//

#ifndef __OperationManagerApple__
#define __OperationManagerApple__
#import <Foundation/Foundation.h>

@interface OperationApple : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pOperation;
    
#endif
}
-(id) initWithOperation:(void*)Operation;
-(bool) ExecOperation;
-(void) ReturnOperation:(NSDictionary*)returnData;
-(NSString*) GetOperationName;
@end

@interface OperationManagerApple : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pOperationManager;
    
#endif
}
+ (OperationManagerApple*) defaultOperationManager;

- (void*)RegisterExecutor:(NSString*)ExecutorName Observer:(id)anObserver selector:(SEL)aSelector;
- (void)UnregisterExecutor:(NSString*)ExecutorName Handle:(void*)theHandle;
- (bool)ExecOperation:(NSString*)ExecutorName OperationName:(NSString*)aOperationName Argument:(NSDictionary*)inData OPDefs:(id)anDefs ExecSelector:(SEL)aExecSelector ReturnSelector:(SEL)aReturnSelector WaitUntilDone:(bool) bWait;

@end


#endif
