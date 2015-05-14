//
//  ProfileViewController.h
//  Vestium
//
//  Created by Craig Pullar on 06/08/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vestium.h"

@interface ProfileViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,VestiumProfileDelegate>

@property (strong,nonatomic) Vestium *vestium;
@property (strong,nonatomic) UIImageView *profileBackgroundView;
@property (nonatomic, strong) UILabel *profileUsernameLabel;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *profileUserStatistics;
@property (nonatomic, strong) UICollectionView *postCollectionView;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIButton *profileFollowButton;
@property (nonatomic, strong) NSArray* posts;
@property () Boolean isFollowed;

@end
