//
//  CameraButton.m
//  Vestium
//
//  Created by Daniel Koehler on 27/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "CameraButton.h"

@implementation CameraButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.buttonColor = [UIColor colorWithRed: 0.934 green: 0.605 blue: 0.147 alpha: 1];
        self.highlightedColor = [UIColor grayColor ];
    
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self setNeedsDisplay];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(57.31, 17.79)];
    [bezierPath addCurveToPoint: CGPointMake(57.31, 57.43) controlPoint1: CGPointMake(68.26, 28.73) controlPoint2: CGPointMake(68.26, 46.48)];
    [bezierPath addCurveToPoint: CGPointMake(17.67, 57.43) controlPoint1: CGPointMake(46.37, 68.38) controlPoint2: CGPointMake(28.62, 68.38)];
    [bezierPath addCurveToPoint: CGPointMake(17.67, 17.79) controlPoint1: CGPointMake(6.73, 46.48) controlPoint2: CGPointMake(6.73, 28.73)];
    [bezierPath addCurveToPoint: CGPointMake(57.31, 17.79) controlPoint1: CGPointMake(28.62, 6.84) controlPoint2: CGPointMake(46.37, 6.84)];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    bezierPath.usesEvenOddFillRule = YES;
    
    if (self.highlighted){
        [self.highlightedColor setFill];
    } else {
        [self.buttonColor setFill];
    }

    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(74.99, 37.49)];
    [bezier2Path addCurveToPoint: CGPointMake(37.49, 74.99) controlPoint1: CGPointMake(74.99, 58.2) controlPoint2: CGPointMake(58.2, 74.99)];
    [bezier2Path addCurveToPoint: CGPointMake(0, 37.49) controlPoint1: CGPointMake(16.79, 74.99) controlPoint2: CGPointMake(0, 58.2)];
    [bezier2Path addCurveToPoint: CGPointMake(37.49, 0) controlPoint1: CGPointMake(0, 16.78) controlPoint2: CGPointMake(16.79, 0)];
    [bezier2Path addCurveToPoint: CGPointMake(74.99, 37.49) controlPoint1: CGPointMake(58.2, 0) controlPoint2: CGPointMake(74.99, 16.78)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(37.49, 7.04)];
    [bezier2Path addCurveToPoint: CGPointMake(7.17, 37.36) controlPoint1: CGPointMake(20.75, 7.04) controlPoint2: CGPointMake(7.17, 20.62)];
    [bezier2Path addCurveToPoint: CGPointMake(37.49, 67.69) controlPoint1: CGPointMake(7.17, 54.11) controlPoint2: CGPointMake(20.75, 67.69)];
    [bezier2Path addCurveToPoint: CGPointMake(67.81, 37.36) controlPoint1: CGPointMake(54.24, 67.69) controlPoint2: CGPointMake(67.81, 54.11)];
    [bezier2Path addCurveToPoint: CGPointMake(37.49, 7.04) controlPoint1: CGPointMake(67.81, 20.62) controlPoint2: CGPointMake(54.24, 7.04)];
    [bezier2Path closePath];
    bezier2Path.miterLimit = 4;
    
    bezier2Path.usesEvenOddFillRule = YES;
    
    [[UIColor whiteColor] setFill];
    [bezier2Path fill];
    
    


    
    

    
}


@end
