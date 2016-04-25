//
//  JRSearchFormComplexTableClearCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRSearchFormCell.h"

@protocol JRSearchFormComplexTableClearCellDelegate <NSObject>

@required

- (void)addTravelSegment;
- (void)removeLastSegment;

@end

@interface JRSearchFormComplexTableClearCell : JRSearchFormCell
@property (weak, nonatomic) id <JRSearchFormComplexTableClearCellDelegate> addCellDelegate;
@end
