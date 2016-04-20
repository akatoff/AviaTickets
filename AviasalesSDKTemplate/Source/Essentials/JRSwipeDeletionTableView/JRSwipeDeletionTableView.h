//
//  JRSwipeDeletionTableView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRSwipeDeletionTableViewCell.h"

@interface JRSwipeDeletionTableView : UITableView
@property (nonatomic, strong) JRSwipeDeletionTableViewCell *swipedCell;
@property (nonatomic) BOOL disabledSwipe;
@end
