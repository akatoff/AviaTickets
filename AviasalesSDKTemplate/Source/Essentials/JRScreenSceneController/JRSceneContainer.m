//
//  JRSceneContainer.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 10/01/14.
//
//

#import "JRSceneContainer.h"

@implementation JRSceneContainer

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            if (point.x <= _passThroughTouchEventsX) {
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

@end
