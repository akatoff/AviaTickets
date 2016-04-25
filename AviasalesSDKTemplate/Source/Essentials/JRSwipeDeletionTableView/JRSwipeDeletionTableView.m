//
//  JRSwipeDeletionTableView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
