//
//  JRDatePickerDateViewCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 05/02/14.
//
//

#import <UIKit/UIKit.h>
#import "JRDatePickerMonthItem.h"
#import "ASTSearchInfo.h"

@interface JRDatePickerDayCell : UITableViewCell

- (void)setDatePickerItem:(JRDatePickerMonthItem *)datePickerItem dates:(NSArray *)dates;

@end
