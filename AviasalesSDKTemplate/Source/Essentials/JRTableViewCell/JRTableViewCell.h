//
//  JRTableViewCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 31/03/14.
//
//

#import <UIKit/UIKit.h>

@interface JRTableViewCell : UITableViewCell

@property (assign, nonatomic) UIColor *bottomLineColor;
@property (assign, nonatomic) BOOL bottomLineVisible;
@property (assign, nonatomic) BOOL showLastLine;
@property (assign, nonatomic) CGFloat leftOffset;
@property (assign, nonatomic) UIEdgeInsets bottomLineInsets;
@property (strong, nonatomic) UIView *customBackgroundView;
@property (strong, nonatomic) UIView *customSelectedBackgroundView;

- (void)updateBackgroundViewsForImagePath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView;
@end
