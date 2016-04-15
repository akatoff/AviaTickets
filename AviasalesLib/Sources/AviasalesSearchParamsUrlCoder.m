//
//  AviasalesSearchParamsCoder.m
//  Pods
//
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import "AviasalesSearchParamsUrlCoder.h"
#import "NSDate+AviasalesCoding.h"
#import "AviasalesSearchParams.h"
#import "NSDate+AviasalesCoding.h"

@implementation AviasalesSearchParamsUrlCoder

#pragma mark - <AviasalesSearchParamsCoder>

- (nullable AviasalesSearchParams *)searchParamsWithString:(NSString *)encodedSearchParams {
    AviasalesSearchParams *result = nil;

    NSMutableArray<NSString *> *travelSegments = [[encodedSearchParams componentsSeparatedByString:@"-"] mutableCopy];

    NSString *const lastTravelSegmentPart = travelSegments.lastObject;

    NSRegularExpression *const lastTravelSegmentRegexp = [[NSRegularExpression alloc] initWithPattern:@"(.*?)(\\d)(\\d)?(\\d?)([CY])$" options:NSRegularExpressionCaseInsensitive error:nil];


    NSArray<NSTextCheckingResult *> *const matches = [lastTravelSegmentRegexp matchesInString:lastTravelSegmentPart options:0 range:NSMakeRange(0, lastTravelSegmentPart.length)];

    BOOL isMatching = matches.count > 0;

    if (isMatching) {
        NSTextCheckingResult *const match = matches[0];
        isMatching = match.resultType == NSTextCheckingTypeRegularExpression;
        if (isMatching) {
            result = [[AviasalesSearchParams alloc] init];

            NSString *const lastTravelSegmentValue = [lastTravelSegmentPart substringWithRange:[match rangeAtIndex:1]];
            travelSegments[travelSegments.count - 1] = lastTravelSegmentValue;

            const NSRange adiltsPartRange = [match rangeAtIndex:2];
            const NSRange childrenPartRange = [match rangeAtIndex:3];
            const NSRange infantsPartRange = [match rangeAtIndex:4];
            const NSRange travelSegmentPartRange = [match rangeAtIndex:5];

            result.adultsNumber = [[lastTravelSegmentPart substringWithRange:adiltsPartRange] integerValue];
            result.childrenNumber = childrenPartRange.location != NSNotFound ? [[lastTravelSegmentPart substringWithRange:childrenPartRange] integerValue] : 0;
            result.infantsNumber = infantsPartRange.location != NSNotFound ? [[lastTravelSegmentPart substringWithRange:infantsPartRange] integerValue] : 0;
            result.travelClass = [[self class] decodeTravelClass:[lastTravelSegmentPart substringWithRange:travelSegmentPartRange]];

            [self decodeTravelSegments:travelSegments toSearchParameters:result];
            return result;
        }
    }
    return result;
}

- (nullable NSString *)encodeSearchParams:(AviasalesSearchParams *)searchParams {
    NSMutableArray *const travelSemgents = [NSMutableArray arrayWithCapacity:3];
    NSString *const directTravelSegment = [[self class] encodeTravelSegmentFrom:searchParams.originIATA
                                                                            to:searchParams.destinationIATA
                                                                          date:searchParams.departureDate];
    [travelSemgents addObject:directTravelSegment];

    if (searchParams.returnFlight) {
        NSString *const returnTravelSegment = [[self class] encodeTravelSegmentFrom:searchParams.destinationIATA
                                                                                 to:searchParams.originIATA
                                                                               date:searchParams.returnDate];
        [travelSemgents addObject:returnTravelSegment];
    }

    NSMutableString *const result = [[travelSemgents componentsJoinedByString:@"-"] mutableCopy];

    NSString *const passengerInfo = [[self class] encodePassengerInfo:searchParams];
    [result appendString:passengerInfo];

    NSString *const travelClassInfo = [[self class] encodeTravelClass:searchParams.travelClass];
    [result appendString:travelClassInfo];

    return result;
}

#pragma mark - Private

- (void)decodeTravelSegments:(NSArray<NSString *> *)travelSegments toSearchParameters:(AviasalesSearchParams *)searchParameters {
    NSParameterAssert(travelSegments.count < 3);
    NSParameterAssert(searchParameters != nil);

    if (travelSegments.count == 2) {
        searchParameters.returnFlight = YES;
    }

    //First travel segment

    searchParameters.originIATA = [travelSegments.firstObject substringToIndex:3];
    searchParameters.destinationIATA = [travelSegments.firstObject substringFromIndex:7];
    const NSRange dateRange = NSMakeRange(3, 4);
    searchParameters.departureDate = [NSDate aviasales_dateWithDayMonthString:[travelSegments.firstObject substringWithRange:dateRange]];
    searchParameters.returnDate = [NSDate aviasales_dateWithDayMonthString:[travelSegments.lastObject substringWithRange:dateRange]];
}

+ (NSString *)encodeTravelSegmentFrom:(NSString *)originIATA to:(NSString *)destinationIATA date:(NSDate *)date {
    NSParameterAssert(originIATA.length == 3);
    NSParameterAssert(destinationIATA.length == 3);
    NSParameterAssert(date != nil);

    NSString *const dateRepresentation = [date aviasales_fastDayMonthString];
    return [NSString stringWithFormat:@"%@%@%@", originIATA, dateRepresentation, destinationIATA];
}

+ (NSString *)encodePassengerInfo:(AviasalesSearchParams *)searchParams {
    NSMutableString *const result = [[NSMutableString alloc] initWithCapacity:3];

    [result appendFormat:@"%ld", (long)searchParams.adultsNumber];

    if (searchParams.childrenNumber > 0 || searchParams.infantsNumber > 0) {
        [result appendFormat:@"%ld", (long)searchParams.childrenNumber];
        [result appendFormat:@"%ld", (long)searchParams.infantsNumber];
    }
    return [result copy];
}

+ (NSString *)encodeTravelClass:(NSInteger)travelClass {
    NSParameterAssert(travelClass < 2); //according to documentation
    //TODO: add enum to travel classes

    switch (travelClass) {
        case 1: //Business
            return @"C";
        default: //Economy
            return @"Y";
    }
}

+ (NSInteger)decodeTravelClass:(NSString *)encodedTravelClass {
    NSParameterAssert(encodedTravelClass.length == 1);
    if ([encodedTravelClass isEqualToString:@"C"]) {
        return 1; //Business
    } else {
        return 0; // Economy
    }

}
@end
