//
//  JRSegmentedControl.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSegmentedControl.h"
#import "JRC.h"
#import "UIView+JRFadeAnimation.h"
#import "UIImage+JRUIImage.h"
#import "NSLayoutConstraint+JRConstraintMake.h"

#define kJRSegmentedControlDefaultTopBorderHeight 0.5
#define kJRSegmentedControlDefaultTopBorderColor [[JRC WHITE_COLOR] colorWithAlphaComponent:0.2]
#define kJRSegmentedControlDefaultBottomBorderHeight 0.5
#define kJRSegmentedControlDefaultNormalSegmentTextAlpha 0.4
#define kJRSegmentedControlDefaultRibbonHeight iPhone() ? 4 : 1.5
#define kJRSegmentedControlDefaultSegmentedControlAnimationDuration 0.4
#define kJRSegmentedControlDefaultSegmentedControlAnimationUsingSpringWithDamping 0.75
#define kJRSegmentedControlDefaultSegmentedControlAnimationInitialSpringVelocity 1
#define kJRSegmentedControlDefaultSegmentedControlStyle JRSegmentedControlStyleLightContent
#define kJRSegmentedControlDefaultSegmentLabelFont [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]
#define kJRSegmentedControlLightContentTitleBottomEdgeInset 2

@interface JRSegmentedControl ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSLayoutConstraint *bottomBorderConstraint;
@property (nonatomic, strong) NSLayoutConstraint *ribbonBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *ribbonHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *ribbonLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *ribbonWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *segmentedControlHeightConstraint;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, strong) UIView *ribbon;
@property (nonatomic, strong) UIView *toolbar;
@end

@implementation JRSegmentedControl

#pragma mark - JRSegmentedControl Creation and Subview Creation

- (id)init
{
	return nil;
}

- (id)initWithItems:(NSArray *)items
{
    
	if ([items isKindOfClass:[NSArray class]] && items.count > 0) {
        
		self = [super init];
        
		_items = items;
        
		_animationDuration      = kJRSegmentedControlDefaultSegmentedControlAnimationDuration;
		_bottomBorderHeight     = kJRSegmentedControlDefaultBottomBorderHeight;
		_deselectedSegmentTextAlpha = kJRSegmentedControlDefaultNormalSegmentTextAlpha;
		_ribbonHeight           = kJRSegmentedControlDefaultRibbonHeight;
		_segmentedControlStyle  = kJRSegmentedControlDefaultSegmentedControlStyle;
		_segmentLabelFont       = kJRSegmentedControlDefaultSegmentLabelFont;
        
		_ribbonTintColor        = [JRC BLACK_COLOR];
		_segmentTitleTintColor  = [JRC BLACK_COLOR];
        
		_selectedIndex          = NSNotFound;
        
		[self createViewsAndSetupConstraintsForBottomBorder];
		[self updateSubviews];
        
		return self;
	} else {
		return nil;
	}
}



#pragma mark - Segmented Control Updates and Events

- (void)updateSubviews
{
    
	for (UIButton *button in [self controlViews]) {
		UIColor *titleColorForNormalState = [_segmentTitleTintColor colorWithAlphaComponent:_deselectedSegmentTextAlpha];
		if (_segmentNormalTitleTintColor) {
			titleColorForNormalState = _segmentNormalTitleTintColor;
		}
		[button.titleLabel setFont:_segmentLabelFont];
		[button setTitleColor:titleColorForNormalState forState:UIControlStateNormal];
        
		[button setTitleColor:_segmentNormalTitleTintColor forState:UIControlStateHighlighted];
		[button setTitleColor:_segmentTitleTintColor forState:UIControlStateSelected];
		BOOL isUppercase = _segmentedControlStyle == JRSegmentedControlStyleDarkContent;
		NSString *title = [button titleForState:UIControlStateNormal];
		title = isUppercase ?[title uppercaseString] : title;
		[button setTitle:title forState:UIControlStateNormal];
		CGFloat bottom = _segmentedControlStyle == JRSegmentedControlStyleLightContent ? kJRSegmentedControlLightContentTitleBottomEdgeInset : 0;
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, bottom, 0)];
	}
    
	UIButton *button = _selectedIndex != NSNotFound ?[self controlViews][_selectedIndex] : nil;
	[self updateRibbonConstraintsForButton:button];
    
	BOOL hideBorders = _segmentedControlStyle == JRSegmentedControlStyleDarkContent || _segmentedControlStyle == JRSegmentedControlStyleRoundContent;
	_bottomLine.hidden = _bottomBorder.hidden = hideBorders;
    
	[_bottomBorder setBackgroundColor:_ribbonTintColor];
	[_ribbon setBackgroundColor:_ribbonTintColor];
    
    
    
	if (_segmentedControlStrokeColor) {
		if (!_toolbar) {
			_toolbar = [UIView new];
			[_toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
			[self insertSubview:_toolbar atIndex:0];
			[self addConstraints:JRConstraintsMakeScaleToFill(_toolbar, self)];
		}
	}
    
	[_toolbar.layer setBorderColor:_segmentedControlStrokeColor.CGColor];
	[_toolbar.layer setBorderWidth:_segmentedControlStyle == JRSegmentedControlStyleRoundContent ? 1 : 0];
	[_toolbar.layer setCornerRadius:_segmentedControlStyle == JRSegmentedControlStyleRoundContent ? 5 : 0];
}

