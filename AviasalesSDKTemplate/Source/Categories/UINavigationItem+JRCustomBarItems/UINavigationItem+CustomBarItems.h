//
//  UINavigationItem+IOS7Fix.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 06/11/13.
//
//

#import <UIKit/UIKit.h>

#define kJRCustomBarItemsNegativeSeperatorWidth 10

@interface UINavigationItem (CustomBarItems)

+ (UIBarButtonItem *)barItemWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName buttonClass:(Class)buttonClass target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barItemWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
