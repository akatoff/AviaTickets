//
//  JRDatePickerDayView.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 07/02/14.
//
//

#import <UIKit/UIKit.h>
#import "JRDatePickerMonthItem.h"

@interface JRDatePickerDayView : UIButton

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIColor *dateLabelColor;
@property (assign, nonatomic) BOOL todayLabelHidden;
@property (assign, nonatomic) BOOL dotHidden;
@property (assign, nonatomic) BOOL backgroundImageViewHidden;

- (void)setDate:(NSDate *)date monthItem:(JRDatePickerMonthItem *)monthItem;

@end
