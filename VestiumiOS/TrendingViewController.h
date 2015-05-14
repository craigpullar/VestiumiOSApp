//
//  TrendingViewController.h
//  Vestium
//
//  Created by Daniel Koehler on 22/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "Vestium.h"
#import <UIKit/UIKit.h>

@interface TrendingViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, VestiumPostDelegate, VestiumUserDelegate>
{
    UICollectionView *_collectionView;
}

@property (nonatomic, strong) NSArray* menuItems;
@property (nonatomic, strong) UITapGestureRecognizer *detailedViewRecogsniser;

@property Vestium *vestium;

@property (nonatomic, strong) User *user;

@end
