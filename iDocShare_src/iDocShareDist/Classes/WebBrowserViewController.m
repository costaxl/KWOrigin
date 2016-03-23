//
//  WebBrowserViewController.m
//

#import "WebBrowserViewController.h"
#import "GUIModelService.h"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface WebBrowserViewController ()

@end

@implementation WebBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Animations & positions
    [self setNavBarHidden:true animated:animated];
    // send the state - presentable view absent
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Present];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:self.view userInfo:dic];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // send the state - presentable view absent
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_WillAbsent];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:nil userInfo:dic];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setNavBarHidden:false animated:animated];
    
}
- (void) setNavBarHidden:(BOOL)bHide animated:(BOOL)bAnimated
{
    CGFloat animationDuration = (bAnimated ? 0.35 : 0);
    
    bool _leaveStatusBarAlone = YES;
    bool _isVCBasedStatusBarAppearance = YES;
    bool hidden = bHide;
    // Status bar
    if (!_leaveStatusBarAlone) {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            
            // iOS 7
            // Hide status bar
            if (!_isVCBasedStatusBarAppearance) {
                
                // Non-view controller based
                [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:bAnimated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
                
            } else {
                
                // View controller based so animate away
                [UIView animateWithDuration:animationDuration animations:^(void) {
                    [self setNeedsStatusBarAppearanceUpdate];
                } completion:^(BOOL finished) {}];
                
            }
            
        } else {
            
            // iOS < 7
            // Status bar and nav bar positioning
            BOOL fullScreen = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            if (SYSTEM_VERSION_LESS_THAN(@"7")) fullScreen = self.wantsFullScreenLayout;
#endif
            if (fullScreen) {
                
                // Need to get heights and set nav bar position to overcome display issues
                
                // Get status bar height if visible
                CGFloat statusBarHeight = 0;
                if (![UIApplication sharedApplication].statusBarHidden) {
                    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                    statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
                }
                
                // Status Bar
                [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:bAnimated?UIStatusBarAnimationFade:UIStatusBarAnimationNone];
                
                // Get status bar height if visible
                if (![UIApplication sharedApplication].statusBarHidden) {
                    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                    statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
                }
                
                // Set navigation bar frame
                CGRect navBarFrame = self.navigationController.navigationBar.frame;
                navBarFrame.origin.y = statusBarHeight;
                self.navigationController.navigationBar.frame = navBarFrame;
                
            }
            
        }
    }
    
    // Toolbar, nav bar and captions
    // Pre-appear animation positions for iOS 7 sliding
    [UIView animateWithDuration:animationDuration animations:^(void) {
        
        CGFloat alpha = hidden ? 0 : 1;
        
        // Nav bar slides up on it's own on iOS 7
        [self.navigationController.navigationBar setAlpha:alpha];
        
        
    } completion:^(BOOL finished) {}];
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
