//
//  JRSearchInfoUtils.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRSearchInfo.h"

@interface JRSearchInfoUtils : NSObject

+ (NSArray *)getDirectionIATAsForSearchInfo:(JRSearchInfo *)searchInfo;
+ (NSArray *)getMainIATAsForSearchInfo:(JRSearchInfo *)searchInfo;

+ (NSArray *)datesForSearchInfo:(JRSearchInfo *)searchInfo;

+ (NSString *)shortDirectionIATAStringForSearchInfo:(JRSearchInfo *)searchInfo;
+ (NSString *)fullDirectionIATAStringForSearchInfo:(JRSearchInfo *)searchInfo;
+ (NSString *)fullDirectionCityStringForSearchInfo:(JRSearchInfo *)searchInfo;

+ (NSString *)datesIntervalStringWithSearchInfo:(JRSearchInfo *)searchInfo;
+ (NSString *)passengersCountAndTravelClassStringWithSearchInfo:(JRSearchInfo *)searchInfo;
+ (NSString *)passengersCountStringWithSearchInfo:(JRSearchInfo *)searchInfo;
+ (NSString *)travelClassStringWithSearchInfo:(JRSearchInfo *)searchInfo;
+ (NSString *)travelClassStringWithTravelClass:(JRSDKTravelClass)travelClass;
@end
