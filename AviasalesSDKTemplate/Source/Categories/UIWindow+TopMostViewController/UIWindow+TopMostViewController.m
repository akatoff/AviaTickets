//
//  UIApplication+TopMostViewController.m
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 10/07/14.
//
//

#import "UIWindow+TopMostViewController.h"

@implementation UIWindow (TopMostViewController)

- (UIViewController*)topMostController
{
    UIViewController *topController = [self rootViewController];
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (BOOL)topMostControllerIsModal
{
    if ([self topMostController].presentingViewController != nil) {
        return YES;
    }
    return NO;
}

@end
