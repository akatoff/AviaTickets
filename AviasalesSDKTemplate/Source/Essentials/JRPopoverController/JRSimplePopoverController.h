//
//  JRSimplePopoverController.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface JRSimplePopoverController : UIPopoverController

- (JRSimplePopoverController*)initWithContentViewControllerWithNavigation:(UIViewController*) vc;

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated manual:(BOOL)manual;

@end
