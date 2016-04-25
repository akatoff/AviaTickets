//
//  JRFlightSegment.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRAirline.h"
#import "JRFlight.h"


@interface JRFlightSegment : NSObject <JRSDKFlightSegment>

@property (nonatomic, retain) JRAirline *segmentAirline;
@property (nonatomic, retain) NSSet <JRFlight *> *unorderedFlights;

@end