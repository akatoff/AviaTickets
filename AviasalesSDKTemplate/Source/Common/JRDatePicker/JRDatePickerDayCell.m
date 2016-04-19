//
//  JRDatePickerDateViewCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 05/02/14.
//
//

#import "JRDatePickerDayCell.h"
#import "JRDatePickerMonthItem.h"
#import "NSLayoutConstraint+JRConstraintMake.h"
#import "JRDatePickerDayView.h"
#import "JRC.h"
#import "JRViewController.h"

#define DATE_VIEW_TAG_OFFSET 1000
#define NUMBER_OF_DAYS_IN_WEEK 7
@interface JRDatePickerDayCell ()
@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic) JRDatePickerMonthItem *datePickerItem;
@property (strong, nonatomic) UIView *layoutAttributeView;
@property (strong, nonatomic) UIColor *nornalGrayColor;
@property (strong, nonatomic) UIColor *nornalSelectedColor;
@end


@implementation JRDatePickerDayCell

- (void)initialSetup
{
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	[self setBackgroundColor:[UIColor clearColor]];
    
	[self disableClipForViewSubviews:self];
    
	_nornalGrayColor = [JRC DATE_PICKER_NORMAL_DATE_COLOR];
	_nornalSelectedColor = [JRC DATE_PICKER_NORMAL_SELECTED_DATE_COLOR];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
        
		[self initialSetup];
	}
	return self;
}

- (JRDatePickerDayView *)createDateViewWithTag:(NSInteger)dateViewTag
                             dateViewSuperview:(UIView *)dateViewSuperview
                                   indexOfDate:(NSUInteger)indexOfDate
{
	JRDatePickerDayView *dateView = LOAD_VIEW_FROM_NIB_NAMED(@"JRDatePickerDayView");
    
	[dateView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[dateView setTag:dateViewTag];
    
	[dateViewSuperview addSubview:dateView];
    
    CGFloat fraction = 1.0f / NUMBER_OF_DAYS_IN_WEEK;
    CGFloat leftToRightMultiplier = fraction * indexOfDate;
    
    NSLayoutAttribute secondLeftToRightAttribute = NSLayoutAttributeRight;
    if (leftToRightMultiplier == 0.0f) {
        secondLeftToRightAttribute = NSLayoutAttributeLeft;
        leftToRightMultiplier = 1.0f;
    }
    
	[dateViewSuperview addConstraint:JRConstraintMake(dateView, NSLayoutAttributeLeft, NSLayoutRelationEqual, dateViewSuperview, secondLeftToRightAttribute, leftToRightMultiplier, 0)];
    
	[dateViewSuperview addConstraint:JRConstraintMake(dateView, NSLayoutAttributeWidth, NSLayoutRelationEqual, dateViewSuperview, NSLayoutAttributeWidth, fraction, 0)];
    
	[dateViewSuperview addConstraint:JRConstraintMake(dateView, NSLayoutAttributeHeight, NSLayoutRelationEqual, dateView, NSLayoutAttributeWidth, 1, 0)];
    
	[dateViewSuperview addConstraint:JRConstraintMake(dateView, NSLayoutAttributeTop, NSLayoutRelationEqual, dateViewSuperview, NSLayoutAttributeTop, 1, 0)];
	return dateView;
}

- (JRDatePickerDayView *)dateViewForDate:(NSDate *)date
{
	BOOL shouldHideCell = [_datePickerItem.prevDates containsObject:date] ||
    [_datePickerItem.futureDates containsObject:date];
    
	NSUInteger indexOfDate = [_dates indexOfObject:date];
	NSInteger dateViewTag = indexOfDate + DATE_VIEW_TAG_OFFSET;
    
	UIView *dateViewSuperview = self.contentView;
    
	id viewWithTag = [dateViewSuperview viewWithTag:dateViewTag];
	JRDatePickerDayView *dateView = viewWithTag;
    
	if (!dateView && !shouldHideCell) {
        
		dateView = [self createDateViewWithTag:dateViewTag
                             dateViewSuperview:dateViewSuperview
                                   indexOfDate:indexOfDate];
        
	}
    
	[dateView setDotHidden:YES];
	[dateView setTodayLabelHidden:YES];
    
	[dateView setHidden:shouldHideCell];
    
	if (shouldHideCell) {
		return nil;
	} else {
		return dateView;
	}
    
}

- (void)setupDateView:(JRDatePickerDayView *)dateView date:(NSDate *)date
{
    [dateView setBackgroundImageViewHidden:YES];
    
	[dateView setDate:date monthItem:_datePickerItem];

	[dateView addTarget:self action:@selector(dateViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [dateView setEnabled:[_datePickerItem.stateObject.disabledDates containsObject:date] &&
     [date compare:_datePickerItem.stateObject.lastAvalibleForSearchDate] == NSOrderedAscending];
    
    
	BOOL isSelectedDate = _datePickerItem.stateObject.firstSelectedDate == date || _datePickerItem.stateObject.secondSelectedDate == date;
	[dateView setSelected:isSelectedDate];
    
	UIColor *normalTextColor = [_datePickerItem.stateObject.selectedDates containsObject:date] ?
    _nornalSelectedColor : _nornalGrayColor;
	[dateView setTodayLabelHidden:date != _datePickerItem.stateObject.today];
	[dateView setDateLabelColor:normalTextColor];
    
	NSUInteger nextDateIndex = [_dates indexOfObject:date] + 1;
	BOOL nextDateNotInThisMonth = NO;
	if (_dates.count > nextDateIndex) {
		NSDate *nextDate = _dates[nextDateIndex];
		nextDateNotInThisMonth = [[_datePickerItem futureDates] containsObject:nextDate];
	}
	BOOL shouldShowDot = [_datePickerItem.stateObject.selectedDates containsObject:date] &&
    date != _dates.lastObject &&
    date != _datePickerItem.stateObject.secondSelectedDate &&
    !nextDateNotInThisMonth;
	[dateView setDotHidden:!shouldShowDot];
    
}

- (void)updateCell
{
    for (UIButton *button in self.contentView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setHighlighted:NO];
            [button setSelected:NO];
        }
    }
	for (NSDate *date in _dates) {
        
		JRDatePickerDayView *dateView = [self dateViewForDate:date];
        
		if (dateView) {
            
			[self setupDateView:dateView date:date ];
		}
	}
}

- (void)dateViewAction:(JRDatePickerDayView *)dateViewAction
{
	[_datePickerItem.stateObject.delegate dateWasSelected:dateViewAction.date];
}

- (void)setDatePickerItem:(JRDatePickerMonthItem *)datePickerItem dates:(NSArray *)dates
{
	_dates = dates;
	_datePickerItem = datePickerItem;
    
	[self updateCell];
    
	[self disableClipForViewSubviews:self];
}

- (void)disableClipForViewSubviews:(UIView *)superview
{
    
	[superview setClipsToBounds:NO];
	[superview setOpaque:YES];
	[superview setBackgroundColor:[UIColor clearColor]];
    
	for (UIView *view in superview.subviews) {
		[self disableClipForViewSubviews:view];
	}
}

@end
