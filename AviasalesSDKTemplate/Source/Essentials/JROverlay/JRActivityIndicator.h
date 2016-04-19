//
//  JRActivityIndicator.h
//  Aviasales iOS Apps
//
//  Created by glassoff on 24/04/14.
//
//

#import <Foundation/Foundation.h>

@interface JRActivityIndicator : UIView

+ (JRActivityIndicator *)showInView:(UIView *)view withTitle:(NSString *)title;
+ (void)hideAllFromView:(UIView *)view;

- (void)hide;

@end
