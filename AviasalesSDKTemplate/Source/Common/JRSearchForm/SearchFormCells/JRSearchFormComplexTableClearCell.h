//
//  JRSearchFormComplexAddConfigurationCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 22/01/14.
//
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
