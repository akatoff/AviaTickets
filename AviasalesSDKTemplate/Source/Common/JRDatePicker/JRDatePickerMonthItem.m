//
//  JRDatePickerMonthItem.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRDatePickerMonthItem.h"
#import "DateUtil.h"

@interface JRDatePickerMonthItem ()
@end

@implementation JRDatePickerMonthItem

+ (id)monthItemWithFirstDateOfMonth:(NSDate *)firstDayOfMonth stateObject:(JRDatePickerStateObject *)stateObject
{
	return [[JRDatePickerMonthItem alloc] initWithFirstDateOfMonth:firstDayOfMonth stateObject:stateObject];
}

- (id)initWithFirstDateOfMonth:(NSDate *)firstDayOfMonth stateObject:(JRDatePickerStateObject *)stateObject
{
	self = [super init];
	if (self) {
		_stateObject = stateObject;
		_firstDayOfMonth = firstDayOfMonth;
		[self prepareDatesForCurrrentMonth];
	}
	return self;
}

- (NSMutableArray *)getPreviousDates:(NSDate *)firstDate firstWeekday:(NSInteger)firstWeekday
{
	NSMutableArray *prevDates = [[NSMutableArray alloc] init];
    
	for (NSInteger i = firstWeekday; i > [[DateUtil gregorianCalendar] firstWeekday]; i--) {
		NSDate *prevDate = prevDates.count ?[prevDates firstObject] : firstDate;
		NSDate *newDate = [DateUtil prevDayForDate:prevDate];
		[prevDates insertObject:newDate atIndex:0];
	}
	return prevDates;
}

- (NSMutableArray *)getDatesInThisMonth
{
	NSMutableArray *datesThisMonth = [[NSMutableArray alloc] init];
    
	NSRange rangeOfDaysThisMonth = [[DateUtil gregorianCalendar]
	                                rangeOfUnit:NSCalendarUnitDay
	                                inUnit:NSCalendarUnitMonth
	                                forDate:_firstDayOfMonth];
    
	unsigned unitFlags = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra);
	NSDateComponents *components = [[DateUtil gregorianCalendar] components:unitFlags fromDate:_firstDayOfMonth];
    
	for (NSInteger i = rangeOfDaysThisMonth.location; i < NSMaxRange(rangeOfDaysThisMonth); ++i) {
		[components setDay:i];
		NSDate *dayInMonth = [[DateUtil gregorianCalendar] dateFromComponents:components];
		[datesThisMonth addObject:dayInMonth];
	}
	return datesThisMonth;
}

- (NSMutableArray *)getFutureDatesForLastWeek:(NSArray *)lastWeek
{
	NSMutableArray *futureDates = [[NSMutableArray alloc] init];
	for (NSInteger i = lastWeek.count; i < 7; i++) {
		NSDate *newDate = futureDates.count ?
        [DateUtil nextDayForDate:[futureDates lastObject]] :[DateUtil nextMonthForDate:_firstDayOfMonth];
		[futureDates addObject:newDate];
	}
    
	return futureDates;
}

- (NSMutableDictionary *)getWeeksForDatesInFinalArray:(NSMutableArray *)finalArray
{
	NSMutableDictionary *weeks = [NSMutableDictionary new];
	NSNumber *weekCount = @0;
	for (NSDate *day in finalArray) {
		NSMutableArray *week = weeks[[weekCount stringValue]];
		if (![weekCount integerValue]) {
            
            static NSDateFormatter *formatter;
            if (formatter == nil) {
                formatter = [NSDateFormatter applicationUIDateFormatter];
            }
            
			[formatter setDateFormat:@"EE"];
			[_weekdays addObject:[[formatter stringFromDate:day] capitalizedString]];
		}
		if (!week) {
			week = [[NSMutableArray alloc] init];
			weeks[[weekCount stringValue]] = week;
		}
		[week addObject:day];
        
		if (week.count == 7) {
			weekCount = @([weekCount integerValue] + 1);
		}
	}
    
	NSMutableArray *lastWeek = weeks[[weekCount stringValue]];
    
	if (lastWeek.count != 7) {
		_futureDates = [self getFutureDatesForLastWeek:lastWeek];
		[lastWeek addObjectsFromArray:_futureDates];
	}
    
	return weeks;
}

