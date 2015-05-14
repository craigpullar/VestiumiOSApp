//
//  VUITag.m
//  Vestium
//
//  Created by Daniel Koehler on 29/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "VUITag.h"
#import <QuartzCore/QuartzCore.h>

#define kFilteringFactor   0.1
#define kROTATE_ORIGIN_X 53.95

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation VUITag

- (id)initWithFrame:(CGRect)frame 
{
    
    self = [super initWithFrame:frame];
    
    self.bounds = CGRectMake(0, 0, kROTATE_ORIGIN_X * 2, 45);
    
    if (self) {
    
        // Initialization code
        
        self.style = VUITagStyleBlack;
        
        self.backgroundColor =[UIColor clearColor];
        
    }
    
    if (frame.origin.x + kROTATE_ORIGIN_X > 160) {
        
        self.initialRotation = DEGREES_TO_RADIANS(180);
        [self rotate:0.0f];
        
    }
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.magnetometerUpdateInterval  = 1.0/10.0; // Update at 10Hz
    if (motionManager.magnetometerAvailable) {
        queue = [NSOperationQueue currentQueue];
        
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
            
            
            [self rotate:(motion.attitude.roll / 2.0f)];
            
            
        }];
    }
    
    return self;
}

-(void) rotate:(float) radians
{
    
    CGFloat x = radians;
    
    x = x * kFilteringFactor + x * (1.0 - kFilteringFactor);
    
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:0.1];
    self.transform = CGAffineTransformMakeRotation(self.initialRotation - x);
    [UIView commitAnimations];
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    
    UIColor* tagPrimary = [UIColor colorWithRed: 0.076 green: 0.076 blue: 0.076 alpha: 1];
    UIColor* tagSecondary = [UIColor colorWithRed: 0.992 green: 0.613 blue: 0.047 alpha: 1];
    
    if (self.style == VUITagStyleWhite) {
        
    } else if (self.style == VUITagStyleOrange){
        
    }
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0.67, 43.25)];
    [bezierPath addCurveToPoint: CGPointMake(2.22, 43.88) controlPoint1: CGPointMake(1.08, 43.66) controlPoint2: CGPointMake(1.64, 43.89)];
    [bezierPath addLineToPoint: CGPointMake(53.81, 43.85)];
    [bezierPath addCurveToPoint: CGPointMake(55.36, 43.21) controlPoint1: CGPointMake(54.39, 43.85) controlPoint2: CGPointMake(54.95, 43.62)];
    [bezierPath addLineToPoint: CGPointMake(75.02, 23.53)];
    [bezierPath addCurveToPoint: CGPointMake(75.01, 20.45) controlPoint1: CGPointMake(75.86, 22.68) controlPoint2: CGPointMake(75.86, 21.3)];
    [bezierPath addLineToPoint: CGPointMake(55.33, 0.65)];
    [bezierPath addCurveToPoint: CGPointMake(53.78, 0) controlPoint1: CGPointMake(54.92, 0.23) controlPoint2: CGPointMake(54.36, 0)];
    [bezierPath addLineToPoint: CGPointMake(2.18, 0.04)];
    [bezierPath addCurveToPoint: CGPointMake(0.64, 0.68) controlPoint1: CGPointMake(1.58, 0.04) controlPoint2: CGPointMake(1.03, 0.28)];
    [bezierPath addCurveToPoint: CGPointMake(0, 2.22) controlPoint1: CGPointMake(0.24, 1.07) controlPoint2: CGPointMake(0, 1.62)];
    [bezierPath addLineToPoint: CGPointMake(0.03, 41.7)];
    [bezierPath addCurveToPoint: CGPointMake(0.67, 43.25) controlPoint1: CGPointMake(0.03, 42.28) controlPoint2: CGPointMake(0.26, 42.84)];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    [tagPrimary setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(53.95, 27.91)];
    [bezier2Path addCurveToPoint: CGPointMake(47.81, 21.76) controlPoint1: CGPointMake(50.55, 27.9) controlPoint2: CGPointMake(47.81, 25.15)];
    [bezier2Path addCurveToPoint: CGPointMake(53.95, 15.63) controlPoint1: CGPointMake(47.81, 18.37) controlPoint2: CGPointMake(50.56, 15.62)];
    [bezier2Path addCurveToPoint: CGPointMake(60.09, 21.77) controlPoint1: CGPointMake(57.34, 15.63) controlPoint2: CGPointMake(60.09, 18.38)];
    [bezier2Path addCurveToPoint: CGPointMake(53.95, 27.91) controlPoint1: CGPointMake(60.09, 25.16) controlPoint2: CGPointMake(57.34, 27.91)];
    [bezier2Path closePath];
    bezier2Path.miterLimit = 4;
    
    [tagSecondary setFill];
    [bezier2Path fill];
    
}


@end
