//
//  JRSimplePopoverBackgroundView.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 04/03/14.
//
//

#import <UIKit/UIKit.h>

@interface JRSimplePopoverBackgroundView : UIPopoverBackgroundView
+ (CGFloat)cornerRadius;
+ (UIEdgeInsets)contentViewInsets;
+ (UIImage *)arrowImage;//arrow up image

- (id)initWithFrame:(CGRect)frame;
@end
