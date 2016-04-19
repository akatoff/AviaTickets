//
//  JRDatePickerStateObject.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 10/02/14.
//
//

#import <Foundation/Foundation.h>
#import "ASTSearchInfo.h"

typedef enum {
	JRDatePickerModeDeparture,
	JRDatePickerModeReturn,
	JRDatePickerModeDefault
} JRDatePickerMode;

@protocol JRDatePickerStateObjectActionDelegate<NSObject>
@required
-(void)dateWasSelected:(NSDate *)date;
@end

@interface JRDatePickerStateObject : NSObject

@property (assign, nonatomic) JRDatePickerMode mode;
@property (strong, nonatomic) ASTSearchInfo *searchInfo;
@property (strong, nonatomic) ASTTravelSegment *travelSegment;
@property (strong, nonatomic) NSDate *firstAvalibleForSearchDate;
@property (strong, nonatomic) NSDate *lastAvalibleForSearchDate;
@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) NSDate *borderDate;
@property (strong, nonatomic) NSDate *firstSelectedDate;
@property (strong, nonatomic) NSDate *secondSelectedDate;
@property (strong, nonatomic) NSMutableArray *monthItems;
@property (strong, nonatomic) NSMutableArray *selectedDates;
@property (strong, nonatomic) NSIndexPath *indexPathToScroll;
@property (strong, readonly, nonatomic) NSMutableArray *disabledDates;
@property (strong, readonly, nonatomic) NSMutableDictionary *weeksStrings;

@property (weak, nonatomic) id <JRDatePickerStateObjectActionDelegate> delegate;

- (id)initWithDelegate:(id<JRDatePickerStateObjectActionDelegate>)delegate;
- (void)updateSelectedDatesRange;
@end
