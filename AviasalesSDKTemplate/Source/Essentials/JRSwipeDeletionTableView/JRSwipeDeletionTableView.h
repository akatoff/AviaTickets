//
//  JRSwipeDeletionTableView.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 27/03/14.
//
//

#import <UIKit/UIKit.h>
#import "JRSwipeDeletionTableViewCell.h"

@interface JRSwipeDeletionTableView : UITableView
@property (nonatomic, strong) JRSwipeDeletionTableViewCell *swipedCell;
@property (nonatomic) BOOL disabledSwipe;
@end
