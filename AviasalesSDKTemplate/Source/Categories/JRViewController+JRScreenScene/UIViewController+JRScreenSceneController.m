//
//  UIViewController+JRScreenSceneController.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 13/02/14.
//
//

#import "UIViewController+JRScreenSceneController.h"

@implementation UIViewController (JRScreenSceneController)

- (JRScreenSceneController *)sceneViewController
{
	UIViewController *parent = self.parentViewController;
    
    if (parent && [parent isKindOfClass:[JRScreenSceneController class]]) {
        id screenSceneController = parent;
        return screenSceneController;
    } else if ([parent respondsToSelector:@selector(sceneViewController)]) {
        return parent.sceneViewController;
    } else {
        return nil;
    }
}

@end
