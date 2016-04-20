//
//  NSObject+Accessibility.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface NSObject (Accessibility)

+ (NSString *)findKeyForText:(NSString *)text;

- (void)setAccessibilityLabelWithNSLSKey:(NSString *)key;
- (void)setAccessibilityLabelWithNSLSKey:(NSString *)key andText:(NSString *)text;

@end

@interface UIButton (Accessibility)

@end
