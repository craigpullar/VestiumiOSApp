//
//  CameraControlView.h
//  Vestium
//
//  Created by Daniel Koehler on 27/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraButton.h"

@protocol CameraControlDelegate <NSObject>

@required

-(void) didPressPhotoButton:(id) button;

-(void) didPressCancelButton:(id) button;

-(void) flashEnabled:(BOOL) enabled;

@end

@interface CameraControlView : UIView

@property (nonatomic) BOOL *flashEnabled;
@property (nonatomic, strong) UIView *lowerOverlay;
@property (nonatomic, strong) UIView *upperOverlay;
@property (nonatomic, strong) CameraButton *photoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (strong, nonatomic) id<CameraControlDelegate> delegate;

-(void) hideControls;
-(void) showControls;

@end
