//
//  JRTravelSegment.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>


@interface JRTravelSegment : NSObject <JRSDKTravelSegment>

- (BOOL)isValidSegment;

#pragma mark - Copying

- (JRTravelSegment *)copy;

@end