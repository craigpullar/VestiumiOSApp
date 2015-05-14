//
//  UploadViewController.h
//  Vestium
//
//  Created by Daniel Koehler on 27/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    BOOL mouseSwiped;
    CGPoint lastPoint;


}

-(void) showPicker;

@end
