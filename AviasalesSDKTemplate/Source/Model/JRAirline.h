//
//  JRAirline.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRAlliance.h"


@interface JRAirline : NSObject <JRSDKAirline>

@property (nonatomic, retain) JRAlliance *alliance;

@end