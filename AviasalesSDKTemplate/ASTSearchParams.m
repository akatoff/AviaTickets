//
//  ASTSearchParams.m
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 22.10.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import "ASTSearchParams.h"
#import "ASTCommonFunctions.h"

@implementation ASTSearchParams

+ (ASTSearchParams *)sharedInstance {
    static ASTSearchParams *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *paramsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"AVIASALES_SEARCH_PARAMS"];
        
        if (paramsData) {
            instance = [NSKeyedUnarchiver unarchiveObjectWithData:paramsData];
        } else {
            instance = [[ASTSearchParams alloc] init];
            
            instance.adultsNumber = @(1);
            instance.childrenNumber = @(0);
            instance.infantsNumber = @(0);
            
            instance.travelClass = @(0);
        }
    });
    return instance;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _adultsNumber = [coder decodeObjectForKey:@"adultsNumber"];
        _childrenNumber = [coder decodeObjectForKey:@"childrenNumber"];
        _infantsNumber = [coder decodeObjectForKey:@"infantsNumber"];
        _departureDate = [coder decodeObjectForKey:@"departureDate"];
        _returnDate = [coder decodeObjectForKey:@"returnDate"];
        _originIATA = [coder decodeObjectForKey:@"originIATA"];
        _destinationIATA = [coder decodeObjectForKey:@"destinationIATA"];
        _travelClass = [coder decodeObjectForKey:@"travelClass"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_adultsNumber forKey:@"adultsNumber"];
    [coder encodeObject:_childrenNumber forKey:@"childrenNumber"];
    [coder encodeObject:_infantsNumber forKey:@"infantsNumber"];
    [coder encodeObject:_departureDate forKey:@"departureDate"];
    [coder encodeObject:_returnDate forKey:@"returnDate"];
    [coder encodeObject:_originIATA forKey:@"originIATA"];
    [coder encodeObject:_destinationIATA forKey:@"destinationIATA"];
    [coder encodeObject:_travelClass forKey:@"travelClass"];
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:@"AVIASALES_SEARCH_PARAMS"];
    
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getPassengersInfoString {
    int passengers = [_adultsNumber intValue] + [_childrenNumber intValue]  + [_infantsNumber intValue];
    NSString *travelClass = ([_travelClass integerValue] == 0) ? AVIASALES_(@"AVIASALES_TRAVEL_CLASS_0") : AVIASALES_(@"AVIASALES_TRAVEL_CLASS_1");
    return [NSString localizedStringWithFormat:AVIASALES_(@"AVIASALES_PASSENGERS"), passengers, travelClass];
}

@end
