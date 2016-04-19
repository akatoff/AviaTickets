//
//  UIApplication+TopMostViewController.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 10/07/14.
//
//

#import <UIKit/UIKit.h>

@interface UIWindow (TopMostViewController)

- (UIViewController *)topMostController;
- (BOOL)topMostControllerIsModal;

@end
