//
//  ProfileViewController.m
//  Vestium
//
//  Created by Craig Pullar on 06/08/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "ProfileViewController.h"

#define PROFILE_VIEW_X_INSET 0.0f
#define PROFILE_VIEW_Y_INSET (0.0f)
#define PROFILE_VIEW_WIDTH   self.view.bounds.size.width
#define PROFILE_VIEW_HEIGHT  200.0f

#define POST_COLLECTION_VIEW_X_INSET (0.0f)
#define POST_COLLECTION_VIEW_Y_INSET PROFILE_VIEW_HEIGHT
#define POST_COLLECTION_VIEW_WIDTH self.view.bounds.size.width
#define POST_COLLECTION_VIEW_HEIGHT self.view.bounds.size.height - PROFILE_VIEW_HEIGHT

#define PROFILE_IMAGE_VIEW_X_INSET (PROFILE_VIEW_WIDTH - PROFILE_IMAGE_VIEW_WIDTH) / 2.0f
#define PROFILE_IMAGE_VIEW_Y_INSET 50.0f
#define PROFILE_IMAGE_VIEW_WIDTH   75.0f
#define PROFILE_IMAGE_VIEW_HEIGHT  75.0f

#define PROFILE_STATISTICS_VIEW_X_INSET (self.view.bounds.size.width - PROFILE_VIEW_WIDTH) / 2.0f
#define PROFILE_STATISTICS_VIEW_Y_INSET PROFILE_IMAGE_VIEW_HEIGHT + 80.0f
#define PROFILE_STATISTICS_VIEW_WIDTH   PROFILE_VIEW_WIDTH
#define PROFILE_STATISTICS_VIEW_HEIGHT  20.0f

#define PROFILE_USERNAME_VIEW_X_INSET (self.view.bounds.size.width - PROFILE_USERNAME_VIEW_WIDTH) / 2.0f
#define PROFILE_USERNAME_VIEW_Y_INSET PROFILE_IMAGE_VIEW_Y_INSET + PROFILE_IMAGE_VIEW_HEIGHT + 10.0f
#define PROFILE_USERNAME_VIEW_WIDTH   PROFILE_VIEW_WIDTH
#define PROFILE_USERNAME_VIEW_HEIGHT  20.0f

#define FOLLOW_BUTTON_X_INSET 200
#define FOLLOW_BUTTON_Y_INSET 110
#define FOLLOW_BUTTON_WIDTH 20
#define FOLLOW_BUTTON_HEIGHT 20

