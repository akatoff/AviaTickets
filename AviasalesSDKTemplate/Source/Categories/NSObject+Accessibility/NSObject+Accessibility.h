//
//  NSObject+Accessibility.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 24/09/14.
//  Copyright (c) 2014 aviasales. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (Accessibility)

+ (NSString *)findKeyForText:(NSString *)text;

- (void)setAccessibilityLabelWithNSLSKey:(NSString *)key;
- (void)setAccessibilityLabelWithNSLSKey:(NSString *)key andText:(NSString *)text;

@end

@interface UIButton (Accessibility)

@end
