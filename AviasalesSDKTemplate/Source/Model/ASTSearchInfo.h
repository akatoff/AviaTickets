#import <Foundation/Foundation.h>
#import "ASTTravelSegment.h"
#import "ASTTicket.h"

@interface ASTSearchInfo : NSObject <JRSDKSearchInfo>

@property (nonatomic, retain) NSOrderedSet <ASTTravelSegment *> *travelSegments;
@property (nonatomic, retain) NSSet <ASTTicket *> *searchTickets;
@property (nonatomic, retain) NSSet <ASTTicket *> *strictSearchTickets;

@property (nonatomic, assign) BOOL adjustSearchInfo;

@property (nonatomic, strong) NSDate *returnDateForSimpleSearch;

- (BOOL)isComplexOpenJawSearch;
- (BOOL)isComplexSearch;
- (BOOL)isDirectReturnFlight;
- (BOOL)isValidSearchInfo;

- (void)cleanUp;

- (void)clipSearchInfoForComplexSearchIfNeeds;
- (void)clipSearchInfoForSimpleSearchIfNeeds;

- (void)addTravelSegment:(ASTTravelSegment *)travelSegment;
- (void)removeTravelSegment:(ASTTravelSegment *)travelSegment;
- (void)removeTravelSegmentsStartingFromTravelSegment:(ASTTravelSegment *)travelSegment;

#pragma mark - Copying

- (ASTSearchInfo *)copyWithTravelSegments;

@end