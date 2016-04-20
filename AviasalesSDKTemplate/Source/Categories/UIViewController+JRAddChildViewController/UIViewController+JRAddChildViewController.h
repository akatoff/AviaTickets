//
//  UIViewController+JRAddChildViewController.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JRAddChildViewController)

- (void)addChildViewController:(UIViewController *)childController toView:(UIView *)view;
- (void)deleteChildViewController:(UIViewController *)viewController;

@end
