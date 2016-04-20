//
//  JRDatePickerDayCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRDatePickerMonthItem.h"
#import "JRSearchInfo.h"

@interface JRDatePickerDayCell : UITableViewCell

- (void)setDatePickerItem:(JRDatePickerMonthItem *)datePickerItem dates:(NSArray *)dates;

@end
