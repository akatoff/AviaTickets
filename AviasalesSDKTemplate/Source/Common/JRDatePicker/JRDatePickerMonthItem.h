//
//  JRDatePickerMonthItem.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 05/02/14.
//
//

#import <Foundation/Foundation.h>
#import "JRDatePickerStateObject.h"

@interface JRDatePickerMonthItem : NSObject

@property (weak, nonatomic) JRDatePickerStateObject *stateObject;

@property (strong, readonly, nonatomic) NSMutableArray *prevDates;
@property (strong, readonly, nonatomic) NSMutableArray *futureDates;

@property (strong, readonly, nonatomic) NSMutableArray *weeks;
@property (strong, readonly, nonatomic) NSMutableArray *weekdays;

@property (strong, readonly, nonatomic) NSDate *firstDayOfMonth;

+ (instancetype)monthItemWithFirstDateOfMonth:(NSDate *)firstDayOfMonth stateObject:(JRDatePickerStateObject *)stateObject;
@end
