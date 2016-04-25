//
//  UIApplication+TopMostViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
