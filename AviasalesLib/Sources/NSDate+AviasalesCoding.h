//
//  NSDate+AviasalesCoding.h
//  Pods
//
//  Created by Denis Chaschin on 30.03.16.
//
//

#import <Foundation/Foundation.h>

@interface NSDate(AviasalesCoding)
- (NSString *)aviasales_fastDayMonthString; //TODO: add tests
+ (NSDate *)aviasales_fastDateWithDayMonthString:(NSString *)string; //TODO: add tests
@end
