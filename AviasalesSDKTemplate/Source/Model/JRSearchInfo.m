//
//  JRSearchInfo.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchInfo.h"
#import "DateUtil.h"


@implementation JRSearchInfo

@synthesize travelClass = _travelClass;
@synthesize adults = _adults;
@synthesize children = _children;
@synthesize infants = _infants;
@synthesize travelSegments =_travelSegments;
@synthesize searchTickets = _searchTickets;
@synthesize strictSearchTickets = _strictSearchTickets;
@synthesize adjustSearchInfo = _adjustSearchInfo;

- (NSDate *)returnDateForSimpleSearch
{
    if ([self.travelSegments count] > 1) {
        return ((JRTravelSegment *)(self.travelSegments)[1]).departureDate;
    }
    return nil;
}

- (void)setReturnDateForSimpleSearch:(NSDate *)returnDateForSimpleSearch
{
    if ([self.travelSegments count] > 1) {
        ((JRTravelSegment *)(self.travelSegments)[1]).departureDate = returnDateForSimpleSearch;
    }
}

#pragma mark - SearchInfo Identity

- (BOOL)isDirectReturnFlight
{
    JRTravelSegment *firstTS = self.travelSegments.firstObject;
    JRTravelSegment *secondTS = self.travelSegments.lastObject;
    if (self.travelSegments.count == 2 &&
        [[AviasalesAirportsStorage mainIATAByIATA:firstTS.originIata] isEqualToString:[AviasalesAirportsStorage mainIATAByIATA:secondTS.destinationIata]] &&
        [[AviasalesAirportsStorage mainIATAByIATA:firstTS.destinationIata] isEqualToString:[AviasalesAirportsStorage mainIATAByIATA:secondTS.originIata]]) {
        if (firstTS.departureDate &&
            secondTS.departureDate) {
            return YES;
        } else if (!firstTS.departureDate &&
                   !secondTS.departureDate) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (BOOL)isComplexSearch
{
    JRSearchInfo *searchInfo = self;
    if (searchInfo.travelSegments.count <= 1) {
        return NO;
    } else if (searchInfo.travelSegments.count == 2) {
        
        JRTravelSegment *firstTravelSegment = searchInfo.travelSegments.firstObject;
        JRTravelSegment *secondTravelSegment = searchInfo.travelSegments.lastObject;
        
        
        if ([[AviasalesAirportsStorage mainIATAByIATA:firstTravelSegment.originIata] isEqualToString:[AviasalesAirportsStorage mainIATAByIATA:secondTravelSegment.destinationIata]] &&
            [[AviasalesAirportsStorage mainIATAByIATA:firstTravelSegment.destinationIata] isEqualToString:[AviasalesAirportsStorage mainIATAByIATA:secondTravelSegment.originIata]]) {
            return NO;
        } else if (secondTravelSegment.originIata == nil ||
                   secondTravelSegment.destinationIata == nil ||
                   secondTravelSegment.departureDate == nil) {
            return NO;
        }
        return YES;
    } else {
        return YES;
    }
    
}

- (BOOL)isComplexOpenJawSearch {
    BOOL isComplexSearch = [self isComplexSearch];
    if (isComplexSearch) {
        BOOL isOpenJawSearch = YES;
        JRTravelSegment *prevTravelSegment;
        for (JRTravelSegment *currentTravelSegment in self.travelSegments.copy) {
            if (prevTravelSegment) {
                if ([[AviasalesAirportsStorage mainIATAByIATA:prevTravelSegment.destinationIata]
                     isEqualToString:[AviasalesAirportsStorage mainIATAByIATA:currentTravelSegment.originIata]] == NO) {
                    isOpenJawSearch = NO;
                }
            }
            prevTravelSegment = currentTravelSegment;
        }
        return isOpenJawSearch;
    } else {
        return NO;
    }
}

- (BOOL)isValidSearchInfo
{
    if (self.adults < 1 || self.adults > 9 || self.children > 9 || self.infants > 9) {
        return NO;
    }
    if (self.travelClass != JRSDKTravelClassEconomy &&
               self.travelClass != JRSDKTravelClassBusiness &&
               self.travelClass != JRSDKTravelClassPremiumEconomy &&
               self.travelClass != JRSDKTravelClassFirst) {
        return NO;
    }
    for (JRTravelSegment *travelSegment in self.travelSegments) {
        if (travelSegment.isValidSegment == NO) {
            return NO;
        }
    }
    NSDate *prevDate = nil;
    for (JRTravelSegment *travelSegment in self.travelSegments) {
        if (prevDate && travelSegment.departureDate) {
            if ([travelSegment.departureDate compare:prevDate] == NSOrderedAscending) {
                return NO;
            }
        }
        
        if (travelSegment.departureDate) {
            prevDate = travelSegment.departureDate;
        }
    }
    return YES;
}

#pragma mark - Travel segments operations

- (void)cleanUp {
    
    NSDate *prevDate = nil;
    
    for (JRTravelSegment *travelSegment in self.travelSegments) {
        if ([AviasalesAirportsStorage getAirportByIATA:travelSegment.originIata] == nil) {
            [travelSegment setOriginIata:nil];
        }
        if ([AviasalesAirportsStorage getAirportByIATA:travelSegment.destinationIata] == nil) {
            [travelSegment setDestinationIata:nil];
        }
        
        if (travelSegment.departureDate) {
            
            NSDate *departureDate = [DateUtil systemTimeZoneResetTimeForDate:travelSegment.departureDate];
            NSDate *firstAvalibleForSearchDate = [DateUtil firstAvalibleForSearchDate];
            NSDate *lastAvalibleForSearchDate = [DateUtil nextYearDate:[DateUtil firstAvalibleForSearchDate]];
            NSDate *tomorrow = [DateUtil systemTimeZoneResetTimeForDate:[DateUtil nextDayForDate:[NSDate date]]];
            if ([lastAvalibleForSearchDate compare:tomorrow] == NSOrderedAscending) {
                tomorrow = lastAvalibleForSearchDate;
            }
            if (departureDate && ([departureDate compare:prevDate ? prevDate : firstAvalibleForSearchDate] == NSOrderedAscending ||
                                  [departureDate compare:lastAvalibleForSearchDate] == NSOrderedDescending )) {
                [travelSegment setDepartureDate:prevDate ? prevDate : tomorrow];
            }
            
            if (prevDate && [travelSegment.departureDate compare:prevDate] == NSOrderedAscending) {
                [travelSegment setDepartureDate:tomorrow];
            } else {
                prevDate = travelSegment.departureDate;
            }
            
        }
    }
}

- (void)clipSearchInfoForSimpleSearchIfNeeds
{
    NSDate *returnDate = [self returnDateForSimpleSearch];
    JRTravelSegment *directTravelSegment = self.travelSegments.firstObject;
    
    [self removeTravelSegmentsStartingFromTravelSegment:directTravelSegment];
    
    [self addTravelSegment:directTravelSegment];
    
    if (returnDate) {
        JRTravelSegment *returnTravelSegment = [JRTravelSegment new];
        [returnTravelSegment setOriginIata:directTravelSegment.destinationIata];
        [returnTravelSegment setDestinationIata:directTravelSegment.originIata];
        [returnTravelSegment setDepartureDate:returnDate];
        [self addTravelSegment:returnTravelSegment];
    }
}

- (void)clipSearchInfoForComplexSearchIfNeeds
{
    for (JRTravelSegment *travelSegment in self.travelSegments) {
        if (!travelSegment.originIata || !travelSegment.destinationIata || !travelSegment.departureDate) {
            [self removeTravelSegmentsStartingFromTravelSegment:travelSegment];
            break;
        }
    }
}

- (void)addTravelSegment:(JRTravelSegment *)travelSegment
{
    if ([travelSegment isKindOfClass:[JRTravelSegment class]]) {
        JRTravelSegment *prevTravelSegment = self.travelSegments.lastObject;
        NSMutableOrderedSet *travelSegments = [NSMutableOrderedSet new];
        [travelSegments addObjectsFromArray:self.travelSegments.array];
        [travelSegments addObject:travelSegment];
        [self setTravelSegments:travelSegments];
        if (self.adjustSearchInfo == YES) {
            [self travelSegment:prevTravelSegment didSetDestinationIATA:prevTravelSegment.destinationIata];
        }
    }
}

- (void)removeTravelSegment:(JRTravelSegment *)travelSegment
{
    
    JRTravelSegment *prevTravelSegment = nil;
    if (self.adjustSearchInfo == YES) {
        prevTravelSegment = [self prevTravelSegmentForTravelSegment:travelSegment];
    }
    NSMutableOrderedSet *travelSegments = [NSMutableOrderedSet new];
    [travelSegments addObjectsFromArray:self.travelSegments.array];
    [travelSegments removeObject:travelSegment];
    [self setTravelSegments:travelSegments];
    [prevTravelSegment setDestinationIata:prevTravelSegment.destinationIata];
    
}

- (void)removeTravelSegmentsStartingFromTravelSegment:(JRTravelSegment *)travelSegment
{
    if ([travelSegment isKindOfClass:[JRTravelSegment class]]) {
        
        NSOrderedSet *travelSegments = self.travelSegments;
        NSUInteger startIndex = [travelSegments indexOfObject:travelSegment];
        if (startIndex != NSNotFound) {
            NSUInteger endIndex = travelSegments.count;
            NSArray *travelSegmentsToDelete = [[NSOrderedSet orderedSetWithOrderedSet:travelSegments
                                                                                range:NSMakeRange(startIndex, endIndex - startIndex)
                                                                            copyItems:NO] array];
            for (JRTravelSegment *travelSegmentToDelete in travelSegmentsToDelete) {
                [self removeTravelSegment:travelSegmentToDelete];
            }
        }
    }
}

#pragma mark - Travel Segments Changes

-(void)travelSegment:(JRTravelSegment *)travelSegment didSetOriginIATA:(NSString *)originIATA
{
    if (self.adjustSearchInfo == NO) {
        return;
    }
    if (travelSegment && originIATA) {
        JRTravelSegment *prevTravelSegment = [self prevTravelSegmentForTravelSegment:travelSegment];
        if (prevTravelSegment.destinationIata == nil && ![prevTravelSegment.destinationIata isEqualToString:originIATA]) {
            [prevTravelSegment setDestinationIata:originIATA];
        }
    }
}

-(void)travelSegment:(JRTravelSegment *)travelSegment didSetDestinationIATA:(NSString *)destinationIATA
{
    if (self.adjustSearchInfo == NO) {
        return;
    }
    if (travelSegment && destinationIATA) {
        
        JRTravelSegment *prevTravelSegment = [self prevTravelSegmentForTravelSegment:travelSegment];
        [prevTravelSegment setDestinationIata:prevTravelSegment.destinationIata];
        
        JRTravelSegment *nextTravelSegment = [self nextTravelSegmentForTravelSegment:travelSegment];
        if (nextTravelSegment.originIata == nil &&
            ![nextTravelSegment.originIata isEqualToString:destinationIATA]) {
            [nextTravelSegment setOriginIata:destinationIATA];
        }
    }
}

-(void)travelSegment:(JRTravelSegment *)travelSegment didSetDepartureDate:(NSDate *)departureDate
{
    if (self.adjustSearchInfo == NO) {
        return;
    }
    if (travelSegment && departureDate) {
        NSUInteger travelSegmentIndex = [self.travelSegments indexOfObject:travelSegment];
        for (JRTravelSegment *segment in self.travelSegments) {
            NSUInteger segmentIndex = [self.travelSegments indexOfObject:segment];
            if (segmentIndex > travelSegmentIndex && segment.departureDate) {
                NSComparisonResult result = [departureDate compare:segment.departureDate];
                if (result == NSOrderedDescending) {
                    [segment setDepartureDate:departureDate];
                }
            }
        }
    }
}

- (JRTravelSegment *)prevTravelSegmentForTravelSegment:(JRTravelSegment *)travelSegment
{
    NSUInteger prevTravelSegmentIndex = [self.travelSegments indexOfObject:travelSegment] - 1;
    if (self.travelSegments.count > prevTravelSegmentIndex) {
        return (self.travelSegments)[prevTravelSegmentIndex];
    } else {
        return nil;
    }
}

- (JRTravelSegment *)nextTravelSegmentForTravelSegment:(JRTravelSegment *)travelSegment
{
    NSUInteger nextTravelSegmentIndex = [self.travelSegments indexOfObject:travelSegment] + 1;
    if (self.travelSegments.count > nextTravelSegmentIndex) {
        return (self.travelSegments)[nextTravelSegmentIndex];
    } else {
        return nil;
    }
}

#pragma mark - Copying

- (JRSearchInfo *)copyWithTravelSegments {
    JRSearchInfo *searchInfoWithTravelSegments = [JRSearchInfo new];
    searchInfoWithTravelSegments.travelClass = self.travelClass;
    searchInfoWithTravelSegments.adults = self.adults;
    searchInfoWithTravelSegments.children = self.children;
    searchInfoWithTravelSegments.infants = self.infants;
    
    NSMutableOrderedSet *orderedTravelSegments = [NSMutableOrderedSet new];
    for (JRTravelSegment *travelSegment in self.travelSegments) {
        [orderedTravelSegments addObject:[travelSegment copy]];
    }
    
    [searchInfoWithTravelSegments setTravelSegments:orderedTravelSegments];
    
    return searchInfoWithTravelSegments;
}

@end