- (void)selectSegmentAtIndex:(NSInteger)segmentIndex animated:(BOOL)animated
{
    
	NSArray *controlViews = [self controlViews];
	if ([controlViews count] > segmentIndex) {
		UIButton *button = controlViews[segmentIndex];
		[self segmentedControlButtonAction:button animated:animated shouldNotifyDelegate:NO];
	}
}

- (void)segmentedControlButtonAction:(UIButton *)sender
{
	[self segmentedControlButtonAction:sender animated:YES shouldNotifyDelegate:YES];
}

- (void)segmentedControlButtonAction:(UIButton *)sender animated:(BOOL)animated shouldNotifyDelegate:(BOOL)shouldNotifyDelegate
{
	NSArray *controlViews = [self controlViews];
    
	for (UIButton *button in controlViews) {
		[button setSelected:NO];
		[button setUserInteractionEnabled:YES];
		[UIView addTransitionFadeToView:button duration:_animationDuration * 0.5];
        if (_segmentNormalLabelFont) {
            [button.titleLabel setFont:_segmentNormalLabelFont];
        }
	}
	[sender setSelected:YES];
    
    if (sender.selected == YES) {
        [sender.titleLabel setFont:_segmentLabelFont];
    }
    
	[sender setUserInteractionEnabled:NO];
    
	BOOL firstTimeSelected = _selectedIndex == NSNotFound;
	_selectedIndex = [controlViews indexOfObject:sender];
    
	if ([_delegate respondsToSelector:@selector(segmentedControl:clickedButtonAtIndex:)]
	    && _selectedIndex != NSNotFound &&
	    shouldNotifyDelegate) {
		[_delegate segmentedControl:self clickedButtonAtIndex:_selectedIndex];
	}
    
	NSTimeInterval duration = _animationDuration;
	if (!animated || firstTimeSelected) {
		duration = 0;
	}
	[UIView animateWithDuration:duration delay:kNilOptions
         usingSpringWithDamping:kJRSegmentedControlDefaultSegmentedControlAnimationUsingSpringWithDamping
          initialSpringVelocity:kJRSegmentedControlDefaultSegmentedControlAnimationInitialSpringVelocity
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedOptions animations:^{
                            [self updateRibbonConstraintsForButton:sender];
                            [self layoutIfNeeded];
                        } completion:NULL];
}

#pragma mark - Segmented Control Customizable Properties

- (void)setBottomBorderHeight:(CGFloat)bottomBorderHeight
{
	_bottomBorderHeight = bottomBorderHeight;
	_bottomBorderConstraint.constant = _bottomBorderHeight;
}

- (void)setRibbonHeight:(CGFloat)ribbonHeight
{
	_ribbonHeight = ribbonHeight;
	_ribbonHeightConstraint.constant = _ribbonHeight;
}

- (void)setDeselectedSegmentTextAlpha:(CGFloat)normalSegmentTextAlpha
{
	_deselectedSegmentTextAlpha = normalSegmentTextAlpha;
	[self updateSubviews];
}

- (void)setSegmentedControlStyle:(JRSegmentedControlStyle)segmentedControlStyle
{
	_segmentedControlStyle = segmentedControlStyle;
	[self updateSubviews];
}

- (void)setSegmentLabelFont:(UIFont *)segmentLabelFont
{
	_segmentLabelFont = segmentLabelFont;
	[self updateSubviews];
}

- (void)setRibbonTintColor:(UIColor *)ribbonTintColor
{
	_ribbonTintColor = ribbonTintColor;
	[self updateSubviews];
}

