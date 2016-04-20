//
//  JRTravelSegment.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRTravelSegment.h"


@implementation JRTravelSegment

@synthesize departureDate;
@synthesize destinationIata;
@synthesize originIata;

- (BOOL)isValidSegment {
    
    if ([self.originIata isKindOfClass:[NSString class]] && self.originIata.length > 0 &&
        [self.destinationIata isKindOfClass:[NSString class]] && self.destinationIata.length > 0 &&
        [self.departureDate isKindOfClass:[NSDate class]] &&
        [self.originIata isEqualToString:self.destinationIata] == NO) {
        return YES;
    }
    return NO;
}

#pragma mark - Copying

- (JRTravelSegment *)copy {
    JRTravelSegment *travelSegment = [JRTravelSegment new];
    travelSegment.departureDate = self.departureDate;
    travelSegment.destinationIata = self.destinationIata;
    travelSegment.originIata = self.originIata;
    
    return travelSegment;
}

@end