//
//  MenuViewController.h
//  Vestium
//
//  Created by Daniel Koehler on 22/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vestium.h"

@class TrendingViewController;

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, VestiumMenuDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) TrendingViewController *trendingViewController;

@property (strong, nonatomic) Vestium *vestium;

@end


