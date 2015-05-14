//
//  RegistrationViewController.m
//  Vestium
//
//  Created by Daniel Koehler on 21/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "RegistrationViewController.h"
#import "AppDelegate.h"
#import "TrendingViewController.h"

#define NAVIGATION_BAR_OFFSET 44.0f

#define LOG_IN_VIEW_X_INSET (self.view.frame.size.width/2.0f - LOG_IN_VIEW_WIDTH/2.0f)
#define LOG_IN_VIEW_Y_INSET (88.0f)
#define LOG_IN_VIEW_WIDTH   264.0f
#define LOG_IN_VIEW_HEIGHT  373.0f

#define LOGO_IMAGE_VIEW_X_INSET (LOG_IN_VIEW_WIDTH/2.0f - LOGO_IMAGE_VIEW_WIDTH/2.0f)
#define LOGO_IMAGE_VIEW_Y_INSET (22.0f)
#define LOGO_IMAGE_VIEW_WIDTH   75.0f
#define LOGO_IMAGE_VIEW_HEIGHT  103.0f

#define POSTED_BY_LABEL_X_INSET 215.0f
#define POSTED_BY_LABEL_Y_INSET (self.view.frame.size.height - POSTED_BY_LABEL_HEIGHT - 22.0f)
#define POSTED_BY_LABEL_WIDTH   60.0f
#define POSTED_BY_LABEL_HEIGHT  21.0f

#define POSTED_BY_IMAGE_X_INSET (POSTED_BY_LABEL_X_INSET + POSTED_BY_LABEL_WIDTH)
#define POSTED_BY_IMAGE_Y_INSET (self.view.frame.size.height - POSTED_BY_IMAGE_HEIGHT - 20.0f)
#define POSTED_BY_IMAGE_WIDTH   24.0f
#define POSTED_BY_IMAGE_HEIGHT  24.0f

#define DESCRIPTION_X_INSET SIGN_IN_BUTTON_X_INSET
#define DESCRIPTION_Y_INSET 10.0f
#define DESCRIPTION_WIDTH   SIGN_IN_BUTTON_WIDTH
#define DESCRIPTION_HEIGHT  21.0f

#define SIGN_IN_BUTTON_X_INSET ((LOG_IN_VIEW_WIDTH / 2) - (SIGN_IN_BUTTON_WIDTH / 2))
#define SIGN_IN_BUTTON_Y_INSET (70.0f + POSTED_BY_LABEL_HEIGHT)
#define SIGN_IN_BUTTON_WIDTH   200.0f
#define SIGN_IN_BUTTON_HEIGHT  50.0f

#define USERNAME_X_INSET DESCRIPTION_X_INSET
#define USERNAME_Y_INSET (LOGO_IMAGE_VIEW_HEIGHT + 50.0f)
#define USERNAME_WIDTH   DESCRIPTION_WIDTH
#define USERNAME_HEIGHT  35.0f

#define PASSWORD_X_INSET DESCRIPTION_X_INSET
#define PASSWORD_Y_INSET (USERNAME_Y_INSET + 50.0f)
#define PASSWORD_WIDTH   DESCRIPTION_WIDTH
#define PASSWORD_HEIGHT  35.0f


@interface RegistrationViewController () <UITextFieldDelegate>

@end

@implementation RegistrationViewController

// When the user signs in, save their username and hide this vc (revealing the landing vc)
-(void)pushSignInButton:(id)sender
{
    // Save username
    // [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:KP_USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Notify listeners that user has signed in
    // [[NSNotificationCenter defaultCenter] postNotificationName:KP_USER_LOGGED_IN_NOTIFICATION object:nil];
    
    // Side keyboard
    [self textFieldDidEndEditing:usernameTextField];
    [self dismissViewControllerAnimated:YES completion:nil]; // hide VC
    
    
}

// Set up the panning image view
-(void)setUpImageView
{
    
    //    UIImage *background = [UIImage imageNamed:@"test_background@2x.png"];
    //
    
    //    wallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (background.size.width / 2), self.view.frame.size.height)];
    wallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [wallImageView setContentMode:UIViewContentModeScaleAspectFill];
    //    [wallImageView setImage:background];
    [wallImageView setImage:[UIImage imageNamed:@"img_1253.jpg"]];
    [wallImageView setClipsToBounds:YES];
    [self.view addSubview:wallImageView];
    
}

// Pan background. this is so CPU intensive...
-(void) beginAnimatingBackground
{
    
    [UIView animateWithDuration:15.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        [wallImageView setFrame:CGRectMake(-(wallImageView.frame.size.width - self.view.frame.size.width), 0.0f, wallImageView.frame.size.width, self.view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:15.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [wallImageView setFrame:CGRectMake(0.0f, 0.0f, wallImageView.frame.size.width, self.view.frame.size.height)];
            
        } completion:^(BOOL finished) {
            
            [self beginAnimatingBackground];
        }];
    }];
}

