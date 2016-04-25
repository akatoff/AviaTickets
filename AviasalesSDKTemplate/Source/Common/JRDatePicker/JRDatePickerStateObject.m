//
//  JRDatePickerStateObject.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRDatePickerStateObject.h"
#import "JRDatePickerMonthItem.h"
#import "DateUtil.h"

@interface JRDatePickerStateObject ()

@end

@implementation JRDatePickerStateObject

- (id)initWithDelegate:(id<JRDatePickerStateObjectActionDelegate>)delegate
{
	self = [super init];
	if (self) {
        
		_delegate = delegate;
        
		_weeksStrings = [NSMutableDictionary new];
		_disabledDates = [NSMutableArray new];
		_monthItems = [NSMutableArray new];
        
        _firstAvalibleForSearchDate = [DateUtil firstAvalibleForSearchDate];
        _lastAvalibleForSearchDate = [DateUtil nextYearDate:_firstAvalibleForSearchDate];
	}
	return self;
}

- (void)updateSelectedDatesRange
{
	if (_mode != JRDatePickerModeDefault) {
		_selectedDates = [NSMutableArray new];
		if (_firstSelectedDate && _secondSelectedDate) {
			for (JRDatePickerMonthItem *item in _monthItems) {
				for (NSArray *week in item.weeks) {
					for (NSDate *date in week) {
						BOOL lessThanFirstDate = [date compare:_firstSelectedDate] == NSOrderedAscending;
						BOOL moreThanSecondDate = [date compare:_secondSelectedDate] == NSOrderedDescending;
						if (!(lessThanFirstDate || moreThanSecondDate)) {
							[_selectedDates addObject:date];
						}
					}
				}
			}
		}
	}
    
	NSDate *dateForSearch = _mode == JRDatePickerModeDeparture ? _firstSelectedDate : _secondSelectedDate;
	if (!dateForSearch) {
		dateForSearch = _mode == JRDatePickerModeDeparture ? _secondSelectedDate : _firstSelectedDate;
	}
	if (!dateForSearch) {
		dateForSearch = _borderDate;
	}
	if (dateForSearch) {
		for (JRDatePickerMonthItem *item in _monthItems) {
			for (NSArray *week in item.weeks) {
				if ([week containsObject:dateForSearch] &&
				    ![item.prevDates containsObject:dateForSearch] &&
				    ![item.futureDates containsObject:dateForSearch]) {
					_indexPathToScroll = [NSIndexPath indexPathForRow:0 inSection:[_monthItems indexOfObject:item]];
					break;
				}
			}
		}
	}
    
}

- (void)setFirstSelectedDate:(NSDate *)firstSelectedDate
{
	_firstSelectedDate = firstSelectedDate;
	if (_firstSelectedDate && _secondSelectedDate) {
		NSComparisonResult result = [_firstSelectedDate compare:_secondSelectedDate];
		if (result == NSOrderedDescending) {
			_secondSelectedDate = _firstSelectedDate;
		}
	}
}

@end
