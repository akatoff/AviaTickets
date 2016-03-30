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

+ (NSDate *)aviasales_dateWithDayMonthString:(NSString *)string {
    NSParameterAssert(string.length == 4);
    NSCalendar *const calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];

    NSDateComponents *const components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

    const NSInteger day = [[string substringToIndex:2] integerValue];
    const NSInteger month = [[string substringFromIndex:2] integerValue];

    if (components.month > month || (components.day > day && components.month == month)) {
        components.year ++;
    }

    components.day = day;
    components.month = month;
    return [calendar dateFromComponents:components];
}
@end
