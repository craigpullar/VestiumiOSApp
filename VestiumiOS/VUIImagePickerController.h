//
//  VUIImagePickerController.h
//  Vestium
//
//  Created by Daniel Koehler on 28/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraControlView.h"

@interface VUIImagePickerController : UIImagePickerController <CameraControlDelegate>

@property (nonatomic, strong) CameraControlView *overlayView;

@end
