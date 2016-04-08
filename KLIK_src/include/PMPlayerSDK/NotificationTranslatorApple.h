//
//  NotificationTranslatorApple.h
//

#ifndef _NotificationTranslatorApple_h
#define _NotificationTranslatorApple_h
#import <Foundation/Foundation.h>

@interface NotificationInfo : NSObject
{
@public
    void* theData;
}
@property void* Data;
@end

@interface NotificationTranslatorApple : NSObject 
{
#if !defined(_LP64) //  work around 32 bit compiler issues
    void *_m_pNotificationManager;
#endif

}
+ (NotificationTranslatorApple*) defaultNotificationTranslator;
- (void*)AddNotification:(NSString*)name Observer:(id)anObserver selector:(SEL)aSelector;
- (void)RemoveNotification:(NSString*)name Handle:(void*)theHandle;
- (void)PostNotification:(NSString*)name NotificationData:(NSDictionary*)theData;
@end


#endif
