//
//  JRSwipeDeletionTableView.m
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 27/03/14.
//
//

#import "JRSwipeDeletionTableView.h"

@implementation JRSwipeDeletionTableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.swipedCell && !CGRectContainsPoint(self.swipedCell.frame, point)) {
        [self.swipedCell swipedButtonHideAnimated:YES];
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

@end
