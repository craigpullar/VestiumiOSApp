//
//  CameraControlView.m
//  Vestium
//
//  Created by Daniel Koehler on 27/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <FontasticIcons.h>
#import "CameraControlView.h"

#define CAMERA_TOP_OVERLAY_X_INSET 0.0f
#define CAMERA_TOP_OVERLAY_Y_INSET 0.0f
#define CAMERA_TOP_OVERLAY_WIDTH   self.bounds.size.width
#define CAMERA_TOP_OVERLAY_HEIGHT  40.0f

#define CAMERA_FLASH_X_INSET (CAMERA_TOP_OVERLAY_WIDTH - CAMERA_FLASH_Y_INSET - CAMERA_FLASH_WIDTH)
#define CAMERA_FLASH_Y_INSET (CAMERA_TOP_OVERLAY_HEIGHT - CAMERA_FLASH_HEIGHT) / 2.0f
#define CAMERA_FLASH_WIDTH   CAMERA_FLASH_HEIGHT
#define CAMERA_FLASH_HEIGHT  20.0f

#define CAMERA_EXIT_X_INSET CAMERA_EXIT_Y_INSET
#define CAMERA_EXIT_Y_INSET (CAMERA_TOP_OVERLAY_HEIGHT - CAMERA_EXIT_HEIGHT) / 2.0f
#define CAMERA_EXIT_WIDTH   CAMERA_EXIT_HEIGHT
#define CAMERA_EXIT_HEIGHT  30.0f

#define CAMERA_BOTTOM_OVERLAY_X_INSET 0.0f
#define CAMERA_BOTTOM_OVERLAY_Y_INSET (self.bounds.size.height - CAMERA_BOTTOM_OVERLAY_HEIGHT)
#define CAMERA_BOTTOM_OVERLAY_WIDTH   self.bounds.size.width
#define CAMERA_BOTTOM_OVERLAY_HEIGHT  100.0f

#define CAMERA_BUTTON_X_INSET (CAMERA_BOTTOM_OVERLAY_WIDTH / 2.0f) - (75.0f / 2.0f)
#define CAMERA_BUTTON_Y_INSET (CAMERA_BOTTOM_OVERLAY_HEIGHT / 2.0f) - (75.0f / 2.0f)
#define CAMERA_BUTTON_WIDTH   75.0f
#define CAMERA_BUTTON_HEIGHT  75.0f


@implementation CameraControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.upperOverlay = [[UIView alloc] initWithFrame:CGRectMake(CAMERA_TOP_OVERLAY_X_INSET, CAMERA_TOP_OVERLAY_Y_INSET, CAMERA_TOP_OVERLAY_WIDTH, CAMERA_TOP_OVERLAY_HEIGHT)];
        self.upperOverlay.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        
        self.lowerOverlay = [[UIView alloc] initWithFrame:CGRectMake(CAMERA_BOTTOM_OVERLAY_X_INSET, CAMERA_BOTTOM_OVERLAY_Y_INSET, CAMERA_BOTTOM_OVERLAY_WIDTH, CAMERA_BOTTOM_OVERLAY_HEIGHT)];
        self.lowerOverlay.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        
        self.photoButton = [[CameraButton alloc] initWithFrame:CGRectMake(CAMERA_BUTTON_X_INSET, CAMERA_BUTTON_Y_INSET, CAMERA_BUTTON_WIDTH, CAMERA_BUTTON_HEIGHT)];
        
        [self.photoButton addTarget:self.delegate action:@selector(didPressPhotoButton:) forControlEvents:UIControlEventTouchUpInside];

        self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(CAMERA_FLASH_X_INSET, CAMERA_FLASH_Y_INSET, CAMERA_FLASH_WIDTH, CAMERA_FLASH_HEIGHT)];
        FIIcon *icon = [FIEntypoIcon flashIcon];
        FIIconLayer *layer = [FIIconLayer new];
        layer.icon = icon;
        layer.frame = self.flashButton.bounds;
        layer.iconColor = [UIColor whiteColor];
        [self.flashButton.layer addSublayer:layer];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CAMERA_EXIT_X_INSET, CAMERA_EXIT_Y_INSET, CAMERA_EXIT_WIDTH, CAMERA_EXIT_HEIGHT)];
        FIIcon *exitIcon = [FIEntypoIcon crossIcon];
        FIIconLayer *exitLayer = [FIIconLayer new];
        exitLayer.icon = exitIcon;
        exitLayer.frame = CGRectMake(CAMERA_EXIT_X_INSET + 3, CAMERA_EXIT_Y_INSET + 3, CAMERA_EXIT_WIDTH - 16, CAMERA_EXIT_HEIGHT - 16);
        exitLayer.iconColor = [UIColor whiteColor];
        [self.cancelButton.layer addSublayer:exitLayer];
        
        [self.cancelButton addTarget:self.delegate action:@selector(didPressCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.upperOverlay addSubview:self.cancelButton];
        [self.upperOverlay addSubview:self.flashButton];
        [self.lowerOverlay addSubview:self.photoButton];
        
        [self addSubview:self.upperOverlay];
        [self addSubview:self.lowerOverlay];
    }
    
    return self;
}

- (void) hideControls
{
        
    [UIView animateWithDuration:.3 animations:^{
        
        [self.flashButton setFrame:CGRectMake(CAMERA_FLASH_X_INSET - CAMERA_TOP_OVERLAY_WIDTH, CAMERA_FLASH_Y_INSET, CAMERA_FLASH_WIDTH, CAMERA_FLASH_HEIGHT)];
        [self.cancelButton setFrame:CGRectMake(CAMERA_EXIT_X_INSET - CAMERA_TOP_OVERLAY_WIDTH, CAMERA_EXIT_Y_INSET, CAMERA_EXIT_WIDTH, CAMERA_EXIT_HEIGHT)];
    
        [self.lowerOverlay setFrame:CGRectMake(CAMERA_BOTTOM_OVERLAY_X_INSET, CAMERA_BOTTOM_OVERLAY_Y_INSET + CAMERA_BOTTOM_OVERLAY_HEIGHT, CAMERA_BOTTOM_OVERLAY_WIDTH, CAMERA_BOTTOM_OVERLAY_HEIGHT)];
        
    }];
    
}


- (void) showControls
{
    
    [UIView animateWithDuration:.3 animations:^{
        
        [self.flashButton setFrame:CGRectMake(CAMERA_FLASH_X_INSET, CAMERA_FLASH_Y_INSET, CAMERA_FLASH_WIDTH, CAMERA_FLASH_HEIGHT)];
        [self.cancelButton setFrame:CGRectMake(CAMERA_EXIT_X_INSET, CAMERA_EXIT_Y_INSET, CAMERA_EXIT_WIDTH, CAMERA_EXIT_HEIGHT)];
        
        [self.lowerOverlay setFrame:CGRectMake(CAMERA_BOTTOM_OVERLAY_X_INSET, CAMERA_BOTTOM_OVERLAY_Y_INSET, CAMERA_BOTTOM_OVERLAY_WIDTH, CAMERA_BOTTOM_OVERLAY_HEIGHT)];
        
    }];
    
}


@end
