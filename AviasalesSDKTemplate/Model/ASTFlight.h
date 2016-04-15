#import <Foundation/Foundation.h>
#import "ASTAirline.h"
#import "ASTAirport.h"


@interface ASTFlight : NSObject <JRSDKFlight>

@property (nonatomic, retain) ASTAirline *airline;
@property (nonatomic, retain) ASTAirport *destinationAirport;
@property (nonatomic, retain) ASTAirport *originAirport;

@end