//
//  JRSearchInfo.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRTravelSegment.h"
#import "JRTicket.h"

@interface JRSearchInfo : NSObject <JRSDKSearchInfo>

@property (nonatomic, retain) NSOrderedSet <JRTravelSegment *> *travelSegments;
@property (nonatomic, retain) NSSet <JRTicket *> *searchTickets;
@property (nonatomic, retain) NSSet <JRTicket *> *strictSearchTickets;

@property (nonatomic, assign) BOOL adjustSearchInfo;

@property (nonatomic, strong) NSDate *returnDateForSimpleSearch;

- (BOOL)isComplexOpenJawSearch;
- (BOOL)isComplexSearch;
- (BOOL)isDirectReturnFlight;
- (BOOL)isValidSearchInfo;

- (void)cleanUp;

- (void)clipSearchInfoForComplexSearchIfNeeds;
- (void)clipSearchInfoForSimpleSearchIfNeeds;

- (void)addTravelSegment:(JRTravelSegment *)travelSegment;
- (void)removeTravelSegment:(JRTravelSegment *)travelSegment;
- (void)removeTravelSegmentsStartingFromTravelSegment:(JRTravelSegment *)travelSegment;

#pragma mark - Copying

- (JRSearchInfo *)copyWithTravelSegments;

@end