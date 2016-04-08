//
//  PMTaskObserverApple.h
//

#ifndef __PMTaskObserverApple__
#define __PMTaskObserverApple__

#import <Foundation/Foundation.h>

enum PMTaskState
{
    kStateUninit=0,
    kStateInit,
    kStateStarted,
    kStateStopped,
    kStateNewInfo,
    kStateDone,
    kStateError
};

@interface PMTaskObserverApple : NSObject
{
#if !defined(_LP64) //  work around 32 bit compiler issues
    void *_m_pObserver;
#endif
    
}

- (void)SetStateObserver:(id)anObserver selector:(SEL)aSelector;

@end



#endif 
