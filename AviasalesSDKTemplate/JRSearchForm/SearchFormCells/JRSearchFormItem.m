//
//  JRSearchFormTableViewItem.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 20/01/14.
//
//

#import "JRSearchFormAirportCell.h"
#import "JRSearchFormAirportsCell.h"
#import "JRSearchFormComplexSegmentCell.h"
#import "JRSearchFormComplexTableClearCell.h"
#import "JRSearchFormDateCell.h"
#import "JRSearchFormDatesCell.h"
#import "JRSearchFormItem.h"
#import "JRSearchFormPassengersCell.h"
#import "JRSearchFormTravelClassAndPassengersCell.h"
#import "JRSearchFormTravelClassCell.h"
#import "JRSearchFormVC.h"

@implementation JRSearchFormItem

- (id)initWithType:(JRSearchFormItemType)type
      itemDelegate:(id<JRSearchFormItemDelegate>)itemDelegate
{
	self = [super init];
	if (self) {
		_type = type;
		_itemDelegate = itemDelegate;
	}
	return self;
}

- (NSString *)cellIdentifier
{
	Class class = NULL;
	if (_type == JRSearchFormTableViewItemAirportsType) {
		class = [JRSearchFormAirportsCell class];
	} else if (_type == JRSearchFormTableViewOriginAirportItem ||
	           _type == JRSearchFormTableViewDestinationAirportItem) {
		class = [JRSearchFormAirportCell class];
	} else if (_type == JRSearchFormTableViewItemDatesType) {
		class = [JRSearchFormDatesCell class];
	} else if (_type == JRSearchFormTableViewDirectDateItem ||
	           _type == JRSearchFormTableViewReturnDateItem) {
		class = [JRSearchFormDateCell class];
	} else if (_type == JRSearchFormTableViewItemTravelClassAndPassengersType) {
		class = [JRSearchFormTravelClassAndPassengersCell class];
	} else if (_type == JRSearchFormTableViewPassengersItem) {
		class = [JRSearchFormPassengersCell class];
	} else if (_type == JRSearchFormTableViewTravelClassItem) {
		class = [JRSearchFormTravelClassCell class];
	} else if (_type == JRSearchFormTableViewComplexSegmentItem) {
		class = [JRSearchFormComplexSegmentCell class];
	} else if (_type == JRSearchFormTableViewComplexAddSegmentItem) {
		class = [JRSearchFormComplexTableClearCell class];
	}
	return NSStringFromClass(class);
}

@end
