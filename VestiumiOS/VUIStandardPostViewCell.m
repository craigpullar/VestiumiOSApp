//
//  VUIStandardPostViewCell.m
//  Vestium
//
//  Created by Daniel Koehler on 24/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "LEColorPicker.h"
#import "VUIStandardPostViewCell.h"
#import "STTweetLabel.h"

#ifndef MIN
#import <NSObjCRuntime.h>
#endif

#define POST_IMAGE_VIEW_X_INSET 0.0f
#define POST_IMAGE_VIEW_Y_INSET 0.0f
#define POST_IMAGE_VIEW_WIDTH   self.bounds.size.width
#define POST_IMAGE_VIEW_HEIGHT  (self.bounds.size.height - POST_DESCRIPTION_VIEW_HEIGHT)

#define POST_DESCRIPTION_VIEW_X_INSET 0.0f
#define POST_DESCRIPTION_VIEW_Y_INSET POST_IMAGE_VIEW_HEIGHT
#define POST_DESCRIPTION_VIEW_WIDTH   self.bounds.size.width
#define POST_DESCRIPTION_VIEW_HEIGHT  120.0f

#define POSTED_BY_IMAGE_X_INSET 20.0f
#define POSTED_BY_IMAGE_Y_INSET 13.0f
#define POSTED_BY_IMAGE_WIDTH   24.0f
#define POSTED_BY_IMAGE_HEIGHT  24.0f

#define POSTED_BY_LABEL_X_INSET POSTED_BY_IMAGE_X_INSET + POSTED_BY_IMAGE_WIDTH + 13.0f
#define POSTED_BY_LABEL_Y_INSET POSTED_BY_IMAGE_Y_INSET
#define POSTED_BY_LABEL_WIDTH   200.0f
#define POSTED_BY_LABEL_HEIGHT  24.0f

#define POSTED_BY_TIME_X_INSET self.bounds.size.width - POSTED_BY_TIME_WIDTH
#define POSTED_BY_TIME_Y_INSET POSTED_BY_IMAGE_Y_INSET
#define POSTED_BY_TIME_WIDTH   50.0f
#define POSTED_BY_TIME_HEIGHT  24.0f

#define TABLE_CELL_PULL_TAB_X_INSET self.bounds.size.width - 15.0f
#define TABLE_CELL_PULL_TAB_Y_INSET 25.0f
#define TABLE_CELL_PULL_TAB_WIDTH   .5f
#define TABLE_CELL_PULL_TAB_HEIGHT  30.0f

#define STARS_X_INSET POSTED_BY_IMAGE_X_INSET
#define STARS_Y_INSET POSTED_BY_IMAGE_Y_INSET + POSTED_BY_IMAGE_HEIGHT
#define STARS_WIDTH   200.0f
#define STARS_HEIGHT  30.0f

#define SHARES_X_INSET STARS_X_INSET + STARS_WIDTH
#define SHARES_Y_INSET POSTED_BY_IMAGE_Y_INSET + POSTED_BY_IMAGE_HEIGHT
#define SHARES_WIDTH   100.0f
#define SHARES_HEIGHT  30.0f

#define FAST_ANIMATION_DURATION 0.25
#define SLOW_ANIMATION_DURATION 0.45
#define PAN_CLOSED_X 0
#define PAN_OPEN_X -300

//#define POSTED_BY_SHARE_X_INSET self.frame.size.width - 13.0f
//#define POSTED_BY_SHARE_Y_INSET POSTED_BY_IMAGE_Y_INSET
//#define POSTED_BY_SHARE_WIDTH   100.0f
//#define POSTED_BY_SHARE_HEIGHT  24.0f

@implementation VUIStandardPostViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
        
        self.edgePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self.edgePanGestureRecognizer setDelegate:self];
        
    }
    
    return self;
}

- (void) layoutSubviews
{
    [[self layer] setMasksToBounds:YES];
    
    [self layoutPostImage];
    [self layoutPostDescriptionLeft];
    [self layoutPostDescriptionRight];

}

-(void) layoutPostImage
{
    
    // Create main post image view
    UIImageView *postImage = [[UIImageView alloc] initWithFrame:CGRectMake(POST_IMAGE_VIEW_X_INSET, POST_IMAGE_VIEW_Y_INSET, POST_IMAGE_VIEW_WIDTH, POST_IMAGE_VIEW_HEIGHT)];

    __weak typeof(postImage) weakPostImage = postImage;
    
    [postImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.post.imagePath]] placeholderImage:[UIImage imageWithColor:self.post.pastel cornerRadius:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        [weakPostImage setImage:image];
        
        // Success
    
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    
        // Failure
    
    }];
    
    [postImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.contentView addSubview:postImage];
    
}


