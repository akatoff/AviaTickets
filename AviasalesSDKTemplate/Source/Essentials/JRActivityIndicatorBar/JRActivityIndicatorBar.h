//
//  JRActivityIndicatorBar.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface JRActivityIndicatorBar : UIView

@property (strong, nonatomic) UIColor *indicatorColor;

@property (assign, nonatomic) BOOL prepareForSuperview;
@property (assign, nonatomic) BOOL startAnimation;
@property (assign, nonatomic) BOOL stopAnimation;

@end
