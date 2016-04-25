//
//  JRSearchInfoUtils.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchInfoUtils.h"
#import "JRSearchInfo.h"
#import "JRAirport.h"
#import "DateUtil.h"
#import "JRTravelSegment.h"

@implementation JRSearchInfoUtils

+ (NSArray *)getDirectionIATAsForSearchInfo:(JRSearchInfo *)searchInfo
{
	NSMutableArray *iatas = [NSMutableArray new];
	for (JRTravelSegment *travelSegment in searchInfo.travelSegments) {
		NSString *originIATA = travelSegment.originIata;
		if (originIATA) {
			[iatas addObject:originIATA];
		}
		NSString *destinationIATA = travelSegment.destinationIata;
		if (destinationIATA) {
			[iatas addObject:destinationIATA];
		}
	}
	if (searchInfo.isDirectReturnFlight && iatas.count > 2) {
		NSArray *directReturnIATAs = nil;
		NSRange directReturnIATAsRange = NSMakeRange(0, 2);
		directReturnIATAs = [iatas subarrayWithRange:directReturnIATAsRange];
		return directReturnIATAs;
	} else {
		return iatas;
	}
}

+ (NSArray *)getMainIATAsForSearchInfo:(JRSearchInfo *)searchInfo
{
	NSMutableArray *iatasForSearchInfo = [[self getDirectionIATAsForSearchInfo:searchInfo] mutableCopy];
	NSMutableArray *mainIATAsForSearchInfo = [NSMutableArray new];
	for (NSString *iata in iatasForSearchInfo) {
		NSString *mainIATA = [AviasalesAirportsStorage mainIATAByIATA:iata];
		if (mainIATA) {
			[mainIATAsForSearchInfo addObject:mainIATA];
		}
	}
	return mainIATAsForSearchInfo;
}

+ (NSArray *)datesForSearchInfo:(JRSearchInfo *)searchInfo
{
	NSMutableArray *dates = [NSMutableArray new];
    
	for (JRTravelSegment *travelSegment in searchInfo.travelSegments) {
		NSDate *departureDate = travelSegment.departureDate;
		if (departureDate) {
			[dates addObject:departureDate];
		}
	}
	return dates;
}


+ (NSString *)shortDirectionIATAStringForSearchInfo:(JRSearchInfo *)searchInfo
{
	NSArray *iatas = [self getDirectionIATAsForSearchInfo:searchInfo];
    
    NSString *separator = searchInfo.isComplexSearch ? @" … " : @" — ";
	return [NSString stringWithFormat:@"%@ %@ %@", iatas.firstObject, separator, iatas.lastObject];
}

+ (NSString *)fullDirectionIATAStringForSearchInfo:(JRSearchInfo *)searchInfo
{
    NSMutableString *directionString = [NSMutableString new];
    for (JRTravelSegment *travelSegment in searchInfo.travelSegments) {
        if (travelSegment != searchInfo.travelSegments.firstObject) {
            [directionString appendString:@"  "];
        }
        [directionString appendFormat:@"%@—%@", travelSegment.originIata, travelSegment.destinationIata];
    }
	return directionString;
}

+ (NSString *)fullDirectionCityStringForSearchInfo:(JRSearchInfo *)searchInfo {
    NSArray *iatas = [self getDirectionIATAsForSearchInfo:searchInfo];
    NSMutableString *directionString = [NSMutableString new];
	for (NSInteger i = 0; i < iatas.count; i++) {
		NSString *iata = iatas[i];
        id <JRSDKAirport> airport = [AviasalesAirportsStorage getAirportByIATA:iata];
        NSString *airportCity = airport.city ? airport.city : iata;
		[directionString appendString:airportCity];
		if (i != iatas.count - 1) {
			[directionString appendString:@" — "];
		}
	}
	return directionString;
}

+ (NSString *)datesIntervalStringWithSearchInfo:(JRSearchInfo *)searchInfo
{
	NSString *datesString;
    
	NSDate *firstDate = [searchInfo.travelSegments.firstObject departureDate];
	NSDate *lastDate = searchInfo.travelSegments.count > 1 ?[searchInfo.travelSegments.lastObject departureDate] : nil;
    
	if (lastDate) {
		datesString = [NSString stringWithFormat:@"%@ — %@", iPhone() ?[DateUtil dayMonthStringFromDate:firstDate] : [DateUtil dayFullMonthYearStringFromDate:firstDate], iPhone() ?[DateUtil dayMonthStringFromDate:lastDate] : [DateUtil dayFullMonthYearStringFromDate:lastDate]];
	} else {
		datesString = [NSString stringWithFormat:@"%@", iPhone() ?[DateUtil dayFullMonthStringFromDate:firstDate] : [DateUtil dayFullMonthYearStringFromDate:firstDate]];
	}
	return datesString;
}

+ (NSString *)passengersCountAndTravelClassStringWithSearchInfo:(JRSearchInfo *)searchInfo
{
    NSString *passengersCountStringWithSearchInfo = [JRSearchInfoUtils passengersCountStringWithSearchInfo:searchInfo];
    return [NSString stringWithFormat:@"%@, %@", passengersCountStringWithSearchInfo, [JRSearchInfoUtils travelClassStringWithSearchInfo:searchInfo].lowercaseString];
}

+ (NSString *)passengersCountStringWithSearchInfo:(JRSearchInfo *)searchInfo
{
	NSInteger passengers = searchInfo.adults + searchInfo.children  + searchInfo.infants;
    NSString *format = NSLSP(@"JR_SEARCHINFO_PASSENGERS", passengers);
	return [NSString stringWithFormat:format, passengers];
}

+ (NSString *)travelClassStringWithSearchInfo:(JRSearchInfo *)searchInfo
{
    return [self travelClassStringWithTravelClass:searchInfo.travelClass];
}

+ (NSString *)travelClassStringWithTravelClass:(JRSDKTravelClass)travelClass
{
    switch (travelClass) {
        case JRSDKTravelClassBusiness : {
            return NSLS(@"JR_SEARCHINFO_BUSINESS");
        } break;
        case JRSDKTravelClassPremiumEconomy : {
            return NSLS(@"JR_SEARCHINFO_PREMIUM_ECONOMY");
        } break;
        case JRSDKTravelClassFirst : {
            return NSLS(@"JR_SEARCHINFO_FIRST");
        } break;
        default : {
            return NSLS(@"JR_SEARCHINFO_ECONOMY");
        } break;
    }
}



@end
