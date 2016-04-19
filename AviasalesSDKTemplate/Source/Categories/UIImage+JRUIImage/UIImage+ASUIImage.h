//
//  UIImage+ASUIImage.h
//
//  Created by Matt Gemmell on 04/07/2010.
//  Copyright 2010 Instinctive Code.
//

#import <UIKit/UIKit.h>

@interface UIImage (ASUIImage)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
@end