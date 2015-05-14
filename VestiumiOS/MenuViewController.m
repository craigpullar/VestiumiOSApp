//
//  MenuViewController.m
//  Vestium
//
//  Created by Daniel Koehler on 22/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//
#import "MenuViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "FontasticIcons.h"

#import "RegistrationViewController.h"
#import "TrendingViewController.h"
#import "UploadViewController.h"

#define PROFILE_VIEW_X_INSET 0.0f
#define PROFILE_VIEW_Y_INSET (0.0f)
#define PROFILE_VIEW_WIDTH   self.view.bounds.size.width
#define PROFILE_VIEW_HEIGHT  200.0f

#define PROFILE_IMAGE_VIEW_X_INSET (PROFILE_VIEW_WIDTH - PROFILE_IMAGE_VIEW_WIDTH) / 2.0f
#define PROFILE_IMAGE_VIEW_Y_INSET 50.0f
#define PROFILE_IMAGE_VIEW_WIDTH   75.0f
#define PROFILE_IMAGE_VIEW_HEIGHT  75.0f

#define PROFILE_USERNAME_VIEW_X_INSET (self.view.bounds.size.width - PROFILE_USERNAME_VIEW_WIDTH) / 2.0f
#define PROFILE_USERNAME_VIEW_Y_INSET PROFILE_IMAGE_VIEW_Y_INSET + PROFILE_IMAGE_VIEW_HEIGHT + 10.0f
#define PROFILE_USERNAME_VIEW_WIDTH   PROFILE_VIEW_WIDTH
#define PROFILE_USERNAME_VIEW_HEIGHT  20.0f

#define PROFILE_STATISTICS_VIEW_X_INSET (self.view.bounds.size.width - PROFILE_VIEW_WIDTH) / 2.0f
#define PROFILE_STATISTICS_VIEW_Y_INSET PROFILE_USERNAME_VIEW_Y_INSET + PROFILE_USERNAME_VIEW_HEIGHT + 10.0f
#define PROFILE_STATISTICS_VIEW_WIDTH   PROFILE_VIEW_WIDTH
#define PROFILE_STATISTICS_VIEW_HEIGHT  20.0f

#define TABLE_VIEW_X_INSET (self.view.bounds.size.width/2.0f - TABLE_VIEW_WIDTH/2.0f)
#define TABLE_VIEW_Y_INSET PROFILE_VIEW_HEIGHT
#define TABLE_VIEW_WIDTH   self.view.bounds.size.width
#define TABLE_VIEW_HEIGHT  self.view.bounds.size.height - PROFILE_VIEW_HEIGHT

#define TABLE_CELL_BORDER_X_INSET (cell.frame.size.width - TABLE_CELL_BORDER_WIDTH) / 2.0f
#define TABLE_CELL_BORDER_Y_INSET cell.frame.size.height - TABLE_CELL_BORDER_HEIGHT
#define TABLE_CELL_BORDER_WIDTH   0.0f
#define TABLE_CELL_BORDER_HEIGHT  1.0f

#define TABLE_CELL_ACTIVE_X_INSET 0.0f
#define TABLE_CELL_ACTIVE_Y_INSET ((cell.frame.size.height - TABLE_CELL_ACTIVE_HEIGHT) / 2.0f)
#define TABLE_CELL_ACTIVE_WIDTH   4.0f
#define TABLE_CELL_ACTIVE_HEIGHT  (cell.frame.size.height)

@interface MenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) UINavigationController *transitionsNavigationController;
@property (nonatomic, strong) UILabel *profileUsernameLabel;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *profileUserStatistics;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view setBounds:CGRectMake(0, 0, 220.0f, self.view.bounds.size.height)];
    
    [self setUpTableView];
    [self setUpProfileView];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0 ]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionMiddle];
    
    // topViewController is the transitions navigation controller at this point.
    // It is initially set as a User Defined Runtime Attributes in storyboards.
    // We keep a reference to this instance so that we can go back to it without losing its state.
    
    self.vestium = [Vestium alloc];
    self.vestium.menuDelegate = self;
    self.transitionsNavigationController = (UINavigationController *)self.slidingViewController.topViewController;
    
}

