//
//  NSDate+AviasalesCoding.m
//  Pods
//
//  Created by Denis Chaschin on 30.03.16.
//
//

#import "NSDate+AviasalesCoding.h"

@implementation NSDate(AviasalesCoding)
- (NSString *)aviasales_fastDayMonthString {
    struct tm *timeinfo;
    char buffer[80];

    const time_t rawtime = [self timeIntervalSince1970];
    timeinfo = gmtime(&rawtime);

    strftime(buffer, 80, "%d%m", timeinfo);

    NSString *const timeInfoString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];

    return timeInfoString;
}

+ (NSDate *)aviasales_fastDateWithDayMonthString:(NSString *)string {
    NSParameterAssert(string.length == 4);
    struct tm timeInfo;
    timeInfo.tm_mday = [[string substringToIndex:2] integerValue];
    timeInfo.tm_mon = [[string substringFromIndex:2] integerValue];
    const time_t rawTime = mktime(&timeInfo);
    return [self dateWithTimeIntervalSince1970:rawTime];
}
@end
