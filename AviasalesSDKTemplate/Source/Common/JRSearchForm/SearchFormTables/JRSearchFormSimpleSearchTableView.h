//
//  JRSearchFormTableView.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 20/01/14.
//
//

#import <UIKit/UIKit.h>
#import "JRSearchFormItem.h"
#import "JRSearchFormAirportCell.h"
#import "JRSearchFormAirportsCell.h"

@interface JRSearchFormSimpleSearchTableView : UITableView

- (NSArray *)items;
- (void)setItems:(NSArray *)items;

@end
