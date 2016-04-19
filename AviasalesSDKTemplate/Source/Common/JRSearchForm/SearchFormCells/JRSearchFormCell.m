//
//  JRSearchFormCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 21/01/14.
//
//

#import "JRSearchFormCell.h"
#import "JRSearchFormComplexSegmentCell.h"
#import "ASTSearchInfo.h"
#import "JRC.h"

@interface JRSearchFormCell ()

@end

@implementation JRSearchFormCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self updateCell];
}

- (ASTSearchInfo *)searchInfo
{
	return [_item.itemDelegate searchInfo];
}

- (void)setupBackgroundViews
{
	self.customBackgroundView.backgroundColor = [JRC CLEAR_COLOR];
	self.customSelectedBackgroundView.backgroundColor = [JRC SF_CELL_HIGHLIGHTED_COLOR];
}

- (void)setItem:(JRSearchFormItem *)item
{
	_item = item;
    
	[self setupBackgroundViews];
    
	[self updateCell];
}

- (void)updateCell
{
    
}

- (void)action
{
    
}

@end
