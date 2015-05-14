//
//  RegistrationViewController.h
//  Vestium
//
//  Created by Daniel Koehler on 21/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "Vestium.h"
#import <UIKit/UIKit.h>

@interface RegistrationViewController : UIViewController <UIGestureRecognizerDelegate,VestiumUserDelegate>
{
    
    UIView    *registrationBackgroundView;
    
    VUITextField *usernameTextField;
    VUITextField *passwordTextField;
    
    UIImageView *wallImageView;
    UIImageView *logoImageView;
    
    VUIButton *signInButton;
    
    UILabel   *photoCreditLabel;
    UILabel *photoCreditUsername;
    UIImageView   *photoCreditImageView;
    
}

@property (nonatomic) BOOL *animated;
@property (strong, nonatomic) Vestium *vestium;
@end