-(void) layoutPostDescriptionLeft {
    
    self.postSliderLeft = [[UIView alloc] initWithFrame:CGRectMake(POST_DESCRIPTION_VIEW_X_INSET, POST_DESCRIPTION_VIEW_Y_INSET, POST_DESCRIPTION_VIEW_WIDTH, POST_DESCRIPTION_VIEW_HEIGHT)];
    [self.postSliderLeft setBackgroundColor:[UIColor whiteColor]];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGestureRecognizer setDelegate:self];
    [self.postSliderLeft addGestureRecognizer:panGestureRecognizer];
    
    self.postSliderLeft.layer.borderColor = [UIColor clearColor].CGColor;
    
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(POSTED_BY_IMAGE_X_INSET, POSTED_BY_IMAGE_Y_INSET, POSTED_BY_IMAGE_WIDTH, POSTED_BY_IMAGE_HEIGHT)];
    [[userImageView layer] setMasksToBounds:YES];
    [[userImageView layer] setCornerRadius:12.0f]; // Round corners
    [userImageView setImage:[UIImage imageNamed:@"test_user@2x.png"]]; // Set image
    [userImageView setUserInteractionEnabled:YES];
    userImageView.layer.shouldRasterize = YES;
    userImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    NSString *postedBy = [NSString stringWithFormat:@"%@ %@", self.post.user.firstName, self.post.user.lastName];
    
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(POSTED_BY_LABEL_X_INSET, POSTED_BY_LABEL_Y_INSET, POSTED_BY_LABEL_WIDTH, POSTED_BY_LABEL_HEIGHT)];
    [usernameLabel setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [usernameLabel setBackgroundColor:[UIColor clearColor]];
    [usernameLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    [usernameLabel setText:postedBy];
    
    CALayer *activeMark = [CALayer layer];
    activeMark.frame = CGRectMake(TABLE_CELL_PULL_TAB_X_INSET, TABLE_CELL_PULL_TAB_Y_INSET, TABLE_CELL_PULL_TAB_WIDTH,  TABLE_CELL_PULL_TAB_HEIGHT);
    activeMark.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;

    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(POSTED_BY_TIME_X_INSET, POSTED_BY_TIME_Y_INSET, POSTED_BY_TIME_WIDTH, POSTED_BY_TIME_HEIGHT)];
    
    [timeLabel setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    [timeLabel setText:[NSDate stringForDisplayFromDate:self.post.pubDate]];
    
    UILabel *starsLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARS_X_INSET, STARS_Y_INSET, STARS_WIDTH, STARS_HEIGHT)];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *stars = [formatter stringFromNumber:[NSNumber numberWithInteger:self.post.numLikes]];
    NSString *shares = [formatter stringFromNumber:[NSNumber numberWithInteger:self.post.numShares]];
    
    [starsLabel setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [starsLabel setBackgroundColor:[UIColor clearColor]];
    [starsLabel setTextColor:[UIColor colorWithWhite:0.4 alpha:1.0f]];
    [starsLabel setText:[NSString stringWithFormat:@"%@ stars  |  %@ shares", stars, shares]];
    
    UILabel *sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(SHARES_X_INSET, SHARES_Y_INSET,SHARES_WIDTH, SHARES_HEIGHT)];
    
    [sharesLabel setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [sharesLabel setBackgroundColor:[UIColor clearColor]];
    [sharesLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    [sharesLabel setText:@"127 stars"];
    
    STTweetLabel *txt = [[STTweetLabel alloc] initWithFrame:CGRectMake(20, 80, 280, 80)];
    [txt setText:self.post.description];
    [self.postSliderLeft addSubview:txt];
    
    
    [txt setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        if([protocol isEqualToString:@"http"]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
        }
        
    }];
    
//    [self.postSliderLeft.layer addSublayer:activeMark];
//    [self.postDescriptionView.layer addSublayer:borderTop];
//    [self.postDescriptionView.layer addSublayer:borderBottom];
    
    [self.postSliderLeft addSubview:timeLabel];
    [self.postSliderLeft addSubview:userImageView];
    [self.postSliderLeft addSubview:usernameLabel];
    
    //    [postDescriptionView addSubview:sharesLabel];
    [self.postSliderLeft addSubview:starsLabel];
    
    [self.contentView addSubview:self.postSliderLeft];
}


