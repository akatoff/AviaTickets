//
//  FPPopoverView+DrawRect.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "FPPopoverView+DrawRect.h"
#import <objc/runtime.h>


#define FP_POPOVER_ARROW_HEIGHT 20.0
#define FP_POPOVER_ARROW_BASE 34.0
#define FP_POPOVER_RADIUS 10.0

@implementation FPPopoverView (DrawRect)

+ (void)initialize {
    IMP swizzled;
    swizzled = class_getMethodImplementation(self.class, @selector(swizzled_drawRect:));
    class_replaceMethod(self.class, @selector(drawRect:), swizzled, "@");
    
    swizzled = class_getMethodImplementation(self.class, @selector(swizzled_newContentPathWithBorderWidth:arrowDirection:));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_replaceMethod(self.class, @selector(newContentPathWithBorderWidth:arrowDirection:), swizzled, "@");
#pragma clang diagnostic pop
}

- (void)swizzled_drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (UIBezierPath *)newBezierPathPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(FPPopoverArrowDirection)direction
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat ah = FP_POPOVER_ARROW_HEIGHT; //is the height of the triangle of the arrow
    CGFloat aw = FP_POPOVER_ARROW_BASE/2.0; //is the 1/2 of the base of the arrow
    CGFloat radius = FP_POPOVER_RADIUS;
    CGFloat b = borderWidth;
    
    //NO BORDER
    if(self.border == NO) {
        b = 10.0;
    }
    
    CGRect rect;
    if(direction == FPPopoverArrowDirectionUp)
    {
        
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = ah + b;
    }
    else if(direction == FPPopoverArrowDirectionDown)
    {
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;
    }
    
    
    else if(direction == FPPopoverArrowDirectionRight)
    {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;
    }
    else if(direction == FPPopoverArrowDirectionLeft)
    {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = ah + b;
        rect.origin.y = b;
    }
    
    //NO ARROW
    else
    {
        rect.size.width = w - 2*b;
        rect.size.height = (h - 2*b) - ah;
        rect.origin.x = b;
        rect.origin.y = b + ah;
    }
    
    
    
    //the arrow will be near the origin
    CGFloat ax = self.relativeOrigin.x - aw; //the start of the arrow when UP or DOWN
    if(ax < aw + b) ax = aw + b;
    else if (ax +2*aw + 2*b> self.bounds.size.width) ax = self.bounds.size.width - 2*aw - 2*b;
    
    CGFloat ay = self.relativeOrigin.y - aw; //the start of the arrow when RIGHT or LEFT
    if(ay < aw + b) ay = aw + b;
    else if (ay +2*aw + 2*b > self.bounds.size.height) ay = self.bounds.size.height - 2*aw - 2*b;
    
    
    
    //ROUNDED RECT
    // arrow UP
    CGRect  innerRect = CGRectInset(rect, radius, radius);
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
    
    
    //drawing the border with arrow
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, innerRect.origin.x, outside_top);
    
    //top arrow
    if(direction == FPPopoverArrowDirectionUp)
    {
        CGPathAddLineToPoint(path, NULL, ax, ah+b);
        CGPathAddLineToPoint(path, NULL, ax+aw, b);
        CGPathAddLineToPoint(path, NULL, ax+2*aw, ah+b);
        
    }
    
    
    CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(path, NULL, outside_right, outside_top, outside_right, inside_top, radius);
    
    //right arrow
    if(direction == FPPopoverArrowDirectionRight)
    {
        CGPathAddLineToPoint(path, NULL, outside_right, ay);
        CGPathAddLineToPoint(path, NULL, outside_right + ah, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_right, ay + 2*aw);
    }
    
    
	CGPathAddLineToPoint(path, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
    //down arrow
    if(direction == FPPopoverArrowDirectionDown)
    {
        CGPathAddLineToPoint(path, NULL, ax+2*aw, outside_bottom);
        CGPathAddLineToPoint(path, NULL, ax+aw, outside_bottom + ah);
        CGPathAddLineToPoint(path, NULL, ax, outside_bottom);
    }
    
	CGPathAddLineToPoint(path, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
    
    //left arrow
    if(direction == FPPopoverArrowDirectionLeft)
    {
        CGPathAddLineToPoint(path, NULL, outside_left, ay + 2*aw);
        CGPathAddLineToPoint(path, NULL, outside_left - ah, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_left, ay);
    }
    
    
	CGPathAddLineToPoint(path, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
    
    CGPathCloseSubpath(path);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
    CGPathRelease(path);
    return bezierPath;
    
}

- (CGPathRef)swizzled_newContentPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(FPPopoverArrowDirection)direction
{
    return nil;
}

@end
