//
//  ImagePanScrollBarView.m
//  SubjectiveCImagePan
//
//  Created by Sam Page on 16/02/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import "ImagePanScrollBarView.h"

@interface ImagePanScrollBarView ()
@property (nonatomic, strong) CAShapeLayer *scrollBarLayer;
@end

@implementation ImagePanScrollBarView

- (id)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)edgeInsets;
{
    
    if (self = [super initWithFrame:frame])
    {
        UIBezierPath *scrollBarPath = [UIBezierPath bezierPath];
        [scrollBarPath moveToPoint:CGPointMake(edgeInsets.left, CGRectGetHeight(self.bounds) - edgeInsets.bottom)];
        [scrollBarPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - edgeInsets.right, CGRectGetHeight(self.bounds) - edgeInsets.bottom)];
        
        CAShapeLayer *scrollBarBackgroundLayer = [CAShapeLayer layer];
        scrollBarBackgroundLayer.path = scrollBarPath.CGPath;
        scrollBarBackgroundLayer.lineWidth = 2.f;
        scrollBarBackgroundLayer.strokeColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor];
        scrollBarBackgroundLayer.fillColor = [[UIColor clearColor] CGColor];
        
        [self.layer addSublayer:scrollBarBackgroundLayer];
        
        self.scrollBarLayer = [CAShapeLayer layer];
        self.scrollBarLayer.path = scrollBarPath.CGPath;
        self.scrollBarLayer.lineWidth = 2.f;
        self.scrollBarLayer.strokeColor = [[UIColor colorWithRed: 0.934 green: 0.605 blue: 0.147 alpha: 1] CGColor];
        self.scrollBarLayer.fillColor = [[UIColor clearColor] CGColor];
        self.scrollBarLayer.actions = @{@"strokeStart": [NSNull null], @"strokeEnd": [NSNull null]};
        
        [self.layer addSublayer:self.scrollBarLayer];
    }
    
    return self;
}

- (void)updateWithScrollAmount:(CGFloat)scrollAmount forScrollableWidth:(CGFloat)scrollableWidth inScrollableArea:(CGFloat)scrollableArea
{
    self.scrollBarLayer.strokeStart = scrollAmount * scrollableArea;
    self.scrollBarLayer.strokeEnd = (scrollAmount * scrollableArea) + scrollableWidth;
}

@end