-(void) layoutPostDescriptionRight {
    
    self.postSliderRight = [[UIView alloc] initWithFrame:CGRectMake(POST_DESCRIPTION_VIEW_X_INSET + POST_DESCRIPTION_VIEW_WIDTH, POST_DESCRIPTION_VIEW_Y_INSET, POST_DESCRIPTION_VIEW_WIDTH, POST_DESCRIPTION_VIEW_HEIGHT)];
    [self.postSliderRight setBackgroundColor:[UIColor whiteColor]];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGestureRecognizer setDelegate:self];
    [self.postSliderRight addGestureRecognizer:panGestureRecognizer];

    self.postSliderRight.layer.borderColor = [UIColor clearColor].CGColor;
    
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(POSTED_BY_IMAGE_X_INSET, POSTED_BY_IMAGE_Y_INSET, POSTED_BY_IMAGE_WIDTH, POSTED_BY_IMAGE_HEIGHT)];
    [[userImageView layer] setMasksToBounds:YES];
    [[userImageView layer] setCornerRadius:4.0f]; // Round corners
    [userImageView setImage:[UIImage imageNamed:@"test_user@2x.png"]]; // Set image
    [userImageView setUserInteractionEnabled:YES];
    userImageView.layer.shouldRasterize = YES;
    userImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    NSString *postedBy = [NSString stringWithFormat:@"%@ %@", self.post.user.firstName, self.post.user.lastName];
    
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(POSTED_BY_LABEL_X_INSET, POSTED_BY_LABEL_Y_INSET, POSTED_BY_LABEL_WIDTH, POSTED_BY_LABEL_HEIGHT)];
    [usernameLabel setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [usernameLabel setBackgroundColor:[UIColor clearColor]];
    [usernameLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    [usernameLabel setText:postedBy];
    
    CALayer *activeMark = [CALayer layer];
    activeMark.frame = CGRectMake(TABLE_CELL_PULL_TAB_X_INSET, TABLE_CELL_PULL_TAB_Y_INSET, TABLE_CELL_PULL_TAB_WIDTH,  TABLE_CELL_PULL_TAB_HEIGHT);
    activeMark.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    
    //    CALayer *borderTop = [CALayer layer];
    //    borderTop.frame = CGRectMake(0.0f, 0.0f, POST_DESCRIPTION_VIEW_WIDTH, 0.5f);
    //    borderTop.backgroundColor = [UIColor colorWithWhite:0.3f alpha:1.0f].CGColor;
    //
    //    CALayer *borderBottom = [CALayer layer];
    //    borderBottom.frame = CGRectMake(0.0f, POST_DESCRIPTION_VIEW_HEIGHT-.5f, POST_DESCRIPTION_VIEW_WIDTH, 0.5f);
    //    borderBottom.backgroundColor = [UIColor colorWithWhite:0.3f alpha:1.0f].CGColor;
    
    
    UILabel *starsLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARS_X_INSET, STARS_Y_INSET - 15, STARS_WIDTH, STARS_HEIGHT)];
    
    [starsLabel setFont:[UIFont boldFlatFontOfSize:12.0f]];
    [starsLabel setBackgroundColor:[UIColor clearColor]];
    [starsLabel setTextColor:[UIColor colorWithWhite:0.4 alpha:1.0f]];
    [starsLabel setText:@"Share/Flag Screen"];

    //    [postDescriptionView addSubview:sharesLabel];
    [self.postSliderRight addSubview:starsLabel];
    
    [self.contentView addSubview:self.postSliderRight];
    
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint translation = [panGestureRecognizer translationInView:[[panGestureRecognizer view] superview] ];
    return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
}

#pragma mark - Gesture handlers

-(void) handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    float threshold = (PAN_OPEN_X+PAN_CLOSED_X)/2.0;
    float vX = 0.0;
    float compare;
    
    UIView *view = self.postSliderLeft;
    
    switch ([panGestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
       
            break;
            
        case UIGestureRecognizerStateEnded:
            
            vX = (FAST_ANIMATION_DURATION/2.0)*[panGestureRecognizer velocityInView:self].x;
            compare = view.transform.tx + vX;
            
            if (compare > threshold) {
                [self snapViewToX:PAN_CLOSED_X animated:YES];
                [self snapViewToX:PAN_CLOSED_X animated:YES];
                [self setOpenCellLastTX:0];
            
            } else {
                
                [self snapViewToX:PAN_OPEN_X animated:YES];
                [self snapViewToX:PAN_OPEN_X animated:YES];
                [self setOpenCellLastTX:view.transform.tx];
                
            }
            break;
        case UIGestureRecognizerStateChanged:
            
            compare = self.openCellLastTX+[panGestureRecognizer translationInView:self].x;
            
            if (compare > PAN_CLOSED_X)
                compare = PAN_CLOSED_X;
            else if (compare < PAN_OPEN_X)
                compare = PAN_OPEN_X;
            
            
            [self.postSliderLeft setTransform:CGAffineTransformMakeTranslation(compare, 0)];
            [self.postSliderRight setTransform:CGAffineTransformMakeTranslation(compare, 0)];
            
            break;
        default:
            break;
    }
}
-(void) snapViewToX:(float)x animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:FAST_ANIMATION_DURATION];
    }
    
    [self.postSliderLeft setTransform:CGAffineTransformMakeTranslation(x, 0)];
    [self.postSliderRight setTransform:CGAffineTransformMakeTranslation(x, 0)];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
