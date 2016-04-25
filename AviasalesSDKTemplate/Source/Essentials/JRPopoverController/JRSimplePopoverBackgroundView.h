//
//  JRSimplePopoverBackgroundView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface JRSimplePopoverBackgroundView : UIPopoverBackgroundView
+ (CGFloat)cornerRadius;
+ (UIEdgeInsets)contentViewInsets;
+ (UIImage *)arrowImage;//arrow up image

- (id)initWithFrame:(CGRect)frame;
@end
