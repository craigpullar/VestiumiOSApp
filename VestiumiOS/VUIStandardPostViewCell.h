//
//  VUIStandardPostViewCell.h
//  Vestium
//
//  Created by Daniel Koehler on 24/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "Post.h"
#import <UIKit/UIKit.h>


@interface VUIStandardPostViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic) float openCellLastTX;

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) UIPanGestureRecognizer *edgePanGestureRecognizer;

@property (strong, nonatomic) UIView* postSliderLeft;
@property (strong, nonatomic) UIView* postSliderRight;

@end
