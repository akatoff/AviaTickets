//
//  UIApplication+TopMostViewController.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface UIWindow (TopMostViewController)

- (UIViewController *)topMostController;
- (BOOL)topMostControllerIsModal;

@end
