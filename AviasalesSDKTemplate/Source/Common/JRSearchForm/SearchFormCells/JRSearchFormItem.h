//
//  JRSearchFormItem.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRSearchInfo.h"

typedef NS_ENUM (NSUInteger, JRSearchFormItemType) {
	JRSearchFormTableViewItemAirportsType,
	JRSearchFormTableViewItemDatesType,
	JRSearchFormTableViewItemTravelClassAndPassengersType,
	JRSearchFormTableViewItemComplexSearchType,
    
	JRSearchFormTableViewOriginAirportItem,
	JRSearchFormTableViewDestinationAirportItem,
	JRSearchFormTableViewDirectDateItem,
	JRSearchFormTableViewReturnDateItem,
	JRSearchFormTableViewPassengersItem,
	JRSearchFormTableViewTravelClassItem,
	JRSearchFormTableViewComplexSegmentItem,
	JRSearchFormTableViewComplexAddSegmentItem
};

@class JRSearchFormCell;

@protocol JRSearchFormItemDelegate<NSObject>
@optional
- (JRSearchInfo *)searchInfo;
- (CGFloat)tableView:(id)tableView heightForItemWithType:(JRSearchFormItemType)type;
- (void)selectOriginIATAForTravelSegment:(JRTravelSegment *)travelSegment itemType:(JRSearchFormItemType)type;
- (void)selectDestinationIATAForTravelSegment:(JRTravelSegment *)travelSegment itemType:(JRSearchFormItemType)typ;
- (void)selectDepartureDateForTravelSegment:(JRTravelSegment *)travelSegment itemType:(JRSearchFormItemType)typ;
- (void)travelClassDidSelect;
- (void)saveReturnFlightTravelSegment;
- (void)restoreReturnFlightTravelSegment;
- (void)showPassengerPicker;
- (void)showTravelClassPickerFromView:(UIView *)view;
@end

@interface JRSearchFormItem : NSObject

@property (assign, readonly, nonatomic) JRSearchFormItemType type;
@property (weak, nonatomic) id<JRSearchFormItemDelegate> itemDelegate;

- (id)initWithType:(JRSearchFormItemType)type
      itemDelegate:(id<JRSearchFormItemDelegate>)itemDelegate;

- (NSString *)cellIdentifier;

@end
