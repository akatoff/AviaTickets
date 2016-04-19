//
//  JRSearchFormCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 21/01/14.
//
//

#import <UIKit/UIKit.h>
#import "ASTSearchInfo.h"
#import "JRSearchFormItem.h"
#import "JRTableViewCell.h"

@interface JRSearchFormCell : JRTableViewCell

@property (strong, nonatomic) JRSearchFormItem *item;

- (ASTSearchInfo *)searchInfo;

- (void)updateCell;
- (void)action;

@end
