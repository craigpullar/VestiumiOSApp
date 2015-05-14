//
//  SearchViewController.m
//  Vestium
//
//  Created by Daniel Koehler on 30/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) ECSlidingViewController *slidingViewController;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        //set the title for the tab
        
        //set the image icon for the tab
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1];
        self.title = @"Search";
        
    }
    
    return self;
    
}

-(void) viewWillAppear:(BOOL)animated
{
 
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    querySet = [[NSMutableArray alloc] initWithObjects:@"iPhone", @"iPod", @"iPod touch", @"iMac", @"Mac Pro", @"iBook",@"MacBook", @"MacBook Pro", @"PowerBook", nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIToolbar *blur = [[UIToolbar alloc] initWithFrame:self.view.bounds];
//    blur.autoresizingMask = self.view.autoresizingMask;
//    // fakeToolbar.barTintColor = [UIColor white]; // Customize base color to a non-standard one if you wish
//    [self.view insertSubview:blur atIndex:0];
    
    self.edgesForExtendedLayout = true;
    
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar setDelegate:self];
    [self.searchBar setTranslucent:YES];
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    
    self.searchBarController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [self.searchBarController setDelegate:self];
    [self.searchBarController setDisplaysSearchBarInNavigationBar:NO];
    [self.searchBarController setSearchResultsDataSource:self];
    [self.searchBarController setSearchResultsDelegate:nil];
    
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setPlaceholder:@"Search Vestium." ];
//    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar setDelegate:self];
//    [self.searchBar sizeToFit];
//    [self.searchBar setScopeButtonTitles:@[@"All", @"Users", @"Hashtags"]];
    
    
    // REPLACE THIS:
    CGRect useableSpace = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);

    self.tabelContentList = [[UITableView alloc] initWithFrame:useableSpace];
    [self.tabelContentList setTableHeaderView:self.searchBar];
    [self.tabelContentList setDataSource:self];
    [self.tabelContentList setDelegate:self];
    [self.tabelContentList setAlwaysBounceVertical:YES];
    [self.tabelContentList setBackgroundColor:[UIColor  clearColor]];
    
    [self.tabelContentList setContentOffset:CGPointMake(0,0) animated:NO];

    [self.view addSubview:self.tabelContentList];
    
    // Do any additional setup after loading the view.
    
    self.slidingViewController = (ECSlidingViewController*)[([[UIApplication sharedApplication] delegate]).window rootViewController];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isSearching) {
        return [resultSet count];
    }
    else {
        NSLog(@"%d", [querySet count]);
        return [querySet count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (isSearching) {
        cell.textLabel.text = [resultSet objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [querySet objectAtIndex:indexPath.row];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

//Search Function Responsible For Searching

- (void)searchTableList {
    NSString *searchString = self.searchBar.text;
    
    for (NSString *tempStr in querySet) {
        NSComparisonResult result = [tempStr compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame) {
            [resultSet addObject:tempStr];
        }
    }
}

// Search Bar Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    isSearching = YES;
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"Text change - %d",isSearching);
    
    //Remove all objects first.
    [resultSet removeAllObjects];
    
    if([searchText length] != 0) {
        isSearching = YES;
        [self searchTableList];
    }
    else {
        isSearching = NO;
    }
    // [self.tblContentList reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"Cancel clicked");
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [self.searchBar setShowsScopeBar:YES];
    //    [self.searchBarController setActive:YES animated:YES];
    [self searchTableList];
}

@end
