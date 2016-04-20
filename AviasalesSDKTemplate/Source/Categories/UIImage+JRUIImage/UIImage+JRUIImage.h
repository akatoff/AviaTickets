//
//  UIImage+JRUIImage.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface UIImage (JRUIImage)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
@end