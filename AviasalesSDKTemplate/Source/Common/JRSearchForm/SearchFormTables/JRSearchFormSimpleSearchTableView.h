//
//  JRSearchFormSimpleSearchTableView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRSearchFormItem.h"
#import "JRSearchFormAirportCell.h"
#import "JRSearchFormAirportsCell.h"

@interface JRSearchFormSimpleSearchTableView : UITableView

- (NSArray *)items;
- (void)setItems:(NSArray *)items;

@end
