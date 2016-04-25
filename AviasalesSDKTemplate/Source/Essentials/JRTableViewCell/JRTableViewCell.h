//
//  JRTableViewCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
