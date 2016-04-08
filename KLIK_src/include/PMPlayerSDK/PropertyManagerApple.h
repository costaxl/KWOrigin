//
//  PropertyManagerTranslatorApple.h
//
//  Created by tywang on 13/9/26.
//
//

#ifndef __PropertyManagerTranslatorApple__
#define __PropertyManagerTranslatorApple__

#import <Foundation/Foundation.h>


@interface PropertyManagerApple : NSObject
{
#if !defined(_LP64) //  work around 32 bit compiler issues
    void *_m_pPropertyManager;
#endif
    
}
+ (PropertyManagerApple*) defaultPropertyManager;
- (bool)AddProperty:(NSString*)name value:(NSObject*)Value;
- (void)RemoveProperty:(NSString*)name;
- (bool)GetProperty:(NSString*)name value:(NSObject**)Value;
- (bool)SetProperty:(NSString*)name value:(NSObject*)Value;
- (void*)AddObserver:(NSString*)name Observer:(id)anObserver selector:(SEL)aSelector;
- (void)RemoveObserver:(NSString*)name Handle:(void*)theHandle;
@end

#endif 
