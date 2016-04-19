//
//  FPPopoverView+DrawRect.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 19/03/14.
//
//

#import "FPPopoverView.h"

@interface FPPopoverView (DrawRect)
- (UIBezierPath *)newBezierPathPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(FPPopoverArrowDirection)direction;
- (CGPathRef)swizzled_newContentPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(FPPopoverArrowDirection)direction;
@end
