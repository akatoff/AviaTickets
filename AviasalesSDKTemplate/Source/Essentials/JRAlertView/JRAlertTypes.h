//
//  JRAlertTypes.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 01/10/14.
//  Copyright (c) 2014 aviasales. All rights reserved.
//

typedef NS_ENUM(NSUInteger, JRAlertType) {
    JRAlertTypeUndefined = 0,
    JRAlertTypeWithText,
};

typedef NS_ENUM(NSUInteger, JRMessagePopoverType) {
    JRMessagePopoverTypeUndefined = 0,
    
    JRMessagePopoverTypeSearchFormExceededTheAllowableNumberOfInfants,
    
    JRMessagePopoverTypeSearchFormEmptyOriginError,
    JRMessagePopoverTypeSearchFormEmptyDestinationAirportError,
    JRMessagePopoverTypeSearchFormSameCityError,
    JRMessagePopoverTypeSearchFormEmptyDepartureAirportError,
};


