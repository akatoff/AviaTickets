#import <Foundation/Foundation.h>
#import "ASTTravelSegment.h"
#import "ASTTicket.h"

@interface ASTSearchInfo : NSObject <JRSDKSearchInfo>

@property (nonatomic, retain) NSSet <ASTTravelSegment *> *unorderedTravelSegments;
@property (nonatomic, retain) NSSet <ASTTicket *> *searchTickets;
@property (nonatomic, retain) NSSet <ASTTicket *> *strictSearchTickets;

@end