// Set up central log in view
-(void)setUpLogInBackgroundView
{
    
    registrationBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(LOG_IN_VIEW_X_INSET, LOG_IN_VIEW_Y_INSET, LOG_IN_VIEW_WIDTH, LOG_IN_VIEW_HEIGHT)];
    [registrationBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.7f]];
    [[registrationBackgroundView layer] setMasksToBounds:YES];
    [[registrationBackgroundView layer] setCornerRadius:5.0f];
    
    logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LOGO_IMAGE_VIEW_X_INSET, LOGO_IMAGE_VIEW_Y_INSET, LOGO_IMAGE_VIEW_WIDTH, LOGO_IMAGE_VIEW_HEIGHT)];
    [logoImageView setImage:[UIImage imageNamed:@"vestium_logo_transparent@2x.png"]]; // Set image
    
    usernameTextField = [[VUITextField alloc] initWithFrame:CGRectMake(USERNAME_X_INSET, USERNAME_Y_INSET, USERNAME_WIDTH, USERNAME_HEIGHT)];
    [usernameTextField setDelegate:self];
    [usernameTextField setPlaceholder:@"Username"];
    [usernameTextField setReturnKeyType:UIReturnKeyDone];
    
    passwordTextField = [[VUITextField alloc] initWithFrame:CGRectMake(PASSWORD_X_INSET, PASSWORD_Y_INSET, PASSWORD_WIDTH, PASSWORD_HEIGHT)];
    [passwordTextField setDelegate:self];
    [passwordTextField setPlaceholder:@"Password"];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setReturnKeyType:UIReturnKeyDone];
    
    signInButton = [[VUIButton alloc] initWithFrame: CGRectMake(PASSWORD_X_INSET, PASSWORD_Y_INSET + 50.0f, PASSWORD_WIDTH, PASSWORD_HEIGHT)];
    
    [signInButton addTarget:self action:@selector(signInButtonWasPushed:) forControlEvents:UIControlEventTouchUpInside];
    [signInButton setShadowHeight:1.0f];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [signInButton.titleLabel setFont:[UIFont boldFlatFontOfSize:16.0f]];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    VUIButton *signUpButton = [[VUIButton alloc] initWithFrame: CGRectMake(PASSWORD_X_INSET, PASSWORD_Y_INSET + 100.0f, PASSWORD_WIDTH, PASSWORD_HEIGHT)];
    
    [signUpButton addTarget:self action:@selector(registerButtonWasPushed:) forControlEvents:UIControlEventTouchUpInside];
    [signUpButton setShadowHeight:1.0f];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitle:@"Register" forState:UIControlStateNormal];
    [signUpButton.titleLabel setFont:[UIFont boldFlatFontOfSize:16.0f]];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [signUpButton setButtonColor:[UIColor lightGrayColor]];
    [signUpButton setShadowColor:[UIColor grayColor]];
    
    [registrationBackgroundView addSubview:usernameTextField];
    [registrationBackgroundView addSubview:passwordTextField];
    [registrationBackgroundView addSubview:logoImageView];
    [registrationBackgroundView addSubview:signInButton];
    [registrationBackgroundView addSubview:signUpButton];
    
    [self.view addSubview:registrationBackgroundView];
}

-(void) enterHighlightedImageView:(id) sender
{
    
    [self pauseLayer:wallImageView.layer];
    
    [photoCreditLabel setUserInteractionEnabled:NO];
    [photoCreditImageView setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:.2 animations:^{
        
        [photoCreditImageView setFrame:CGRectMake(POSTED_BY_IMAGE_X_INSET - 10.0f, POSTED_BY_IMAGE_Y_INSET - 10.0f, POSTED_BY_IMAGE_WIDTH + 10.0f, POSTED_BY_IMAGE_HEIGHT + 10.0f)];
        [photoCreditLabel setFrame:CGRectMake(POSTED_BY_LABEL_X_INSET - 10.0f, POSTED_BY_LABEL_Y_INSET - 15.0f, POSTED_BY_LABEL_WIDTH, POSTED_BY_LABEL_HEIGHT)];
        
        [[photoCreditImageView layer] setCornerRadius:17.0f];
        
        [registrationBackgroundView setAlpha:0.0f];
        [photoCreditUsername setAlpha:1.0f];
        
    }];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHighlightedImageView:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    [self.view addGestureRecognizer:tapRecognizer];
    
}


-(void) dismissHighlightedImageView:(id) sender
{
    
    [photoCreditLabel setUserInteractionEnabled:YES];
    [photoCreditImageView setUserInteractionEnabled:YES];
    
    [UIView animateWithDuration:.2 animations:^{
        
        [photoCreditImageView setFrame:CGRectMake(POSTED_BY_IMAGE_X_INSET, POSTED_BY_IMAGE_Y_INSET, POSTED_BY_IMAGE_WIDTH, POSTED_BY_IMAGE_HEIGHT)];
        [photoCreditLabel setFrame:CGRectMake(POSTED_BY_LABEL_X_INSET, POSTED_BY_LABEL_Y_INSET, POSTED_BY_LABEL_WIDTH, POSTED_BY_LABEL_HEIGHT)];
        
        [[photoCreditImageView layer] setCornerRadius:12.0f];
        
        [photoCreditUsername setAlpha:0.0f];
        [registrationBackgroundView setAlpha:1.0f];
    }];
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    [self resumeLayer:wallImageView.layer];
    
    
}

