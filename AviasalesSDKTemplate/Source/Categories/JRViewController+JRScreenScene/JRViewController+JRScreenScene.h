//
//  JRViewController+JRScreenScene.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRViewController.h"
#import "JRScreenSceneController.h"

@interface JRViewController (JRScreenScene)

- (JRScreenScene *)scene;

- (void)setAccessoryExclusiveFocus:(BOOL)accessoryExclusiveFocus;
- (void)setDimWhenUnfocused:(BOOL)dimWhenUnfocused;
- (void)detachAccessoryViewControllerAnimated:(BOOL)animated;
- (void)attachAccessoryViewController:(UIViewController *)viewController
                                width:(CGFloat)secondWidth
                       exclusiveFocus:(BOOL)exclusiveFocus
                             animated:(BOOL)animated;
- (BOOL)shouldDetachFromMainViewController;
- (void)accessoryWillDetach;

@end
