//
//  DetailedPostController.h
//  Vestium
//
//  Created by Daniel Koehler on 03/08/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface DetailedPostController : UIViewController

@property (nonatomic, strong) Post *post;

- (id)initWithPost;

@end
