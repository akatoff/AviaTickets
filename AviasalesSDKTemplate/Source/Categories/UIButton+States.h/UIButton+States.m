//
//  UIButton+States.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "UIButton+States.h"
#import "UIImage+JRUIImage.h"

#define kkJRFilterButtonHiAlpha 0.4
#define kkJRFilterButtonDisAlpha 0.25
@implementation UIButton (States)

- (void)setSetupButtonStates:(BOOL)setupButtonStates {
    UIImage *normalImage = [self imageForState:UIControlStateNormal];
	UIImage *hiImage = setupButtonStates ? [normalImage imageByApplyingAlpha:kkJRFilterButtonHiAlpha] : nil;
	UIImage *disImage = setupButtonStates ?  [normalImage imageByApplyingAlpha:kkJRFilterButtonDisAlpha] : nil;
	[self setImage:hiImage forState:UIControlStateHighlighted];
    [self setImage:disImage forState:UIControlStateDisabled];
    
    UIImage *selectedImage = [self imageForState:UIControlStateSelected];
	UIImage *hiSelectedImage = setupButtonStates ? [selectedImage imageByApplyingAlpha:kkJRFilterButtonHiAlpha] : nil;
    [self setImage:hiSelectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
    
    [self setAdjustsImageWhenDisabled:NO];
    [self setAdjustsImageWhenHighlighted:NO];
}

@end
