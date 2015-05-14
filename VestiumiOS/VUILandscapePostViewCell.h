//
//  VUILandscapePostViewCelll.h
//  Vestium
//
//  Created by Daniel Koehler on 29/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Post.h"

@interface VUILandscapePostViewCell : UICollectionViewCell

@property (strong, nonatomic) Post *post;

- (void)configureWithImage;

@end
