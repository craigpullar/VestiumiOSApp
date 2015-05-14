//
//  VUITabBarController.m
//  Vestium
//
//  Created by Daniel Koehler on 30/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "VUITabBarController.h"

@interface VUITabBarController ()

@end

@implementation VUITabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
    [self.tabBar setBarStyle:UIBarStyleDefault];
    [self.tabBar setTranslucent:YES];
    [self.tabBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.tabBar setTintColor:[UIColor colorWithRed: 0.934 green: 0.605 blue: 0.147 alpha: 1]];
    [self.tabBar setItemPositioning:UITabBarItemPositioningCentered];
//    [self.tabBar setAlpha:0.0f];
    
//    UIToolbar *blur = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [UIApplication sharedApplication].statusBarFrame.size.height)];
//    [blur setAutoresizingMask:self.view.autoresizingMask];
//    [blur setBarStyle:UIBarStyleBlack];
//    [self.view addSubview:blur];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
