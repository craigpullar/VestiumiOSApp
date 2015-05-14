//
//  AppDelegate.m
//  VestiumiOS
//
//  Created by Daniel Koehler on 31/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) ECSlidingViewController *slidingViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // Init Views for later use.
    
    self.menuViewController = [[MenuViewController alloc] init];
    
    self.registrationViewController  = [[RegistrationViewController alloc] init];
    
    self.uploadViewController = [[UploadViewController alloc] init];
    
    self.trendingViewController = [[TrendingViewController alloc] init];
    
    self.trendingNavigationController = [[UINavigationController alloc] initWithRootViewController:self.trendingViewController];
    
    self.exploreViewController = [[ExploreViewController alloc] init];
    
    self.searchViewController = [[SearchViewController alloc] init];
    
    self.searchNavigationController = [[UINavigationController alloc] initWithRootViewController:self.searchViewController];
    
    self.profileViewController = [[ProfileViewController alloc] init];
    
    // configure under left view controller
    self.menuViewController.view.layer.borderWidth     = 0;
    self.menuViewController.edgesForExtendedLayout     = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft; // don't go under the top view
    
    //initialize the tab bar controller
    self.tabBarController = [[VUITabBarController alloc] init];
    
    self.slidingViewController = [ECSlidingViewController slidingWithTopViewController:self.tabBarController];
    
    self.slidingViewController.underRightViewController = nil;
    self.slidingViewController.underLeftViewController  = self.menuViewController;
    
    self.slidingViewController.anchorRightPeekAmount  = 100.0;
    self.slidingViewController.anchorLeftRevealAmount = 250.0;
    
    //create an array of all view controllers that will represent the tab at the bottom
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:
                                self.uploadViewController,
                                self.trendingViewController,
                                self.exploreViewController,
                                self.searchNavigationController,
                                nil];
    
    
    //set the view controllers for the tab bar controller
    [self.tabBarController setViewControllers:viewControllers];
    [self.tabBarController setSelectedIndex:1];
    
    // configure anchored layout
    self.window.rootViewController = self.slidingViewController;
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    [self.window.rootViewController presentViewController:self.profileViewController animated:NO completion:^{
        //user entry handler
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
