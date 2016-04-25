//
//  JRSegmentedControl.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM (NSUInteger, JRSegmentedControlStyle) {
	JRSegmentedControlStyleLightContent,
	JRSegmentedControlStyleDarkContent,
	JRSegmentedControlStyleRoundContent
};

@class JRSegmentedControl;

@protocol JRSegmentedControlDelegate<NSObject>
@required
- (void)segmentedControl:(JRSegmentedControl *)segmentedControl clickedButtonAtIndex:(NSUInteger)buttonIndex;
@end

@interface JRSegmentedControl : UIView

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) CGFloat bottomBorderHeight;
@property (nonatomic, assign) CGFloat ribbonHeight;
@property (nonatomic, assign) CGFloat deselectedSegmentTextAlpha;

@property (nonatomic, assign) JRSegmentedControlStyle segmentedControlStyle;

@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, strong) UIFont *segmentLabelFont;
@property (nonatomic, strong) UIFont *segmentNormalLabelFont;

@property (nonatomic, strong) UIColor *segmentedControlStrokeColor;
@property (nonatomic, strong) UIColor *segmentStrokeColor;

@property (nonatomic, strong) UIColor *ribbonTintColor;
@property (nonatomic, strong) UIColor *segmentTitleTintColor;
@property (nonatomic, strong) UIColor *segmentNormalTitleTintColor;

@property (nonatomic, weak) id<JRSegmentedControlDelegate> delegate;

- (id)initWithItems:(NSArray *)items;
- (void)selectSegmentAtIndex:(NSInteger)segmentIndex animated:(BOOL)animated;

- (NSArray *)controlViews;

@end
