//
//  UIView+JRFadeAnimation.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "UIView+JRFadeAnimation.h"

@implementation UIView (JRFadeAnimation)

+ (void)addTransitionFadeToView:(UIView *)view
                           duration:(NSTimeInterval)duration {
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDuration:duration];
    [view.layer addAnimation:animation forKey:@"kCATransitionFade"];
}
@end
