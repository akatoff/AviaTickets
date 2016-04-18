#import <Foundation/Foundation.h>
#import "ASTFlightSegment.h"
#import "ASTPrice.h"
#import "ASTAirline.h"

@interface ASTTicket : NSObject <JRSDKTicket>

@property (nonatomic, retain) NSSet <ASTFlightSegment *> *unorderedFlightSegments;
@property (nonatomic, retain) NSSet <ASTPrice *> *unorderedPrices;
@property (nonatomic, retain) ASTAirline *mainAirline;

@end