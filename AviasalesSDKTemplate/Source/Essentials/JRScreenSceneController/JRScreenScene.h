//
//  JRScreenScene.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

#define kJRInterpolatingMotionEffectMinimumRelativeValueX 20

@interface JRScreenScene : UIViewController

@property (strong, readonly, nonatomic) UIViewController *mainViewController;
@property (strong, nonatomic) UIViewController *accessoryViewController;

@property (assign, nonatomic) BOOL dimWhenUnfocused;
@property (assign, nonatomic) BOOL accessoryExclusiveFocus;

- (id)initWithViewController:(UIViewController *)viewController
               portraitWidth:(CGFloat)firstPortraitWidth
              landscapeWidth:(CGFloat)firstLandscapeWidth;

- (void)attachAccessoryViewController:(UIViewController *)viewController
                        portraitWidth:(CGFloat)secondPortraitWidth
                       landscapeWidth:(CGFloat)secondLandscapeWidth
                 exclusiveFocus:(BOOL)exclusiveFocus
                          animated:(BOOL)animated;

- (void)attachAccessoryViewController:(UIViewController *)viewController
                                width:(CGFloat)width
                       exclusiveFocus:(BOOL)exclusiveFocus
                             animated:(BOOL)animated;

- (void)detachAccessoryViewControllerAnimated:(BOOL)animated;

- (void)bringFocusToViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