-(void) updateMenuWithUser:(User*) user
{
    NSLog(@"UpdateCalled");
    [self.profileUsernameLabel setText:[NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName]];
    [self.profileUserStatistics setText:[NSString stringWithFormat:@"%d followers - %d looks",user.numFollowers,user.numPosts]];
    
    __weak typeof(self.profileImageView) weakProfileImageView = self.profileImageView;
    
    [self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.vestium.user.profileImage]] placeholderImage:[UIImage imageNamed:@"user-placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { // Set image
        
        NSLog(@"Imagesuccess");
        [weakProfileImageView setImage:image];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

-(void) setUpProfileView {
    
    UIView *profileBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(PROFILE_VIEW_X_INSET, PROFILE_VIEW_Y_INSET, PROFILE_VIEW_WIDTH, PROFILE_VIEW_HEIGHT)];
    
    [profileBackgroundView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:profileBackgroundView];
    
    self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PROFILE_IMAGE_VIEW_X_INSET, PROFILE_IMAGE_VIEW_Y_INSET, PROFILE_IMAGE_VIEW_WIDTH, PROFILE_IMAGE_VIEW_HEIGHT)];
    
    [[self.profileImageView layer] setMasksToBounds:YES];
    [[self.profileImageView layer] setCornerRadius:37.5f]; // Round corners
    
    self.profileUsernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(PROFILE_USERNAME_VIEW_X_INSET, PROFILE_USERNAME_VIEW_Y_INSET, PROFILE_USERNAME_VIEW_WIDTH, PROFILE_USERNAME_VIEW_HEIGHT)];
    [self.profileUsernameLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.profileUsernameLabel setFont:[UIFont flatFontOfSize:15.0f]];
    [self.profileUsernameLabel setTextColor: [UIColor colorWithRed:1.0f green:172.0f/255.0f blue:6.0f/255.0f alpha:1.0f]];
    
    self.profileUserStatistics = [[UILabel alloc] initWithFrame:CGRectMake(PROFILE_STATISTICS_VIEW_X_INSET, PROFILE_STATISTICS_VIEW_Y_INSET, PROFILE_STATISTICS_VIEW_WIDTH, PROFILE_STATISTICS_VIEW_HEIGHT)];
    
    [self.profileUserStatistics setTextAlignment:NSTextAlignmentCenter];
    [self.profileUserStatistics setFont:[UIFont flatFontOfSize:12.0f]];
    [self.profileUserStatistics setTextColor: [UIColor colorWithRed:1.0f green:172.0f/255.0f blue:6.0f/255.0f alpha:1.0f]];
    
    
    [profileBackgroundView addSubview:self.profileUsernameLabel];
    [profileBackgroundView addSubview:self.profileUserStatistics];
    [profileBackgroundView addSubview:self.profileImageView];
    
    [self.view addSubview:profileBackgroundView];
    
}

-(void) setUpTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(TABLE_VIEW_X_INSET,TABLE_VIEW_Y_INSET, TABLE_VIEW_WIDTH, TABLE_VIEW_HEIGHT) style:UITableViewStylePlain];
    
    self.tableView.rowHeight = 40;
    self.tableView.sectionFooterHeight = 22;
    self.tableView.sectionHeaderHeight = 22;
    self.tableView.scrollEnabled = YES;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.bounces = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"SideMenuItemCell" bundle:nil] forCellReuseIdentifier:@"sideMenuItemCell"];
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - Properties

- (NSArray *)menuItems
{
    
    return @[
             @{
                 @"name":@"Upload",
                 @"iconShortname":@"camera",
                 @"fontName":@"Entypo",
                 },
             @{
                 @"name":@"Home",
                 @"iconShortname":@"home",
                 @"fontName":@"Entypo",
                 },
             @{
                 @"name":@"Explore",
                 @"iconShortname":@"compass",
                 @"fontName":@"Entypo",
                 },
             @{
                 @"name":@"Blog",
                 @"iconShortname":@"map",
                 @"fontName":@"Entypo",
                 },
             @{
                 @"name":@"Settings",
                 @"iconShortname":@"cog",
                 @"fontName":@"Entypo",
                 
                 }
             ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"sideMenuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *menuItem = self.menuItems[indexPath.row];
    
    UIView *icon = [cell viewWithTag:2];
    UILabel *label =  (UILabel *)[cell viewWithTag:1];
    
    FIIconView *iconView = [[FIIconView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    iconView.backgroundColor = [UIColor clearColor];
    iconView.icon = [FIEntypoIcon iconWithName:menuItem[@"iconShortname"] fontName:menuItem[@"fontName"]];
    iconView.padding = 5;
    iconView.iconColor = [UIColor colorWithRed:1.0f green:172.0f/255.0f blue:6.0f/255.0f alpha:1.0f];
    [icon addSubview:iconView];
    
    [label setText:menuItem[@"name"]];
    [label setFont:[UIFont flatFontOfSize:16.0f]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    CALayer *bottomBorder = [CALayer layer];
    
    bottomBorder.frame = CGRectMake(TABLE_CELL_BORDER_X_INSET, TABLE_CELL_BORDER_Y_INSET, TABLE_CELL_BORDER_WIDTH, TABLE_CELL_BORDER_HEIGHT);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f].CGColor;
    
    [cell.layer addSublayer:bottomBorder];
    
    UIView *activeRow = [[UIView alloc] initWithFrame:cell.frame];
    
    CALayer *activeMark = [CALayer layer];
    activeMark.frame = CGRectMake(TABLE_CELL_ACTIVE_X_INSET, TABLE_CELL_ACTIVE_Y_INSET, TABLE_CELL_ACTIVE_WIDTH, TABLE_CELL_ACTIVE_HEIGHT);
    activeMark.backgroundColor = [UIColor colorWithRed:1.0f green:172.0f/255.0f blue:6.0f/255.0f alpha:1.0f].CGColor;
    
    [activeRow.layer addSublayer:activeMark];
    
    [cell setSelectedBackgroundView:activeRow];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *menuItem = self.menuItems[indexPath.row];
    
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    
    //    if ([menuItem[@"name"] isEqualToString:@"Home"])
    //    {
    //
    //        [self.slidingViewController setTopViewController:[[TrendingViewController alloc] init]];
    //
    //    } else if ([menuItem[@"name"] isEqualToString:@"Upload"])
    //    {
    //
    //        [self.slidingViewController setTopViewController:[[UploadViewController alloc] init]];
    //        [(UploadViewController*) self.slidingViewController.topViewController showPicker];
    //
    //    }
    //
    [self.slidingViewController resetTopViewAnimated:YES];
    
}

@end