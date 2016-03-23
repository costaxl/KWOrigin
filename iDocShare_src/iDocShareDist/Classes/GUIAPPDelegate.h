//
//  GUIAPPDelegate.h
//  PMPlayer
//
//  Created by James_hsieh on 12/8/13.
//
//

#import <UIKit/UIKit.h>
#import "DiscoveryListViewController.h"
#import "PMPlayerAppleTranslator.h"
#import "NotificationTranslatorApple.h"
#import "OperationManagerApple.h"
#import "GUIModelService.h"
#import "BrowserDelegate.h"

@interface GUIAPPDelegate : BrowserDelegate<UIApplicationDelegate, GUIAppService, UITabBarControllerDelegate> //UIResponder <UIApplicationDelegate, GUIAppService, UITabBarControllerDelegate>
{   
    UIWindow *                    _window;
	DiscoveryListViewController * _movieListViewController;
    PMPlayerAppleTranslator* m_pPMPlayer;
    BelongingsManagerApple* m_pBelongingsManager;
    PMLiveDomainApple* m_pJingleDomain;
    PMLiveDomainApple* m_pLanDomain;
    void* m_DomainHandle;
    bool m_bIsLogined;
    
}
@property (retain, nonatomic) IBOutlet UINavigationController *DiscoveryNavigator;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) DiscoveryListViewController * movieListViewController;

- (void)OnDomainStatusChanged:(NotificationInfo*)info;
- (void)OnJingleDomainStatusChanged:(NotificationInfo*)info;
- (void)ProcessPlayOnMainThread:(BelongingsRecordApple*)pRecord;
- (void)OnBelongingsScanReport:(NotificationInfo*)info;
- (PMPlayer_Error)PlayPeerMedia:(BelongingsRecordApple*) Record;
- (void)StopPeerMedia;

- (PMLiveDomainApple *)GetJingleDomain;
- (bool) IsLogined;
+ (GUIAPPDelegate*) defaultAppDelegate;

- (void)ExecOperation:(OperationApple*) anOperation WaitUntilDone:(NSNumber*) bWait;
- (void)ExecOperationOnMainThread:(OperationApple*) anOperation;
@end