- (void)setupDatePickerItemWithWeeksDictionary:(NSMutableDictionary *)weeksDictionary
{
	_weeks = [NSMutableArray new];
    
	NSArray *weekKeys = [[weeksDictionary allKeys] sortedArrayUsingComparator: ^NSComparisonResult (NSString *a, NSString *b) {
        return [a caseInsensitiveCompare:b];
    }];
	for (NSString *key in weekKeys) {
		[_weeks addObject:weeksDictionary[key]];
	}
    
	NSDate *today = [DateUtil systemTimeZoneResetTimeForDate:[NSDate date]];
    
	for (NSArray *week in _weeks) {
		for (NSDate *date in week) {
			if (![_prevDates containsObject:date] && ![_futureDates containsObject:date]) {
				if (!_stateObject.today && [date compare:today] == NSOrderedSame) {
					_stateObject.today = date;
				}
				[self markFirstOrSecondSelectedDateIfNeeds:date];
				(_stateObject.weeksStrings)[date] = [DateUtil dayNumberFromDate:date];
				NSComparisonResult borderCompare = [_stateObject.borderDate compare:date];
				if (borderCompare == NSOrderedSame) {
					_stateObject.borderDate = date;
				}
				BOOL disabledDate = borderCompare != NSOrderedDescending;
				if (disabledDate) {
					[_stateObject.disabledDates addObject:date];
				}
			}
		}
	}
}

- (void)prepareDatesForCurrrentMonth
{
	NSMutableArray *datesInThisMonth = [self getDatesInThisMonth];
    
	NSDate *firstDate = [datesInThisMonth firstObject];
	NSInteger firstWeekday = [[[DateUtil gregorianCalendar] components:NSCalendarUnitWeekday fromDate:firstDate] weekday];
    
	if (firstWeekday < [[DateUtil gregorianCalendar] firstWeekday]) {
		firstWeekday = 8;
	}
    
	_prevDates = [self getPreviousDates:firstDate firstWeekday:firstWeekday];
	NSMutableArray *finalArray = [[NSMutableArray alloc] initWithArray:_prevDates];
	[finalArray addObjectsFromArray:datesInThisMonth];
    
    
	_weekdays = [[NSMutableArray alloc] init];
    
	NSMutableDictionary *weeksDictionary = [self getWeeksForDatesInFinalArray:finalArray];
    
	[self setupDatePickerItemWithWeeksDictionary:weeksDictionary];
}

- (void)markFirstOrSecondSelectedDateIfNeeds:(NSDate *)date
{
	if (_stateObject.mode == JRDatePickerModeDefault) {
		JRTravelSegment *travelSegment = _stateObject.travelSegment;
		[self selectedCheckWithTravelSegment:travelSegment date:date];
	}
	else {
		for (JRTravelSegment *travelSegment in _stateObject.searchInfo.travelSegments) {
			if ([_stateObject.searchInfo.travelSegments indexOfObject:travelSegment] > 1) {
				return;
			}
			[self selectedCheckWithTravelSegment:travelSegment date:date];
		}
	}
}

- (void)selectedCheckWithTravelSegment:(JRTravelSegment *)travelSegment date:(NSDate *)date
{
	NSDate *departureDate = travelSegment.departureDate;
	if (departureDate) {
		NSComparisonResult selectedCompare = [[DateUtil resetTimeForDate:departureDate] compare:date];
		if (selectedCompare == NSOrderedSame) {
			if (travelSegment == _stateObject.searchInfo.travelSegments.firstObject ||
			    _stateObject.mode == JRDatePickerModeDefault) {
				_stateObject.firstSelectedDate = date;
			}
			else {
				_stateObject.secondSelectedDate = date;
			}
		}
	}
}

@end
