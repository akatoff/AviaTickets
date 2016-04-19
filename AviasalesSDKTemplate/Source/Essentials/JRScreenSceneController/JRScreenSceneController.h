//
//  JRScreenSceneController.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/12/13.
//
//

#import <UIKit/UIKit.h>

@protocol JRScreenSceneControllerDelegate <NSObject>

@required
- (void)screenSceneController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)screenSceneController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@class JRScreenScene;

@interface JRScreenSceneController : UIViewController

+ (CGFloat)screenSceneControllerWideViewWidth;
+ (CGFloat)screenSceneControllerWideViewPortraitWidth;
+ (CGFloat)screenSceneControllerTallViewWidth;

@property (weak, nonatomic) id<JRScreenSceneControllerDelegate> delegate;

- (NSArray *)viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

- (void)pushScreenSceneWithMainViewController:(UIViewController *)mainViewController
                                        width:(CGFloat)firstWidth
                                     animated:(BOOL)animated;

- (void)pushScreenSceneWithMainViewController:(UIViewController *)mainViewController
                                        width:(CGFloat)firstWidth
                      accessoryViewController:(UIViewController *)accessoryViewController
                                        width:(CGFloat)secondWidth
                               exclusiveFocus:(BOOL)exclusiveFocus
                                     animated:(BOOL)animated;

- (void)pushScreenSceneWithMainViewController:(UIViewController *)mainViewController
                                        portraitWidth:(CGFloat)firstPortraitWidth
                                        landscapeWidth:(CGFloat)firstLandscapeWidth
                      accessoryViewController:(UIViewController *)accessoryViewController
                                portraitWidth:(CGFloat)secondPortraitWidth
                               landscapeWidth:(CGFloat)secondLandscapeWidth
                               exclusiveFocus:(BOOL)exclusiveFocus
                                     animated:(BOOL)animated;

- (JRScreenScene *)findScreenSceneByViewController:(UIViewController *)viewController;

- (void)bringFocusToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)popViewControllerAnimated:(BOOL)animated;

- (void)popToRootViewControllerAnimated:(BOOL)animated;

+ (JRScreenScene *)screenSceneWithMainViewController:(UIViewController *)mainViewController
                                               width:(CGFloat)firstWidth
                             accessoryViewController:(UIViewController *)accessoryViewController
                                               width:(CGFloat)secondWidth
                                      exclusiveFocus:(BOOL)exclusiveFocus;

+ (JRScreenScene *)screenSceneWithMainViewController:(UIViewController *)mainViewController
                                       portraitWidth:(CGFloat)firstPortraitWidth
                                      landscapeWidth:(CGFloat)firstLandscapeWidth
                             accessoryViewController:(UIViewController *)accessoryViewController
                                       portraitWidth:(CGFloat)secondPortraitWidth
                                      landscapeWidth:(CGFloat)secondLandscapeWidth
                                      exclusiveFocus:(BOOL)exclusiveFocus;

@end
