//
//  JRViewController.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 14/01/14.
//
//

#import <UIKit/UIKit.h>
#import "UINavigationItem+CustomBarItems.h"

#define kJRViewControllerTopHeight 0.5

#define kJRBaseMenuButtonImageName @"JRBaseMenuButton"
#define kJRBaseBackButtonImageName @"JRBaseBackButton"

@interface JRViewController : UIViewController

@property (nonatomic) BOOL viewIsVisible;

- (void)addPopButtonToNavigationItem;

- (void)popAction;
- (void)popActionToRoot;

@end
