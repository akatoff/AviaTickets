//
//  JRFlight.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRAirline.h"
#import "JRAirport.h"


@interface JRFlight : NSObject <JRSDKFlight>

@property (nonatomic, retain) JRAirline *airline;
@property (nonatomic, retain) JRAirport *destinationAirport;
@property (nonatomic, retain) JRAirport *originAirport;

@end