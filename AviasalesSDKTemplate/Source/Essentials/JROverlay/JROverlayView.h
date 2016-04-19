//
//  JROverlayView.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 25/04/14.
//
//

#import <UIKit/UIKit.h>

@interface JROverlayView : UIView

+ (JROverlayView *)showInView:(UIView *)view;
+ (JROverlayView *)showInView:(UIView *)view withTag:(NSString *)tag;
+ (void)hideAllInView:(UIView *)view;
+ (void)hideInView:(UIView *)view withTag:(NSString *)tag;

- (void)hide;

@end
