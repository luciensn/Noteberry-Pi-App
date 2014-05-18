//
//  AppDelegate.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "GroupsViewController.h"
#import "CoreDataManager.h"
#import "UIColor+ThemeColor.h"
#import "PinManager.h"
#import "PINViewController.h"

@interface AppDelegate ()

// Properties
@property (nonatomic) BOOL isLaunch;
@property (nonatomic) BOOL pinScreenIsShowing;
@property (nonatomic) BOOL didEnterBackground;

@end

#pragma mark -

@implementation AppDelegate

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Application Launch

static NSString *const FRESH_INSTALL = @"FRESH_INSTALL";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set app theme color
    [self setStyles];
    
    // don't cache any NSURL data
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    
    // check for fresh installation of the app
    BOOL freshInstall = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:FRESH_INSTALL] == NULL) {
        freshInstall = YES;
        [defaults setBool:YES forKey:FRESH_INSTALL];
        [defaults synchronize];
    }
    
    // if app was just installed, clear out the Keychain because the PIN persists between installs
    if (freshInstall) {
        [PinManager resetPin];
    }
    
    // core data manager
    [[CoreDataManager sharedManager] initWithFreshInstall:freshInstall];
    
    // date formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    // set the root view controller
    BaseNavigationController *nav = (BaseNavigationController *)_window.rootViewController;
    GroupsViewController *groups = [[GroupsViewController alloc] init];
    [nav setViewControllers:@[groups] animated:NO];
    
    [self setIsLaunch:YES];
    return YES;
}

- (void)setStyles
{
    [self.window setTintColor:[UIColor themeColor]];
    
    // navigation bar styling
    UIImage *navbar = [UIImage imageWithColor:[UIColor themeColor] andSize:CGSizeMake(2, 2)];
    navbar = [navbar resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setBackgroundImage:navbar forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    NSDictionary *navBarTitleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setTitleTextAttributes:navBarTitleAttributes];
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setTintColor:[UIColor whiteColor]];
}

#pragma mark - Application Events
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // save the time the app entered the background
    [PinManager saveResignTime:[NSDate date]];
    [self setDidEnterBackground:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // save the changes to the managed object context
    [[CoreDataManager sharedManager] saveContext];
    
    // dismiss any view controllers that are up
    if (!_pinScreenIsShowing) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    // set the flags
    [self setDidEnterBackground:YES];
    
    // show the splash screen if pin is enabled
    if ([PinManager pinIsEnabled]) {
        [self showSplashScreen];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // show the pin screen if needed
    if (_isLaunch || _didEnterBackground) {
        if ([self shouldShowPinScreen]) {
            [self showPinScreen];
        }
    }
    
    // hide the splash screen if needed
    if (_splashScreen.superview) {
        [self hideSplashScreenAnimated];
    }
    
    // set the flags
    if (_isLaunch) {
        [self setIsLaunch:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[CoreDataManager sharedManager] saveContext];
}

#pragma mark - Pin Screen

- (BOOL)shouldShowPinScreen
{
    if (_pinScreenIsShowing) {
        return NO;
    }
    
    // always show pin on launch
    else if (_isLaunch) {
        return [PinManager pinIsEnabled];
    }
    
    // only show pin after specified delay
    else if ([PinManager pinIsEnabled]) {
        PinDelay delay = [PinManager getPinDelay];
        if (delay == PinDelayNone) {
            return YES;
        }
        NSDate *resignTime = [PinManager getResignTime];
        NSInteger delayInterval = [PinManager timeIntervalForDelaySetting:delay];
        if (abs([resignTime timeIntervalSinceNow]) > delayInterval) {
            return YES;
        }
    }
    
    return NO;
}

- (void)showPinScreen
{
    [self setPinScreenIsShowing:YES];
    
    __weak typeof(self) weakSelf = self;
    PINViewController *pinViewController = [[PINViewController alloc] initWithPinLockedModeWithCompletion:^(BOOL success){
        if (success) {
            [weakSelf dismissPinScreen];
        }
    }];
    
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:pinViewController];
    [self.window.rootViewController presentViewController:nav animated:NO completion:nil];
    [self.window.rootViewController.view setNeedsLayout];
}

- (void)dismissPinScreen
{
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    [self setPinScreenIsShowing:NO];
}

#pragma mark - Splash Screen

- (void)showSplashScreen
{
    if (!_splashScreen) {
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGRect splashFrame = CGRectMake(0, 0, CGRectGetWidth(screen), CGRectGetHeight(screen));
        _splashScreen = [[UIView alloc] init];
        [_splashScreen setBackgroundColor:[UIColor themeColor]];
        [_splashScreen setFrame:splashFrame];
    }
    
    if (!_splashScreen.superview) {
        [_splashScreen setAlpha:1];
        [_splashScreen setHidden:NO];
        [_window addSubview:_splashScreen];
        [_window bringSubviewToFront:_splashScreen];
    }
}

- (void)hideSplashScreenAnimated
{
    [UIView animateWithDuration:0.25 animations:^{
        [_splashScreen setAlpha:0];
    } completion:^(BOOL finished) {
        [_splashScreen removeFromSuperview];
    }];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