- (void)setSegmentTitleTintColor:(UIColor *)segmentTitleTintColor
{
	_segmentTitleTintColor = segmentTitleTintColor;
	[self updateSubviews];
}

- (void)setSegmentedControlStrokeColor:(UIColor *)segmentedControlStrokeColor
{
	_segmentedControlStrokeColor = segmentedControlStrokeColor;
	[self updateSubviews];
}

- (void)setSegmentStrokeColor:(UIColor *)segmentStrokeColor
{
	_segmentStrokeColor = segmentStrokeColor;
	[self updateSubviews];
}

- (void)setSegmentNormalTitleTintColor:(UIColor *)segmentNormalTitleTintColor
{
	_segmentNormalTitleTintColor = segmentNormalTitleTintColor;
	[self updateSubviews];
}

#pragma mark - Constraints Settings

- (void)didMoveToSuperview
{
	if (self.superview) {
        
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
		[self.superview addConstraint:JRConstraintMake(self, NSLayoutAttributeWidth, NSLayoutRelationEqual, self.superview, NSLayoutAttributeWidth, 1, 0)];
		_segmentedControlHeightConstraint = JRConstraintMake(self, NSLayoutAttributeHeight, NSLayoutRelationEqual, self.superview, NSLayoutAttributeHeight, 1, 0);
		[self.superview addConstraint:_segmentedControlHeightConstraint];
        
		[self.superview addConstraint:JRConstraintMake(self, NSLayoutAttributeTop, NSLayoutRelationEqual, self.superview, NSLayoutAttributeTop, 1, 0)];
		[self.superview addConstraint:JRConstraintMake(self, NSLayoutAttributeLeft, NSLayoutRelationEqual, self.superview, NSLayoutAttributeLeft, 1, 0)];
	}
    
    
}

- (void)addBorders
{
    
	_bottomLine = [UIView new];
	[self addSubview:_bottomLine];
	[_bottomLine setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_bottomLine setBackgroundColor:[JRC BAR_LIGHT_BOTTOM_BORDER]];
    
	_bottomBorder = [UIView new];
	[self addSubview:_bottomBorder];
	[_bottomBorder setTranslatesAutoresizingMaskIntoConstraints:NO];
    
	[self addConstraint:JRConstraintMake(_bottomBorder, NSLayoutAttributeLeft, NSLayoutRelationEqual, self, NSLayoutAttributeLeft, 1, 0)];
	[self addConstraint:JRConstraintMake(_bottomBorder, NSLayoutAttributeBottom, NSLayoutRelationEqual, self, NSLayoutAttributeBottom, 1, 0)];
	[self addConstraint:JRConstraintMake(_bottomBorder, NSLayoutAttributeWidth, NSLayoutRelationEqual, self, NSLayoutAttributeWidth, 1, 0)];
    
	_bottomBorderConstraint = JRConstraintMake(_bottomBorder, NSLayoutAttributeHeight, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, _bottomBorderHeight);
	[self addConstraint:_bottomBorderConstraint];
    
	[self addConstraints:JRConstraintsMakeEqualSize(_bottomLine, _bottomBorder)];
	[self addConstraint:JRConstraintMake(_bottomLine, NSLayoutAttributeCenterX, NSLayoutRelationEqual, _bottomBorder, NSLayoutAttributeCenterX, 1, 0)];
	[self addConstraint:JRConstraintMake(_bottomLine, NSLayoutAttributeTop, NSLayoutRelationEqual, _bottomBorder, NSLayoutAttributeBottom, 1, 0)];
}

- (void)addRibbon
{
	_ribbon = [UIView new];
	[self addSubview:_ribbon];
}

- (void)addControlViews
{
	for (NSString *title in _items) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTintColor:[JRC CLEAR_COLOR]];
        
		[button setTitle:title forState:UIControlStateNormal];
		[button.titleLabel setAdjustsFontSizeToFitWidth:YES];
		[button addTarget:self action:@selector(segmentedControlButtonAction:)
		 forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
	}
}

