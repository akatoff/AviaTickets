//
//  ASTSearchParams.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 22.10.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AviasalesAirport;

@interface ASTSearchParams : NSObject <NSCoding>

+ (ASTSearchParams *)sharedInstance;

- (void)save;

- (NSString *)getPassengersInfoString;

@property (nonatomic, strong) AviasalesAirport* origin;
@property (nonatomic, strong) AviasalesAirport* destination;
@property (nonatomic, strong) NSString* originIATA;
@property (nonatomic, strong) NSString* destinationIATA;
@property (nonatomic, strong) NSDate* departureDate;
@property (nonatomic, strong) NSDate* returnDate;
@property (nonatomic, strong) NSNumber* adultsNumber;
@property (nonatomic, strong) NSNumber* childrenNumber;
@property (nonatomic, strong) NSNumber* infantsNumber;
@property (nonatomic, strong) NSNumber* travelClass;

@end
