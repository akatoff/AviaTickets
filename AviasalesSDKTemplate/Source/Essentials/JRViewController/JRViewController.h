//
//  JRViewController.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "UINavigationItem+JRCustomBarItems.h"

#define kJRViewControllerTopHeight 0.5

#define kJRBaseMenuButtonImageName @"JRBaseMenuButton"
#define kJRBaseBackButtonImageName @"JRBaseBackButton"

@interface JRViewController : UIViewController

@property (nonatomic) BOOL viewIsVisible;

- (void)addPopButtonToNavigationItem;

- (void)popAction;
- (void)popActionToRoot;

@end
