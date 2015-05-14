//
//  AppDelegate.h
//  VestiumiOS
//
//  Created by Daniel Koehler on 31/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "MenuViewController.h"

#import "RegistrationViewController.h"
#import "TrendingViewController.h"
#import "UploadViewController.h"
#import "ExploreViewController.h"
#import "SearchViewController.h"
#import "ProfileViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) VUITabBarController *tabBarController;

// Tab Level View Controller
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) RegistrationViewController *registrationViewController;
@property (strong, nonatomic) UploadViewController *uploadViewController;
@property (strong, nonatomic) TrendingViewController *trendingViewController;
@property (strong, nonatomic) ExploreViewController *exploreViewController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;

// Tab Level Navigation Controllers
@property (strong, nonatomic) UINavigationController *searchNavigationController;
@property (strong, nonatomic) UINavigationController *trendingNavigationController;

@end
