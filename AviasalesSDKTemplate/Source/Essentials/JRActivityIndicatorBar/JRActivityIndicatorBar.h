//
//  JRActivityIndicatorBar.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 06/03/14.
//
//

#import <UIKit/UIKit.h>

@interface JRActivityIndicatorBar : UIView

@property (strong, nonatomic) UIColor *indicatorColor;

@property (assign, nonatomic) BOOL prepareForSuperview;
@property (assign, nonatomic) BOOL startAnimation;
@property (assign, nonatomic) BOOL stopAnimation;

@end
