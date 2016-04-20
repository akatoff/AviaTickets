//
//  JRAlertTypes.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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


