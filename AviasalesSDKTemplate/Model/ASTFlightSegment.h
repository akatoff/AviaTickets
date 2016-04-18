#import <Foundation/Foundation.h>
#import "ASTAirline.h"
#import "ASTFlight.h"


@interface ASTFlightSegment : NSObject <JRSDKFlightSegment>

@property (nonatomic, retain) ASTAirline *segmentAirline;
@property (nonatomic, retain) NSSet <ASTFlight *> *unorderedFlights;

@end