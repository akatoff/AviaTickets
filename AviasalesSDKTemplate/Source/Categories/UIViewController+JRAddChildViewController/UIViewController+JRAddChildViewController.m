//
//  UIViewController+JRAddChildViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "UIViewController+JRAddChildViewController.h"

@implementation UIViewController (JRAddChildViewController)

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
