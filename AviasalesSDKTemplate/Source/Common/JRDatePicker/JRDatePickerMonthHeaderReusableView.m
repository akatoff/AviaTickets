//
//  JRDatePickerMonthHeaderReusableView.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 05/02/14.
//
//

#import "JRDatePickerMonthHeaderReusableView.h"
#import "JRC.h"
#import "JRViewController.h"
#import "DateUtil.h"

#define WEEKDAY_LABEL_TAG_OFFSET 1000

@interface JRDatePickerMonthHeaderReusableView ()
@property (weak, nonatomic) IBOutlet UILabel *monthYearLabel;

@end

@implementation JRDatePickerMonthHeaderReusableView

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self updateView];
}

- (void)setMonthItem:(JRDatePickerMonthItem *)monthItem
{
	_monthItem = monthItem;
	[self updateView];
}

- (NSString *)getMonthYearString
{
	NSDate *date = _monthItem.firstDayOfMonth;
	NSString *monthYearString = nil;
	if (date) {
		NSString *monthName = [DateUtil monthName:date];
		NSString *year = [DateUtil dayMonthYearComponentsFromDate:date][2];
		monthYearString = [[NSString stringWithFormat:@"%@ %@", monthName, year] uppercaseString];
	}
	return monthYearString;
}

- (void)updateView
{
	NSString *monthYearString;
	monthYearString = [self getMonthYearString];
	[_monthYearLabel setText:monthYearString];
    
    
	for (NSString *weekday in _monthItem.weekdays) {
		NSUInteger labelTag = [_monthItem.weekdays indexOfObject:weekday] + WEEKDAY_LABEL_TAG_OFFSET;
		UILabel *weekdayLabel = (UILabel *)[self viewWithTag:labelTag];
		[weekdayLabel setText:[weekday lowercaseString]];
	}
}

@end
