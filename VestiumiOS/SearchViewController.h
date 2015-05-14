//
//  SearchViewController.h
//  Vestium
//
//  Created by Daniel Koehler on 30/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
    
    NSMutableArray *querySet;
    NSMutableArray *resultSet;
    BOOL isSearching;
    
}

@property (strong, nonatomic) UITableView *tabelContentList;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarController;

@end