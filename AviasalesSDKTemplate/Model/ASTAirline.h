#import <Foundation/Foundation.h>
#import "ASTAlliance.h"


@interface ASTAirline : NSObject <JRSDKAirline>

@property (nonatomic, retain) ASTAlliance *alliance;

@end