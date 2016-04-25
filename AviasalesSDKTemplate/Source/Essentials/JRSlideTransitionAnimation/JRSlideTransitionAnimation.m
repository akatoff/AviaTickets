//
//  JRSlideTransitionAnimation.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSlideTransitionAnimation.h"

#define JRSlideTransitionAnimationDuration 0.65
#define JRSlideTransitionAnimationDamping  0.82

@interface JRSlideTransitionAnimation ()
@end

@implementation JRSlideTransitionAnimation

#pragma mark - Animated Transitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning> )transitionContext
{
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
	UIView *containerView = [transitionContext containerView];
	[containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
	CGRect screenFrame = fromViewController.view.frame;
	CGFloat toStartX, fromEndX;
    
	if (self.type == UINavigationControllerOperationPush) {
		toStartX = screenFrame.size.width;
		fromEndX = -screenFrame.size.width;
	} else {
		toStartX = -screenFrame.size.width;
		fromEndX = screenFrame.size.width;
	}
    
	toViewController.view.frame = CGRectOffset(screenFrame, toStartX, 0);
    
	NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    
	[UIView animateWithDuration:duration
                          delay:kNilOptions
         usingSpringWithDamping:JRSlideTransitionAnimationDamping
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         fromViewController.view.frame = CGRectOffset(screenFrame, fromEndX, 0);
                         toViewController.view.frame = screenFrame;
                     } completion: ^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> )transitionContext
{
	return JRSlideTransitionAnimationDuration;
}

@end
