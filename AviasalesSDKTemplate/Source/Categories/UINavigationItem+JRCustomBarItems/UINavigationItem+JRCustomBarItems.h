//
//  UINavigationItem+JRCustomBarItems.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

#define kJRCustomBarItemsNegativeSeperatorWidth 10

@interface UINavigationItem (JRCustomBarItems)

+ (UIBarButtonItem *)barItemWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName buttonClass:(Class)buttonClass target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barItemWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