- (void)setupConstaintsForControlViews
{
	NSArray *controlViews = [self controlViews];
    
	for (UIView *view in controlViews) {
        
		[view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
		NSUInteger previousItemIndex = [controlViews indexOfObject:view] - 1;
		UIView *previousItem = view != [controlViews firstObject] ? controlViews[previousItemIndex] : nil;
        
		NSUInteger nextItemIndex = [controlViews indexOfObject:view] + 1;
		UIView *nextItem = view != [controlViews lastObject] ? controlViews[nextItemIndex] : nil;
        
		UIView *leftToItem = previousItem ? previousItem : self;
		NSLayoutAttribute leftAttribute = previousItem ? NSLayoutAttributeRight : NSLayoutAttributeLeft;
        
		UIView *rightToItem = nextItem ? nextItem : self;
		NSLayoutAttribute rightAttribute = nextItem ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
        
		UIView *widthToItem = self;
        
		if (previousItem) {
			widthToItem = previousItem;
		} else if (nextItem) {
			widthToItem = nextItem;
		}
        
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeHeight, NSLayoutRelationEqual, self, NSLayoutAttributeHeight, 1, 0)];
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeTop, NSLayoutRelationEqual, self, NSLayoutAttributeTop, 1, 0)];
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeLeft, NSLayoutRelationEqual, leftToItem, leftAttribute, 1, 0)];
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeRight, NSLayoutRelationEqual, rightToItem, rightAttribute, 1, 0)];
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeWidth, NSLayoutRelationEqual, widthToItem, NSLayoutAttributeWidth, 1, 0)];
	}
}

- (void)createViewsAndSetupConstraintsForBottomBorder
{
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
	[self addRibbon];
    
	[self addBorders];
    
	[self addControlViews];
    
	[self setupConstaintsForControlViews];
    
}

- (void)updateRibbonConstraintsForButton:(UIButton *)button
{
    
	[_ribbon setTranslatesAutoresizingMaskIntoConstraints:NO];
    
	[self removeConstraint:_ribbonHeightConstraint];
	[self removeConstraint:_ribbonWidthConstraint];
	[self removeConstraint:_ribbonBottomConstraint];
	[self removeConstraint:_ribbonLeftConstraint];
    
	UIView *toItemView = self;
	CGFloat bottonConstant =  -kJRSegmentedControlDefaultTopBorderHeight;
	if (button && _segmentedControlStyle == JRSegmentedControlStyleLightContent) {
		toItemView = button;
	} else if (button && _segmentedControlStyle == JRSegmentedControlStyleDarkContent) {
		bottonConstant = 2;
		toItemView = button.titleLabel;
	} else if (button && _segmentedControlStyle == JRSegmentedControlStyleRoundContent) {
        bottonConstant = 0;
		toItemView = button;
	}
    
	CGFloat heightConstant = _ribbonHeight;
	CGFloat widthMultiplier = button ? 1 : 0;
    
	if (_segmentedControlStyle != JRSegmentedControlStyleRoundContent) {
		_ribbonHeightConstraint = JRConstraintMake(_ribbon, NSLayoutAttributeHeight, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, heightConstant);
		_ribbonWidthConstraint = JRConstraintMake(_ribbon, NSLayoutAttributeWidth, NSLayoutRelationEqual, toItemView, NSLayoutAttributeWidth, widthMultiplier, 0);
	} else {
		_ribbonHeightConstraint = JRConstraintMake(_ribbon, NSLayoutAttributeHeight, NSLayoutRelationEqual, toItemView, NSLayoutAttributeHeight, 1, 0);
		_ribbonWidthConstraint = JRConstraintMake(_ribbon, NSLayoutAttributeWidth, NSLayoutRelationEqual, toItemView, NSLayoutAttributeWidth, 1, 0);
	}
    
	[_ribbon.layer setCornerRadius:_toolbar.layer.cornerRadius];
	[_ribbon.layer setBorderWidth:_toolbar.layer.borderWidth];
    
	[_ribbon.layer setBorderColor:_segmentStrokeColor.CGColor];
    
	_ribbonBottomConstraint = JRConstraintMake(_ribbon, NSLayoutAttributeBottom, NSLayoutRelationEqual, toItemView, NSLayoutAttributeBottom, 1, bottonConstant);
	_ribbonLeftConstraint = JRConstraintMake(_ribbon, NSLayoutAttributeLeft, NSLayoutRelationEqual, toItemView, NSLayoutAttributeLeft, 1, 0);
    
	[self addConstraint:_ribbonHeightConstraint];
	[self addConstraint:_ribbonWidthConstraint];
	[self addConstraint:_ribbonBottomConstraint];
	[self addConstraint:_ribbonLeftConstraint];
    
}

#pragma mark - Helpers

- (NSArray *)controlViews
{
	NSIndexSet *buttonsIndexes = [self.subviews indexesOfObjectsPassingTest: ^BOOL (UIView *subview, NSUInteger idx, BOOL *stop) {
        return [subview isKindOfClass:[UIButton class]];
    }];
	return [self.subviews objectsAtIndexes:buttonsIndexes];
}

@end
