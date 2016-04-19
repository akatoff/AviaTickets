//
//  UIView+FadeAnimation.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 09/01/14.
//
//

#import "UIView+FadeAnimation.h"

@implementation UIView (FadeAnimation)

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
