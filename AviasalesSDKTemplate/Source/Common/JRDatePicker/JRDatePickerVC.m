//
//  JRDatePickerVC.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 04/02/14.
//
//

#import "JRDatePickerVC.h"
#import "JRDatePickerMonthItem.h"
#import "JRDatePickerDayCell.h"
#import "JRDatePickerMonthHeaderReusableView.h"
#import "DateUtil.h"
#import "UIView+FadeAnimation.h"
#import "JRC.h"
#import "JRViewController+JRScreenScene.h"

#define kJRDatePickerCollectionHeaderHeight 65
#define kJRDatePickerToolbarHeight 87

@interface JRDatePickerVC ()<UITableViewDataSource, UITableViewDelegate, JRDatePickerStateObjectActionDelegate>
@property (assign, nonatomic) BOOL shouldShowSearchToolbar;
@property (strong, nonatomic) JRDatePickerStateObject *stateObject;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchButtonToolbar;
@end

@implementation JRDatePickerVC

- (instancetype)initWithSearchInfo:(ASTSearchInfo *)searchInfo
                     travelSegment:(ASTTravelSegment *)travelSegment
                              mode:(JRDatePickerMode)mode
           shouldShowSearchToolbar:(BOOL)shouldShowSearchToolbar {
    self = [self initWithSearchInfo:searchInfo travelSegment:travelSegment mode:mode];
    if (self) {
        [self setShouldShowSearchToolbar:shouldShowSearchToolbar];
    }
    return self;
}

- (instancetype)initWithSearchInfo:(ASTSearchInfo *)searchInfo
                     travelSegment:(ASTTravelSegment *)travelSegment
                              mode:(JRDatePickerMode)mode
{
	self = [super init];
	if (self) {
		_stateObject = [[JRDatePickerStateObject alloc] initWithDelegate:self];
		[_stateObject setSearchInfo:searchInfo];
		[_stateObject setTravelSegment:travelSegment];
		[_stateObject setMode:mode];
		[self buildTable];
	}
	return self;
}

static NSString *DayCellIdentifier = @"JRDatePickerDayCell";
static NSString *MonthReusableHeaderViewIdentifier = @"JRDatePickerMonthHeaderReusableView";

- (void)registerNibs
{
    
	[_tableView registerClass:[JRDatePickerDayCell class] forCellReuseIdentifier:DayCellIdentifier];
    
	UINib *headerNib = [UINib nibWithNibName:MonthReusableHeaderViewIdentifier bundle:nil];
	[_tableView registerNib:headerNib forHeaderFooterViewReuseIdentifier:MonthReusableHeaderViewIdentifier];
}

- (void)setupTitle
{
	if (_stateObject.mode == JRDatePickerModeReturn) {
		if (_shouldShowSearchToolbar) {
            [self setTitle:NSLS(@"JR_DATE_PICKER_TRAVEL_DATES_TITLE")];
        } else {
            [self setTitle:NSLS(@"JR_DATE_PICKER_RETURN_DATE_TITLE")];
        }
	} else {
		[self setTitle:NSLS(@"JR_DATE_PICKER_DEPARTURE_DATE_TITLE")];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self registerNibs];
	[self setupTitle];
    
	[_tableView setBackgroundColor:[JRC COMMON_BACKGROUND]];
    [self setSearchButtonToolbarHidden:_shouldShowSearchToolbar ? NO : YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_tableView reloadData];
	[_tableView scrollToRowAtIndexPath:_stateObject.indexPathToScroll atScrollPosition:UITableViewScrollPositionTop animated:NO];}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[_tableView flashScrollIndicators];
    
}

- (void)setSearchButtonToolbarHidden:(BOOL)searchButtonToolbarHidden {
    [_searchButtonToolbar setHidden:searchButtonToolbarHidden];
    if (_searchButtonToolbar.hidden == YES) {
        [_tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    } else {
        [_tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, kJRDatePickerToolbarHeight, 0)];
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, kJRDatePickerToolbarHeight, 0)];
    }
}

