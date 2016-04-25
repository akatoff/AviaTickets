//
//  JRTicket.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRFlightSegment.h"
#import "JRPrice.h"
#import "JRAirline.h"

@interface JRTicket : NSObject <JRSDKTicket>

@property (nonatomic, retain) NSSet <JRFlightSegment *> *unorderedFlightSegments;
@property (nonatomic, retain) NSSet <JRPrice *> *unorderedPrices;
@property (nonatomic, retain) JRAirline *mainAirline;

@end