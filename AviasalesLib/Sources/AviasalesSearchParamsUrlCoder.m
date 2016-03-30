//
//  AviasalesSearchParamsCoder.m
//  Pods
//
//  Created by Denis Chaschin on 30.03.16. //FIXME: headers
//
//

#import "AviasalesSearchParamsUrlCoder.h"
#import "NSDate+AviasalesCoding.h"
#import "AviasalesSearchParams.h"

@implementation AviasalesSearchParamsUrlCoder

#pragma mark - <AviasalesSearchParamsCoder>

- (nullable AviasalesSearchParams *)searchParamsWithString:(NSString *)encodedSearchParams {

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
@end
