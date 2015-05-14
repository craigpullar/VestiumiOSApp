//
//  UploadViewController.m
//  Vestium
//
//  Created by Daniel Koehler on 27/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#include <stdlib.h>
#import <FontasticIcons.h>

#import "UploadViewController.h"

#import "VUITag.h"
#import "VestiumUI.h"

#define TAGGING_IMAGE_X_INSET 0.0f
#define TAGGING_IMAGE_Y_INSET 0.0f
#define TAGGING_IMAGE_WIDTH self.view.bounds.size.width
#define TAGGING_IMAGE_HEIGHT self.view.bounds.size.height

#define RETAKE_X_INSET 20.0f
#define RETAKE_Y_INSET self.view.bounds.size.height - RETAKE_HEIGHT - RETAKE_X_INSET
#define RETAKE_WIDTH 70.0f
#define RETAKE_HEIGHT 16.0f

#define CAMERA_EXIT_X_INSET CAMERA_EXIT_Y_INSET
#define CAMERA_EXIT_Y_INSET (40.0f - CAMERA_EXIT_HEIGHT) / 2.0f
#define CAMERA_EXIT_WIDTH   CAMERA_EXIT_HEIGHT
#define CAMERA_EXIT_HEIGHT  30.0f

#define CAMERA_TOP_OVERLAY_X_INSET 0.0f
#define CAMERA_TOP_OVERLAY_Y_INSET 0.0f
#define CAMERA_TOP_OVERLAY_WIDTH   self.view.bounds.size.width
#define CAMERA_TOP_OVERLAY_HEIGHT  40.0f


@interface UploadViewController ()

@property (nonatomic, strong) ECSlidingViewController *slidingViewController;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) CameraControlView *controllerView;

@property (nonatomic, strong) UIButton *retakeButton;

@property (nonatomic) VUIImagePickerController *imagePickerController;

@property (nonatomic, strong) NSTimer *cameraTimer;
@property (nonatomic) NSMutableArray *capturedImages;

@end

@implementation UploadViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        //set the title for the tab
        self.title = @"Upload";
        //set the image icon for the tab
        FIIcon *icon = [FIEntypoIcon cameraIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor blackColor]];
        
        [self.tabBarItem setImage:image];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Grab a reference we might need it later.
    self.slidingViewController = (ECSlidingViewController*)[([[UIApplication sharedApplication] delegate]).window rootViewController];
    
    //Appearance configuration
    self.navigationItem.hidesBackButton = YES;
    
    // Camera Picker
    self.imagePickerController = [[VUIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(TAGGING_IMAGE_X_INSET, TAGGING_IMAGE_Y_INSET, TAGGING_IMAGE_WIDTH, TAGGING_IMAGE_HEIGHT)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    // Tap to create tag recognizer
    UITapGestureRecognizer * tagCreationRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createTagAtPoint:)];
    tagCreationRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tagCreationRecognizer];
    
    UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTagAtPoint:)];
    [self.view addGestureRecognizer:panRecognizer];
    // Pan/drag to create tag recognizer
    
    // Retake Button


    // Add these subviews
    [self.view addSubview:self.imageView];
    
    // [self.view addSubview:self.retakeButton];
    // [self.view addGestureRecognizer:self.slidingViewController.panGesture];

}

-(void) showPicker
{
    [self presentViewController:self.imagePickerController animated:NO completion:nil];
}


- (void)viewDidAppear:(BOOL)animated{
    
}

//UIRotationGestureRecognizer

-(void) moveTagAtPoint:(UITapGestureRecognizer*) sender
{

}

- (void) createTagAtPoint:(UITapGestureRecognizer*) sender
{

    CGPoint point = [sender locationInView:self.view];
    VUITag *tag = [[VUITag alloc] initWithFrame:CGRectMake(point.x - (50), point.y - 30.0f, 75.0f, 60.0f)];
    [self.imageView addSubview:tag];
    
}

//
//- (void)createTagWithVector:(UITapGestureRecognizer*) sender
//{
//    NSLog(@"Vector");
//    NSLog(@"%@", sender);
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
    lastPoint.y -= 20;
    
}


#pragma mark - Toolbar actions


- (void)finishAndUpdate
{
    
    
    
//    [self dismissViewControllerAnimated:YES completion:NULL];
    
//    if ([self.capturedImages count] > 0)
//    {
//        if ([self.capturedImages count] == 1)
//        {
//            // Camera took a single picture.
//            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
//        }
//        else
//        {
//            // Camera took multiple pictures; use the list of images for animation.
//            self.imageView.animationImages = self.capturedImages;
//            self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
//            self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
//            [self.imageView startAnimating];
//        }
//        
//        // To be ready to start again, clear the captured images array.
//        [self.capturedImages removeAllObjects];
//    }
    
//    self.imagePickerController = nil;
}


#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.imageView setImage:image]; // (1836, 3264) 16/9 ratio
    
    self.controllerView = (CameraControlView *) picker.cameraOverlayView;
    [self.imageView addSubview:self.controllerView];
    
    [self dismissViewControllerAnimated:NO completion:NULL];

    [self.controllerView hideControls];
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *) picker
{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
