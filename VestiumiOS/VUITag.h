//
//  VUITag.h
//  Vestium
//
//  Created by Daniel Koehler on 29/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

typedef NS_ENUM(NSInteger, VUITagStyle) {
    VUITagStyleBlack,
    VUITagStyleWhite,
    VUITagStyleOrange,
};

@interface VUITag : UIView {
    CMMotionManager *motionManager;
    NSOperationQueue *queue;
}

@property (nonatomic) float initialRotation;
@property (nonatomic) NSInteger identifier;
@property (nonatomic) VUITagStyle style;

//- (id)initWithFrame:(CGRect)frame style:

@end
