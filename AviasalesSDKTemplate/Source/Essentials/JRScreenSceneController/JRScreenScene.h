//
//  JRScreenScene.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 25/12/13.
//
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
