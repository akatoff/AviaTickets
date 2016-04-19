//
//  UIViewController+AddChildViewController.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 25/12/13.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (AddChildViewController)

- (void)addChildViewController:(UIViewController *)childController toView:(UIView *)view;
- (void)deleteChildViewController:(UIViewController *)viewController;

@end
