//
//  FPPopoverView+DrawRect.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "FPPopoverView.h"

@interface FPPopoverView (DrawRect)
- (UIBezierPath *)newBezierPathPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(FPPopoverArrowDirection)direction;
- (CGPathRef)swizzled_newContentPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(FPPopoverArrowDirection)direction;
@end
