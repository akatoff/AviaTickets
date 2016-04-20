//
//  NSObject+Accessibility.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "NSObject+Accessibility.h"

@implementation NSObject (Accessibility)

+ (NSString *)findKeyForText:(NSString *)text
{
    static NSArray *keys;
    static NSMutableArray *strings;
    
    if (!keys.count) {
        NSString *stringsPath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:stringsPath];
        
        keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        strings = [NSMutableArray array];
        for (NSString *key in keys) {
            [strings addObject:dictionary[key]];
        }
    }
    
    for (NSInteger i = 0; i < strings.count; i++) {
        if ([strings[i] isEqualToString:text]) {
            return keys[i];
        }
    }
    for (NSInteger i = 0; i < strings.count; i++) {
        if ([[strings[i] uppercaseString] isEqualToString:[text uppercaseString]]) {
            return keys[i];
        }
    }
    
    return nil;
}

- (void)setAccessibilityLabelWithNSLSKey:(NSString *)key
{
    NSString *text = @"";
    if (![NSLS(key) isEqualToString:key]) {
        text = NSLS(key);
    }
    [self setAccessibilityLabelWithNSLSKey:key andText:text];
}

- (void)setAccessibilityLabelWithNSLSKey:(NSString *)key andText:(NSString *)text
{
    if (text.length) {
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = [self removeEllipsisFromString:text];
    }
}

- (NSString *)removeEllipsisFromString:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"..." withString:@""];
}

@end
