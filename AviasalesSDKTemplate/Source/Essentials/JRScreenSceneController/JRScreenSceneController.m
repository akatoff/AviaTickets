//
//  JRScreenSceneController.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/12/13.
//
//

#import "JRScreenSceneController.h"
#import "UIViewController+AddChildViewController.h"
#import "JRNavigationController.h"
#import "JRSlideTransitionAnimation.h"
#import "JRScreenScene.h"

@interface JRScreenSceneController () <UINavigationControllerDelegate>
@property (strong, nonatomic) JRNavigationController *navigationController;
@property (strong, nonatomic) JRSlideTransitionAnimation *animation;
@end

@implementation JRScreenSceneController

+ (CGFloat)screenSceneControllerWideViewWidth {
    return 535.0f;
}

+ (CGFloat)screenSceneControllerWideViewPortraitWidth {
    return 390.0f;
}

+ (CGFloat)screenSceneControllerTallViewWidth {
    return 320;
}

- (id)init
{
	self = [super init];
	if (self) {
		_animation = [[JRSlideTransitionAnimation alloc] init];
		_navigationController = [[JRNavigationController alloc] init];
		[_navigationController setDelegate:self];
		[_navigationController setNavigationBarHidden:YES];
		[self addChildViewController:_navigationController toView:self.view];
	}
	return self;
}

- (UIViewController *)topViewController
{
	return [self topScreenScene];
}

- (JRScreenScene *)topScreenScene
{
	return (JRScreenScene *)_navigationController.topViewController;
}

- (NSArray *)viewControllers
{
	return [_navigationController viewControllers];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
	[_navigationController setViewControllers:viewControllers animated:animated];
}

- (void)pushScreenSceneWithMainViewController:(UIViewController *)mainViewController
                                        width:(CGFloat)firstWidth
                                     animated:(BOOL)animated
{
	[self pushScreenSceneWithMainViewController:mainViewController width:firstWidth
                        accessoryViewController:nil
                                          width:kNilOptions
                                 exclusiveFocus:kNilOptions
                                       animated:animated];
}

- (void)pushScreenSceneWithMainViewController:(UIViewController *)mainViewController
                                        width:(CGFloat)firstWidth
                      accessoryViewController:(UIViewController *)accessoryViewController
                                        width:(CGFloat)secondWidth
                               exclusiveFocus:(BOOL)exclusiveFocus
                                     animated:(BOOL)animated
{
	[self pushScreenSceneWithMainViewController:mainViewController portraitWidth:kNilOptions landscapeWidth:firstWidth accessoryViewController:accessoryViewController portraitWidth:kNilOptions landscapeWidth:secondWidth exclusiveFocus:exclusiveFocus animated:animated];
}


- (void)pushScreenSceneWithMainViewController:(UIViewController *)mainViewController
                                portraitWidth:(CGFloat)firstPortraitWidth
                               landscapeWidth:(CGFloat)firstLandscapeWidth
                      accessoryViewController:(UIViewController *)accessoryViewController
                                portraitWidth:(CGFloat)secondPortraitWidth
                               landscapeWidth:(CGFloat)secondLandscapeWidth
                               exclusiveFocus:(BOOL)exclusiveFocus
                                     animated:(BOOL)animated {
    JRScreenScene *scene = [JRScreenSceneController screenSceneWithMainViewController:mainViewController portraitWidth:firstPortraitWidth landscapeWidth:firstLandscapeWidth accessoryViewController:accessoryViewController portraitWidth:secondPortraitWidth landscapeWidth:secondLandscapeWidth exclusiveFocus:exclusiveFocus];
	[self pushScreenScene:scene animated:animated];
}

+ (JRScreenScene *)screenSceneWithMainViewController:(UIViewController *)mainViewController
                                               width:(CGFloat)firstWidth
                             accessoryViewController:(UIViewController *)accessoryViewController
                                               width:(CGFloat)secondWidth
                                      exclusiveFocus:(BOOL)exclusiveFocus {
    return [self screenSceneWithMainViewController:mainViewController portraitWidth:kNilOptions landscapeWidth:firstWidth accessoryViewController:accessoryViewController portraitWidth:kNilOptions landscapeWidth:secondWidth exclusiveFocus:exclusiveFocus];
}

+ (JRScreenScene *)screenSceneWithMainViewController:(UIViewController *)mainViewController
                                       portraitWidth:(CGFloat)firstPortraitWidth
                                      landscapeWidth:(CGFloat)firstLandscapeWidth
                             accessoryViewController:(UIViewController *)accessoryViewController
                                       portraitWidth:(CGFloat)secondPortraitWidth
                                      landscapeWidth:(CGFloat)secondLandscapeWidth
                                      exclusiveFocus:(BOOL)exclusiveFocus
{
	JRScreenScene *scene = [[JRScreenScene alloc] initWithViewController:mainViewController portraitWidth:firstPortraitWidth landscapeWidth:firstLandscapeWidth];
	if (accessoryViewController) {
		[scene attachAccessoryViewController:accessoryViewController portraitWidth:secondPortraitWidth landscapeWidth:secondLandscapeWidth exclusiveFocus:exclusiveFocus animated:NO];
	}
	return scene;
}


- (void)bringFocusToViewController:(UIViewController *)toViewController animated:(BOOL)animated
{
	JRScreenScene *scene = [self findScreenSceneByViewController:toViewController];
	[scene bringFocusToViewController:toViewController animated:animated];
}

- (JRScreenScene *)findScreenSceneByViewController:(UIViewController *)viewController
{
	for (JRScreenScene *scene in [[self viewControllers] copy]) {
		for (UIViewController *child in scene.childViewControllers) {
			if (child == viewController) {
				return scene;
			}
		}
	}
	return nil;
}

- (void)popViewControllerAnimated:(BOOL)animated
{
	[self popToRootViewController:NO animated:animated];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
	[self popToRootViewController:YES animated:animated];
}

- (void)pushScreenScene:(JRScreenScene *)screenScene animated:(BOOL)animated
{
	[_navigationController pushViewController:screenScene animated:animated];
    
}

- (void)popToRootViewController:(BOOL)toRoot animated:(BOOL)animated
{
	if (toRoot) {
		[_navigationController popToRootViewControllerAnimated:animated];
	}
	else {
		[_navigationController popViewControllerAnimated:animated];
	}
}

- (id <UIViewControllerAnimatedTransitioning> )navigationController:(UINavigationController *)navigationController
                                    animationControllerForOperation:(UINavigationControllerOperation)operation
                                                 fromViewController:(UIViewController *)fromVC
                                                   toViewController:(UIViewController *)toVC
{
	if (operation != UINavigationControllerOperationNone) {
		[_animation setType:operation];
		return _animation;
	} else {
		return nil;
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[_delegate screenSceneController:navigationController willShowViewController:viewController animated:animated];
	[viewController.view layoutIfNeeded];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[_delegate screenSceneController:navigationController didShowViewController:viewController animated:animated];
	[viewController.view layoutIfNeeded];
}


@end
