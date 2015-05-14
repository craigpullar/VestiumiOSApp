//
//  TrendingViewController.m
//  Vestium
//
//  Created by Daniel Koehler on 22/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#define POST_WIDTH   self.view.frame.size.width
#define POST_HEIGHT  568

#import "UIImageView+AFNetworking.h"

#import "Post.h"
#import "User.h"

#import "AppDelegate.h"
#import "TrendingViewController.h"

@interface TrendingViewController ()

@property (nonatomic, strong) ECSlidingViewController *slidingViewController;

@end


@implementation TrendingViewController

//@synthesize menuItems = _menuItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        //set the title for the tab
        //        self.title = @"Home";
        //set the image icon for the tab
        self.title = @"Home";
        
        FIIcon *icon = [FIEntypoIcon homeIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor blackColor]];
        
        [self.tabBarItem setImage:image];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.vestium = [[Vestium alloc] init];
    self.vestium.trendingDelegate = self;
    
    //    [self.vestium getPostsForUserId:2];
    
    self.detailedViewRecogsniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveToDetailedView)];
    self.detailedViewRecogsniser.numberOfTapsRequired = 1;
    
    
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSLog(@"View is displayed for the first Tab");
    
    [self setUpFeedView];
    
}

-(void) didGetFeedPosts:(NSArray *)posts
{
    
    self.menuItems = posts;
    
    [_collectionView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void) viewWillAppear:(BOOL)animated
{
    
    self.slidingViewController = (ECSlidingViewController*)[([[UIApplication sharedApplication] delegate]).window rootViewController];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    //    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 30.0f, 30.0f)];
    //
    //    [logoImageView setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:1.0f]];
    //    [[logoImageView layer] setMasksToBounds:YES];
    //    [[logoImageView layer] setCornerRadius:5.0f];
    //    [logoImageView setImage:[UIImage imageNamed:@"vestium_logo_transparent@2x.png"]]; // Set imag
    //    [self.view addSubview:logoImageView];
}

-(void) setUpFeedView
{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumInteritemSpacing:0.f];
    [layout setMinimumLineSpacing:0.f];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, POST_WIDTH, POST_HEIGHT) collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setPagingEnabled:NO];
    
    [_collectionView registerClass:[VUIStandardPostViewCell class] forCellWithReuseIdentifier:@"portraitPost"];
    [_collectionView registerClass:[VUILandscapePostViewCell class] forCellWithReuseIdentifier:@"landscapePost"];
    
    [_collectionView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    
    [self.view addSubview:_collectionView];
    
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(POST_WIDTH, POST_HEIGHT + 120.0f);
    
}

- (NSInteger)collectionView:(UICollectionView *) collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (void) openPanView
{
    //    NSLog(@"Opening");
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([[touch view] isKindOfClass:[VUILandscapePostViewCell class]] || [[touch view] isKindOfClass:[VUIStandardPostViewCell class]])
    {
        
        
        // [self openPanView];
    }
    
}

-(void) moveToDetailedView
{
    NSLog(@"Open view.");
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Post *post = self.menuItems[indexPath.row];
    
    UICollectionViewCell *cell = [UICollectionViewCell alloc];
    
    if (post.type == PostTypePortrait){
        
        VUIStandardPostViewCell *c = [collectionView dequeueReusableCellWithReuseIdentifier:@"portraitPost" forIndexPath:indexPath];
        c.post = post;
        cell = c;
        
    } else if (post.type == PostTypeLandscape){
        
        VUILandscapePostViewCell *c = [collectionView dequeueReusableCellWithReuseIdentifier:@"landscapePost" forIndexPath:indexPath];
        [c configureWithImage];
        
        c.post = post;
        
        cell = c;
        
    }
    
    [cell addGestureRecognizer:self.detailedViewRecogsniser];
    
    return cell;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
