//
//  JRSearchFormCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
