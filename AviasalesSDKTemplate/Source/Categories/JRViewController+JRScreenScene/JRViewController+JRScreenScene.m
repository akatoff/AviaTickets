//
//  JRViewController+JRScreenScene.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 15/01/14.
//
//

#import "JRViewController+JRScreenScene.h"
#import "UIViewController+JRScreenSceneController.h"
#import "JRScreenScene.h"

@implementation JRViewController (JRScreenScene)

- (JRScreenScene *)scene
{
    BOOL assert = ![self isKindOfClass:[JRScreenSceneController class]];
    NSAssert(assert, @"Should be used from View Controllers, but not from JRScreenSceneController.");

	JRScreenSceneController *screenSceneController = [self sceneViewController];
	JRScreenScene *scene = [screenSceneController findScreenSceneByViewController:self];
	return scene;
}

- (void)setAccessoryExclusiveFocus:(BOOL)accessoryExclusiveFocus
{
	JRScreenScene *scene = [self scene];
	[scene setAccessoryExclusiveFocus:accessoryExclusiveFocus];
}

- (void)setDimWhenUnfocused:(BOOL)dimWhenUnfocused
{
    JRScreenScene *scene = [self scene];
	[scene setDimWhenUnfocused:dimWhenUnfocused];
}

- (void)attachAccessoryViewController:(UIViewController *)viewController
                                width:(CGFloat)width
                       exclusiveFocus:(BOOL)exclusiveFocus
                             animated:(BOOL)animated
{
    JRScreenScene *scene = [self scene];
	[scene attachAccessoryViewController:viewController
	 width:width
	 exclusiveFocus:exclusiveFocus
	 animated:animated];
}

- (void)detachAccessoryViewControllerAnimated:(BOOL)animated {
    JRScreenScene *scene = [self scene];
    [scene detachAccessoryViewControllerAnimated:animated];
}

- (BOOL)shouldDetachFromMainViewController
{
    return YES;
}

- (void)accessoryWillDetach {
    [self.view endEditing:YES];
}

@end
