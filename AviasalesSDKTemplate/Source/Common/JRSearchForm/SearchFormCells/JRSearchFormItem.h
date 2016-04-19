//
//  JRSearchFormTableViewItem.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 20/01/14.
//
//

#import <Foundation/Foundation.h>
#import "ASTSearchInfo.h"

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
- (ASTSearchInfo *)searchInfo;
- (CGFloat)tableView:(id)tableView heightForItemWithType:(JRSearchFormItemType)type;
- (void)selectOriginIATAForTravelSegment:(ASTTravelSegment *)travelSegment itemType:(JRSearchFormItemType)type;
- (void)selectDestinationIATAForTravelSegment:(ASTTravelSegment *)travelSegment itemType:(JRSearchFormItemType)typ;
- (void)selectDepartureDateForTravelSegment:(ASTTravelSegment *)travelSegment itemType:(JRSearchFormItemType)typ;
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
