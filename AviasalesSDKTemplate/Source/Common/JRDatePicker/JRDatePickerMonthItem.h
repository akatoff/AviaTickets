//
//  JRDatePickerMonthItem.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
