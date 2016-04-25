//
//  UIViewController+JRScreenSceneController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
