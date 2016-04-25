//
//  JRSearchFormComplexSegmentCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRSearchFormCell.h"

@protocol JRSearchFormComplexSegmentCellDelegate <NSObject>

@required
- (void)deleteTravelSegment:(JRTravelSegment *)travelSegmentToDelete;
@end

@interface JRSearchFormComplexSegmentCell : JRSearchFormCell
@property (strong, nonatomic) JRTravelSegment *travelSegment;
@property (weak, nonatomic) id <JRSearchFormComplexSegmentCellDelegate> segmentCellDelegate;

@end