- (void)buildTable
{
	NSMutableArray *datesToRepresent = [NSMutableArray new];
    
	NSUInteger prevIndex = [_stateObject.searchInfo.travelSegments indexOfObject:_stateObject.travelSegment] - 1;
	if (_stateObject.mode != JRDatePickerModeDeparture && _stateObject.searchInfo.travelSegments.count > prevIndex) {
		ASTTravelSegment *segment = (_stateObject.searchInfo.travelSegments)[prevIndex];
		[_stateObject setBorderDate:segment.departureDate];
	}
	if (!_stateObject.borderDate) {
		[_stateObject setBorderDate:[DateUtil firstAvalibleForSearchDate]];
	}
    
	NSDate *firstMonth = [DateUtil firstDayOfMonth:[DateUtil resetTimeForDate:[DateUtil today]]];
	[datesToRepresent addObject:firstMonth];
	for (NSUInteger i = 1; i <= 12; i++) {
		NSDate *prevMonth = datesToRepresent[i - 1];
		[datesToRepresent addObject:[DateUtil nextMonthForDate:prevMonth]];
	}
    
    
	for (NSDate *date in datesToRepresent) {
		[_stateObject.monthItems addObject:[JRDatePickerMonthItem monthItemWithFirstDateOfMonth:date stateObject:_stateObject]];
	}
	[_stateObject updateSelectedDatesRange];
}

- (void)dateWasSelected:(NSDate *)date
{
	if (_stateObject.mode == JRDatePickerModeDefault) {
		_stateObject.firstSelectedDate = date;
	} else {
		if (_stateObject.travelSegment == _stateObject.searchInfo.travelSegments.firstObject) {
			_stateObject.firstSelectedDate = date;
		} else {
			_stateObject.secondSelectedDate = date;
		}
	}
	[_stateObject.travelSegment setDepartureDate:date];
	[_stateObject updateSelectedDatesRange];
	[_tableView reloadData];
    
    if (_searchButtonToolbar.hidden == YES) {
        [self performSelector:@selector(popAction) withObject:nil afterDelay:0.15];
    }
    
    if ([_delegate respondsToSelector:@selector(datePicker:didSelectDepartDate:inTravelSegment:)]) {
        [_delegate datePicker:self didSelectDepartDate:date inTravelSegment:_stateObject.travelSegment];
    }
}

- (void)popAction
{
	[super popAction];
    [self detachAccessoryViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _stateObject.monthItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	JRDatePickerMonthItem *monthItem = (_stateObject.monthItems)[section];
	return monthItem.weeks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JRDatePickerDayCell *cell = [tableView dequeueReusableCellWithIdentifier:DayCellIdentifier];
	JRDatePickerMonthItem *monthItem = (_stateObject.monthItems)[indexPath.section];
	NSArray *dates = (monthItem.weeks)[indexPath.row];
	[cell setDatePickerItem:monthItem dates:dates];
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	JRDatePickerMonthHeaderReusableView *sectionHeaderView = [tableView
	                                                          dequeueReusableHeaderFooterViewWithIdentifier:MonthReusableHeaderViewIdentifier];
	[sectionHeaderView setMonthItem:(_stateObject.monthItems)[section]];
	return sectionHeaderView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.view.frame.size.width / 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kJRDatePickerCollectionHeaderHeight;
}

- (IBAction)searchButtonAction:(id)sender {
    [_stateObject.searchInfo clipSearchInfoForSimpleSearchIfNeeds];
    // TODO: start new search
//    [[JRMenuManager sharedInstance] startNewSearchWithSearchInfo:_stateObject.searchInfo andSearchSource:JRSearchSourcePriceCalendar];
    [_parentPopoverController dismissPopoverAnimated:YES];
}

@end
