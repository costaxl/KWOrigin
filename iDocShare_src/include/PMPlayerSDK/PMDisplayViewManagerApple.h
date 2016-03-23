//
//  PMDisplayViewManagerApple.h
//  Created by tywang on 14/8/29.
//
//

#ifndef __PMDisplayViewManagerApple__
#define __PMDisplayViewManagerApple__
#import <Foundation/Foundation.h>

@protocol PMGUIDisplayViewControllerDelegate <NSObject>
- (bool) ChangeDisplayMode:(int)NewMode;
- (bool) ChangeAppearance: (int)ViewID setting:(NSDictionary*) Setting;
- (bool) AcquireDisplayView:(int)ViewID;
- (void) ReleaseDisplayView:(int)ViewID;
@end

@interface PMDisplayViewManagerApple : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pManager;
    void* _m_pDisplayViewControllerAppleWrapper;
    
#endif
}
- (bool)SetDisplayViewController:(id<PMGUIDisplayViewControllerDelegate>)Delegate;
- (int) GetDisplayMode;
- (bool) SetDisplayMode:(int) DisplayMode;
- (bool) SetDisplayViews:(NSDictionary*) DisplayViews;

@end

#endif