#define POST_WIDTH self.view.frame.size.width / 3.0f
#define POST_HEIGHT 160

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    [self setUpProfile];
    self.vestium = [Vestium alloc];
    self.vestium.profileDelegate = self;
    [self.vestium getProfileUserForId:3];
    [self.vestium checkIfFollowingUserWithId:3];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) didGetProfileUser:(User *)user
{
    self.user = user;
    [self setProfileData:user];
    self.vestium.user  = user;
    
}
- (void) setProfileData:(User*)user
{
    NSLog(@"Data updated");
    [self.profileUserStatistics setText:[NSString stringWithFormat:@"%ld Followers | %ld Following | %ld Looks",(long)user.numFollowers,(long)user.numFollowing, (long)user.numPosts]];
    [self.profileUsernameLabel setText:[NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName]];
    
    __weak typeof(self.profileImageView) weakProfileImageView = self.profileImageView;
    [self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.user.profileImage]] placeholderImage:[UIImage imageNamed:@"profile.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { // Set image
        
        [weakProfileImageView setImage:image];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    __weak typeof(self.profileBackgroundView) weakProfileBackgroundView = self.profileBackgroundView;
    [self.profileBackgroundView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.user.coverImage]] placeholderImage:[UIImage imageNamed:@"cover.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { // Set image
        
        [weakProfileBackgroundView setImage:image];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
    }];
    [self.vestium getPostsForUserId:user.identifier];
}
-(void) didGetPostsForUser:(NSArray *)posts
{
    self.posts = posts;
    [self.postCollectionView reloadData];
}
-(void) setUpProfile
{
    self.profileBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(PROFILE_VIEW_X_INSET, PROFILE_VIEW_Y_INSET, PROFILE_VIEW_WIDTH, PROFILE_VIEW_HEIGHT) ];
    [self.profileBackgroundView setImage:[UIImage imageNamed:@"cover.jpg"]];
    [self.profileBackgroundView setTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.profileBackgroundView];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    self.postCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(POST_COLLECTION_VIEW_X_INSET, POST_COLLECTION_VIEW_Y_INSET, POST_COLLECTION_VIEW_WIDTH, POST_COLLECTION_VIEW_HEIGHT) collectionViewLayout:flow];
    
    self.profileFollowButton = [[UIButton alloc] initWithFrame:CGRectMake(FOLLOW_BUTTON_X_INSET, FOLLOW_BUTTON_Y_INSET, FOLLOW_BUTTON_WIDTH, FOLLOW_BUTTON_HEIGHT)];
    [self.profileFollowButton setBackgroundColor:[UIColor whiteColor]];
    [[self.profileFollowButton layer] setCornerRadius:10];
    
    [self.profileFollowButton setTitleColor:[UIColor colorWithRed:1.0f green:172.0f/255.0f blue:6.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.profileFollowButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.profileFollowButton.titleLabel setFont:[UIFont flatFontOfSize:20.0f]];
    [self.profileFollowButton addTarget:self action:@selector(followButtonWasPushed:) forControlEvents:UIControlEventTouchUpInside];

    
    
    
    [self.postCollectionView setDataSource:self];
    [self.postCollectionView setDelegate:self];
    [self.postCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.postCollectionView setPagingEnabled:NO];
    
    [self.postCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"profilePostCell"];
    [self.postCollectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.postCollectionView setCollectionViewLayout:flow];
    
    [self.view addSubview:self.postCollectionView];
    
    
    self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PROFILE_IMAGE_VIEW_X_INSET, PROFILE_IMAGE_VIEW_Y_INSET, PROFILE_IMAGE_VIEW_WIDTH, PROFILE_IMAGE_VIEW_HEIGHT)];
    
    [[self.profileImageView layer] setMasksToBounds:YES];
    [[self.profileImageView layer] setCornerRadius:37.5f]; // Round corners
    [[self.profileImageView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[self.profileImageView layer] setBorderWidth:2];
    
    
    
    
    self.profileUserStatistics = [[UILabel alloc] initWithFrame:CGRectMake(PROFILE_STATISTICS_VIEW_X_INSET, PROFILE_STATISTICS_VIEW_Y_INSET, PROFILE_STATISTICS_VIEW_WIDTH, PROFILE_STATISTICS_VIEW_HEIGHT)];
    
    [self.profileUserStatistics setTextAlignment:NSTextAlignmentCenter];
    [self.profileUserStatistics setFont:[UIFont flatFontOfSize:8.0f]];
    [self.profileUserStatistics setTextColor: [UIColor whiteColor]];
    
    
    
    self.profileUsernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(PROFILE_USERNAME_VIEW_X_INSET, PROFILE_USERNAME_VIEW_Y_INSET, PROFILE_USERNAME_VIEW_WIDTH, PROFILE_USERNAME_VIEW_HEIGHT)];
    [self.profileUsernameLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.profileUsernameLabel setFont:[UIFont flatFontOfSize:16.0f]];
    [self.profileUsernameLabel setTextColor: [UIColor whiteColor]];
    
    
    
    
    [self.profileBackgroundView addSubview:self.profileImageView];
    [self.profileBackgroundView addSubview:self.profileUserStatistics];
    [self.profileBackgroundView addSubview:self.profileUsernameLabel];
    [self.view addSubview:self.profileFollowButton];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Post *post = self.posts[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"profilePostCell" forIndexPath:indexPath];
    UIImageView *cellImage = [[UIImageView alloc] init];
    
    __weak typeof(cellImage) weakCellImage = cellImage;
    [cellImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:post.imagePath]] placeholderImage:[UIImage imageWithColor:[UIColor whiteColor] cornerRadius:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { // Set image
        
        [weakCellImage setImage:image];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [cell setBackgroundView:cellImage];

    return cell;
    
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(POST_WIDTH, POST_HEIGHT);
    
}

- (NSInteger)collectionView:(UICollectionView *) collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.posts.count;
}
-(void) followButtonWasPushed:(id) sender
{
    if(!self.isFollowed)
    {
        [self.vestium followUserWithId:self.user.identifier];
    }
    else
    {
        [self.vestium unfollowUserWithId:self.user.identifier];

    }
    
}
-(void) didFollowUser:(User *)user
{
    [self.profileFollowButton setTitle:@"F" forState:UIControlStateNormal];
    [self setProfileData:user];
    self.isFollowed = true;
}
-(void) didUnfollowUser
{
    [self.profileFollowButton setTitle:@"+" forState:UIControlStateNormal];
    [self.vestium getProfileUserForId:self.user.identifier];
    self.isFollowed = false;
}
-(void) doesFollowUser
{
    [self.profileFollowButton setTitle:@"F" forState:UIControlStateNormal];
    self.isFollowed = true;
}
-(void) doesNotFollowUser
{
    [self.profileFollowButton setTitle:@"+" forState:UIControlStateNormal];
    self.isFollowed = false;
}
- (void) openPanView
{
    //    NSLog(@"Opening");
    
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
