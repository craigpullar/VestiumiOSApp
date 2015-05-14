//
//  VUIImagePickerController.m
//  Vestium
//
//  Created by Daniel Koehler on 28/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//


#import "VUIImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface VUIImagePickerController ()

@end

@implementation VUIImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.allowsEditing = NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        self.sourceType = UIImagePickerControllerSourceTypeCamera; //if there is a camera avaliable
        
    } else {
        
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//otherwise go to the folder
        
    }
    
    self.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        self.showsCameraControls = NO;
        
        self.overlayView = [[CameraControlView alloc] initWithFrame:self.cameraOverlayView.frame];
        
        [self setCameraOverlayView:self.overlayView];
    
        // Device's screen size (ignoring rotation intentionally):
        //For iphone 5+
        //Camera is 426 * 320. Screen height is 568.  Multiply by 1.333 in 5 inch to fill vertical
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0); //This slots the preview exactly in the middle of the screen by moving it down 71 points
        self.cameraViewTransform = translate;
        
        CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
        self.cameraViewTransform = scale;
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didPressPhotoButton:(id)button
{
    
    [self takePicture];
    
    NSLog(@"Picker received takePhoto message");

}

-(void) didPressCancelButton: (id) button
{
    
    NSLog(@"Picker received cancel message");
    
    [self.delegate imagePickerControllerDidCancel:self];

}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.overlayView showControls];
    
}


-(void) flashEnabled:(BOOL)enabled
{
    
}


@end
