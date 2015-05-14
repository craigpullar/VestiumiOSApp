//
//  VUITextField.m
//  Vestium
//
//  Created by Daniel Koehler on 21/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "VUITextField.h"

@implementation VUITextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
        
        [self setBorderStyle:UITextBorderStyleNone];
        [self setKeyboardAppearance:UIKeyboardAppearanceDark];
//        [self setFont:[UIFont flatFontOfSize:16.0f]];
        [[self layer] setCornerRadius:2.0f];
        [self setBackgroundColor:[UIColor colorWithRed:0.04f green:0.04f blue:0.04f alpha:1.0f]];
        
        self.delegate = self;
    }
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    
    UIColor *colour = [UIColor lightTextColor];
    if ([self.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)]) {
        // iOS7 and later
        NSDictionary *attributes = @{NSForegroundColorAttributeName: colour, NSFontAttributeName: self.font};
        CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
        [self.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}
@end
