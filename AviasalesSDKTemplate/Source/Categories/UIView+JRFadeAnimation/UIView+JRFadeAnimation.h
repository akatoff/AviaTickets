//
//  UIView+JRFadeAnimation.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

#define kJRFadeAnimationFastTransitionDuration 0.2
#define kJRFadeAnimationMediumTransitionDuration 0.4
#define kJRFadeAnimationLondTransitionDuration 0.6
@interface UIView (JRFadeAnimation)

+ (void)addTransitionFadeToView:(UIView *)view
                       duration:(NSTimeInterval)duration;

@end
