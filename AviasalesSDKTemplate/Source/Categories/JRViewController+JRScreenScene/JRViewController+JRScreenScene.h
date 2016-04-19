//
//  JRViewController+JRScreenScene.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 15/01/14.
//
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
