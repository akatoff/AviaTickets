//
//  UIView+FadeAnimation.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 09/01/14.
//
//

#import <UIKit/UIKit.h>

#define kJRFadeAnimationFastTransitionDuration 0.2
#define kJRFadeAnimationMediumTransitionDuration 0.4
#define kJRFadeAnimationLondTransitionDuration 0.6
@interface UIView (FadeAnimation)

+ (void)addTransitionFadeToView:(UIView *)view
                       duration:(NSTimeInterval)duration;

@end
