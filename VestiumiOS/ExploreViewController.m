//
//  ExploreViewController.m
//  Vestium
//
//  Created by Daniel Koehler on 30/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "ExploreViewController.h"
#import "VestiumUI.h"

@interface ExploreViewController ()

@property (nonatomic, strong) ECSlidingViewController *slidingViewController;

@end

@implementation ExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        //set the title for the tab
        self.title = @"Explore";
        //set the image icon for the tab
        FIIcon *icon = [FIEntypoIcon compassIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor blackColor]];
        
        [self.tabBarItem setImage:image];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.slidingViewController = (ECSlidingViewController*)[([[UIApplication sharedApplication] delegate]).window rootViewController];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
