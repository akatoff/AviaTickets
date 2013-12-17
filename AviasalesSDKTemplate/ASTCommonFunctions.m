//
//  ASTCommonFunctions.m
//  AviasalesSDKTemplate
//

#import "ASTCommonFunctions.h"

@implementation ASTCommonFunctions

+ (NSString *)formatPrice:(NSNumber *)price {
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGroupingSeparator:@" "];
        [formatter setGroupingSize:3];
        [formatter setRoundingIncrement:[NSNumber numberWithDouble:1]];
    });
    
    return [formatter stringFromNumber:price];
}

+ (NSString *)choosePluralForNumber:(NSInteger)num from:(NSString *)one andFrom:(NSString *)two andFrom:(NSString *)five {
    if (num % 10 == 1 && num % 100 != 11) {
        return one;
    }
    
    if ((num % 10 >= 2 && num % 10 <= 4) && (num % 100 < 10 || num % 100 >= 20)) {
        return two;
    }
    return five;
}

@end
