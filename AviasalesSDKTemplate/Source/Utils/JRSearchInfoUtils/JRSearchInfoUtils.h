//
//  JRSearchInfoUtils.h
//  Aviasales iOS Apps
//
//  Created by Anton Chebotov on 19/12/13.
//
//

#import <Foundation/Foundation.h>
#import "ASTSearchInfo.h"

@interface JRSearchInfoUtils : NSObject

+ (NSArray *)getDirectionIATAsForSearchInfo:(ASTSearchInfo *)searchInfo;
+ (NSArray *)getMainIATAsForSearchInfo:(ASTSearchInfo *)searchInfo;

+ (NSArray *)datesForSearchInfo:(ASTSearchInfo *)searchInfo;

+ (NSString *)shortDirectionIATAStringForSearchInfo:(ASTSearchInfo *)searchInfo;
+ (NSString *)fullDirectionIATAStringForSearchInfo:(ASTSearchInfo *)searchInfo;
+ (NSString *)fullDirectionCityStringForSearchInfo:(ASTSearchInfo *)searchInfo;

+ (NSString *)datesIntervalStringWithSearchInfo:(ASTSearchInfo *)searchInfo;
+ (NSString *)passengersCountAndTravelClassStringWithSearchInfo:(ASTSearchInfo *)searchInfo;
+ (NSString *)passengersCountStringWithSearchInfo:(ASTSearchInfo *)searchInfo;
+ (NSString *)travelClassStringWithSearchInfo:(ASTSearchInfo *)searchInfo;
+ (NSString *)travelClassStringWithTravelClass:(JRSDKTravelClass)travelClass;
@end
