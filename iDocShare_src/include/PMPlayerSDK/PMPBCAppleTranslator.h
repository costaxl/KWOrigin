//
//  PMPBCAppleTranslator.h
//
//  Created by tywang on 13/11/6.
//
//

#ifndef __PMPBCAppleTranslator__
#define __PMPBCAppleTranslator__

#import <Foundation/Foundation.h>
#include "PMPlayerCommonTypes.h"

@protocol PMPBCGUIDelegateApple <NSObject>
- (bool) CanFeatureStart:(NSString*)FeatureName;
- (void) OnFeatureStatusChanged: (NSString*)FeatureName handle:(void*) theHandle state:(int)currentState info:(NSDictionary*)theInfo;
- (void) OnPBCStatusChanged:(void*) theHandle state:(int)currentState info:(NSDictionary*)theInfo;
@end

@class PMJobApple;
@interface PMPBCAppleTranslator : NSObject
{
#if !defined(_LP64)
    void* _m_pPBC;
    void* _m_pSignalReceiver;
    void* _m_csPBC;
    void* _m_pDelegateAppleWrapper;
    void* _m_ProviderMap;
#endif
}
-(bool) Command:(NSString*)CommandName Argument:(NSDictionary*)inData ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;
- (bool)IssueCommand2Peer:(NSString*)CommandName Argument:(NSDictionary*)inData ExchangeID:(uint32_t)anExchange ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;
- (bool)IssueCommand2Peer:(NSString*)CommandName Argument:(NSDictionary*)inData ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector;
- (PMJobApple*)IssueJob2Peer:(NSString*)JobName Argument:(NSDictionary*)inData EventObserver:(id)anObserver EventSelector:(SEL)aSelector;

- (bool)IssueCommand2Peer:(NSString*)CommandName Argument:(NSDictionary*)inData ExchangeID:(uint32_t)anExchange ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector userData:(NSObject*) Data;
- (bool)IssueCommand2Peer:(NSString*)CommandName Argument:(NSDictionary*)inData ReturnObserver:(id)anObserver ReturnSelector:(SEL)aSelector userData:(NSObject*) Data;
- (PMJobApple*)IssueJob2Peer:(NSString*)JobName Argument:(NSDictionary*)inData EventObserver:(id)anObserver EventSelector:(SEL)aSelector userData:(NSObject*) Data;

-(bool) SetGUIDelegate:(id<PMPBCGUIDelegateApple>) Delegate;
-(void*) GetHandle;
-(id) GetFeature:(NSString*)FeatureName;
-(bool) GetServiceProvider:(NSString*)ServiceName Provider:(void**) ppProvider;

- (bool)GetProperty:(NSString*)name value:(NSObject**)Value;

@end


#endif 
