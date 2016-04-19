#import "ASTTravelSegment.h"


@implementation ASTTravelSegment

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

- (ASTTravelSegment *)copy {
    ASTTravelSegment *travelSegment = [ASTTravelSegment new];
    travelSegment.departureDate = self.departureDate;
    travelSegment.destinationIata = self.destinationIata;
    travelSegment.originIata = self.originIata;
    
    return travelSegment;
}

@end