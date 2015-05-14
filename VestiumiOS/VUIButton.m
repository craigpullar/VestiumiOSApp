//
//  VUIButton.m
//  Vestium
//
//  Created by Daniel Koehler on 21/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "VUIButton.h"
#import "UIImage+FlatUI.h"

@interface VUIButton()
@property(nonatomic) UIEdgeInsets defaultEdgeInsets;
@property(nonatomic) UIEdgeInsets normalEdgeInsets;
@property(nonatomic) UIEdgeInsets highlightedEdgeInsets;
@end

@implementation VUIButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.defaultEdgeInsets = self.titleEdgeInsets;
        self.cornerRadius = 2.0f;
        self.buttonColor = [UIColor colorWithRed:255/255.0 green:172/255.0 blue:6/255.0 alpha:1];
        self.shadowColor = [UIColor colorWithRed:221/255.0 green:146/255.0 blue:14/255.0 alpha:1];

    }
    return self;
}

- (void) setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    [super setTitleEdgeInsets:titleEdgeInsets];
    self.defaultEdgeInsets = titleEdgeInsets;
    [self setShadowHeight:self.shadowHeight];
}

- (void) setHighlighted:(BOOL)highlighted {
    UIEdgeInsets insets = highlighted ? self.highlightedEdgeInsets : self.normalEdgeInsets;
    [super setTitleEdgeInsets:insets];
    [super setHighlighted:highlighted];
}

- (void) setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self configureFlatButton];
}

- (void) setButtonColor:(UIColor *)buttonColor {
    _buttonColor = buttonColor;
    [self configureFlatButton];
}

- (void) setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    [self configureFlatButton];
}

- (void) setHighlightedColor:(UIColor *)highlightedColor {
    _highlightedColor = highlightedColor;
    [self configureFlatButton];
}

- (void) setDisabledColor:(UIColor *)disabledColor {
    _disabledColor = disabledColor;
    [self configureFlatButton];
}

- (void) setDisabledShadowColor:(UIColor *)disabledShadowColor {
    _disabledShadowColor = disabledShadowColor;
    [self configureFlatButton];
}

- (void) setShadowHeight:(CGFloat)shadowHeight {
    _shadowHeight = shadowHeight;
    UIEdgeInsets insets = self.defaultEdgeInsets;
    insets.top += shadowHeight;
    self.highlightedEdgeInsets = insets;
    insets.top -= shadowHeight * 2.0f;
    self.normalEdgeInsets = insets;
    [super setTitleEdgeInsets:insets];
    [self configureFlatButton];
}

- (void) configureFlatButton {
    UIImage *normalBackgroundImage = [UIImage buttonImageWithColor:self.buttonColor
                                                      cornerRadius:self.cornerRadius
                                                       shadowColor:self.shadowColor
                                                      shadowInsets:UIEdgeInsetsMake(0, 0, self.shadowHeight, 0)];
    
    UIColor *highlightedColor = self.highlightedColor == nil ? self.buttonColor : self.highlightedColor;
    UIImage *highlightedBackgroundImage = [UIImage buttonImageWithColor:highlightedColor
                                                           cornerRadius:self.cornerRadius
                                                            shadowColor:[UIColor clearColor]
                                                           shadowInsets:UIEdgeInsetsMake(self.shadowHeight, 0, 0, 0)];
    
    if (self.disabledColor) {
        UIColor *disabledShadowColor = self.disabledShadowColor == nil ? self.shadowColor : self.disabledShadowColor;
        UIImage *disabledBackgroundImage = [UIImage buttonImageWithColor:self.disabledColor
                                                            cornerRadius:self.cornerRadius
                                                             shadowColor:disabledShadowColor
                                                            shadowInsets:UIEdgeInsetsMake(0, 0, self.shadowHeight, 0)];
        [self setBackgroundImage:disabledBackgroundImage forState:UIControlStateDisabled];
    }
    
    [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
}

@end
