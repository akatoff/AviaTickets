//
//  UIViewController+AddChildViewController.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 25/12/13.
//
//

#import "UIViewController+AddChildViewController.h"

@implementation UIViewController (AddChildViewController)

- (void)addChildViewController:(UIViewController *)childController toView:(UIView *)view {
    if (!childController || !view) {
        return;
    }
    if (childController.parentViewController) {
        [self deleteChildViewController:childController];
    }
    [self addChildViewController:childController];
    [view addSubview:childController.view];
    [childController didMoveToParentViewController:self];
}

- (void)deleteChildViewController:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

@end