// Set up label at the bottom
-(void)setUpInfoLabel
{
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterHighlightedImageView:)];
    
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    
    photoCreditLabel = [[UILabel alloc] initWithFrame:CGRectMake(POSTED_BY_LABEL_X_INSET, POSTED_BY_LABEL_Y_INSET, POSTED_BY_LABEL_WIDTH, POSTED_BY_LABEL_HEIGHT)];
    [photoCreditLabel setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [photoCreditLabel setTextAlignment:NSTextAlignmentLeft];
    [photoCreditLabel setBackgroundColor:[UIColor clearColor]];
    [photoCreditLabel setTextColor:[UIColor whiteColor]];
    [photoCreditLabel setText:@"Posted by"];
    [photoCreditLabel setUserInteractionEnabled:YES];
    [photoCreditLabel addGestureRecognizer:tapRecognizer];
    
    photoCreditUsername = [[UILabel alloc] initWithFrame:CGRectMake((POSTED_BY_LABEL_X_INSET + POSTED_BY_LABEL_WIDTH - 400.0f), POSTED_BY_LABEL_Y_INSET, 385.0f, POSTED_BY_LABEL_HEIGHT)];
    [photoCreditUsername setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [photoCreditUsername setTextAlignment:NSTextAlignmentRight];
    [photoCreditUsername setBackgroundColor:[UIColor clearColor]];
    [photoCreditUsername setTextColor:[UIColor whiteColor]];
    [photoCreditUsername setText:@"Nga H Nguyen"];
    [photoCreditUsername setAlpha:0.0f];
    
    
    photoCreditImageView = [[UIImageView alloc] initWithFrame:CGRectMake(POSTED_BY_IMAGE_X_INSET, POSTED_BY_IMAGE_Y_INSET, POSTED_BY_IMAGE_WIDTH, POSTED_BY_IMAGE_HEIGHT)];
    [[photoCreditImageView layer] setMasksToBounds:YES];
    [[photoCreditImageView layer] setCornerRadius:12.0f]; // Round corners
    [photoCreditImageView setImage:[UIImage imageNamed:@"profile.jpg"]]; // Set image
    [photoCreditImageView setUserInteractionEnabled:YES];
    [photoCreditImageView addGestureRecognizer:tapRecognizer];
    photoCreditImageView.layer.shouldRasterize = YES;
    photoCreditImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self.view addSubview:photoCreditImageView];
    [self.view addSubview:photoCreditUsername];
    [self.view addSubview:photoCreditLabel];
    
}

// When the user starts editing, move the log in view up and hide the keyboard
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [UIView animateWithDuration:.2 animations:^{
        [registrationBackgroundView setFrame:CGRectMake(LOG_IN_VIEW_X_INSET, LOG_IN_VIEW_Y_INSET - 60.0f, LOG_IN_VIEW_WIDTH, LOG_IN_VIEW_HEIGHT)];\
        //        [logoImageView setAlpha:0.6f];
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    [UIView animateWithDuration:.2 animations:^{
        
        [registrationBackgroundView setFrame:CGRectMake(LOG_IN_VIEW_X_INSET, LOG_IN_VIEW_Y_INSET, LOG_IN_VIEW_WIDTH, LOG_IN_VIEW_HEIGHT)];
        [logoImageView setAlpha:1.0f];
        
    }];
    
    return YES;
    
}

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
    self.vestium = [[Vestium alloc] init];
    self.vestium.delegate = self;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
	// Do any additional setup after loading the view.
    
    // [self setTitle:@"Register for Vestium"];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.81f]}];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    
    [self setUpImageView];
    [self setUpLogInBackgroundView];
    [self setUpInfoLabel];
    [self beginAnimatingBackground];
    
}

-(void) signInButtonWasPushed:(id)sender
{
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    [self.vestium loginUserWithUsername:username password:password];
    
    
}
- (void) didLoginUser:(User *)user {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) didCreateUser:(User *)user password:(NSString *)password
{
    [self.vestium loginUserWithUsername:user.username password:password];
}
-(void) didNotCreateUser:(User *)user
{
    NSLog(@"Failure");
}
-(void) registerButtonWasPushed:(id)sender
{
    NSString *username = usernameTextField.text;
    
    [self.vestium verifyUsernameAvalibilty:username];
}
-(void) didVerifyUsernameAvailability:(NSString *)username
{
    NSLog(@"Success");
    NSString *password = passwordTextField.text;
    [self.vestium registerUserWithFirstName:@"" lastName:@"" email:@"" username:username password:password image:nil];
}
-(void) didNotVerfiyUsername:(NSString *)username
{
    NSLog(@"Failure");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval paused_time = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = paused_time;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval paused_time = [layer timeOffset];
    layer.speed = 1.0f;
    layer.timeOffset = 0.0f;
    layer.beginTime = 0.0f;
    CFTimeInterval time_since_pause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - paused_time;
    layer.beginTime = time_since_pause;
}

@end



