//
//  JRNavigationController.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 14/01/14.
//
//

#import <UIKit/UIKit.h>

#define kJRNavigationControllerDefaultTextSize 20

@interface JRNavigationController : UINavigationController

@property (nonatomic) BOOL allowedIphoneAutorotate;

- (void)removeAllViewControllersExceptCurrent;
- (void)removeAllBordersFromNavigationBar;

@end
