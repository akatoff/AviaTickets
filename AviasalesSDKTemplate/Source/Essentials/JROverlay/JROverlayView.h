//
//  JROverlayView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface JROverlayView : UIView

+ (JROverlayView *)showInView:(UIView *)view;
+ (JROverlayView *)showInView:(UIView *)view withTag:(NSString *)tag;
+ (void)hideAllInView:(UIView *)view;
+ (void)hideInView:(UIView *)view withTag:(NSString *)tag;

- (void)hide;

@end
