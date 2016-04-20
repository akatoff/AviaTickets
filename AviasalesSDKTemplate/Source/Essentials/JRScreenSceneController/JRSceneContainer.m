//
//  JRSceneContainer.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
