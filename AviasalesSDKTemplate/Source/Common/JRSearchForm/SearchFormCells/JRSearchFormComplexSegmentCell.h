//
//  JRSearchFormComplexConfigurationCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 22/01/14.
//
//

#import <UIKit/UIKit.h>
#import "JRSearchFormCell.h"

@protocol JRSearchFormComplexSegmentCellDelegate <NSObject>

@required
- (void)deleteTravelSegment:(ASTTravelSegment *)travelSegmentToDelete;
@end

@interface JRSearchFormComplexSegmentCell : JRSearchFormCell
@property (strong, nonatomic) ASTTravelSegment *travelSegment;
@property (weak, nonatomic) id <JRSearchFormComplexSegmentCellDelegate> segmentCellDelegate;

@end
