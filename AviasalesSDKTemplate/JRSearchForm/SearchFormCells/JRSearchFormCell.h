//
//  JRSearchFormCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 21/01/14.
//
//

#import <UIKit/UIKit.h>
#import "JRSearchInfo.h"
#import "JRSearchFormItem.h"
#import "JRTableViewCell.h"

@interface JRSearchFormCell : JRTableViewCell

@property (strong, nonatomic) JRSearchFormItem *item;

- (JRSearchInfo *)searchInfo;

- (void)updateCell;
- (void)action;

@end
