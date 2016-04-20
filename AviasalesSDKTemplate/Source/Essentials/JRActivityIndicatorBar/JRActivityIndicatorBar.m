//
//  JRActivityIndicatorBar.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRActivityIndicatorBar.h"
#import "JRC.h"
#import "NSLayoutConstraint+JRConstraintMake.h"
#import "UIView+JRFadeAnimation.h"

#define kJRActivityIndicatorBarMinDotHeightFactor   0.35
#define kJRActivityIndicatorBarMaxDotHeightFactor   0.9

#define kJRActivityIndicatorBarStepFactor           1.25
#define kJRActivityIndicatorDefaultSpeed            0.35
#define kJRActivityIndicatorRiseApha                1
#define kJRActivityIndicatorFallApha                0.5
#define kJRActivityIndicatorDurationDivider         6

@implementation JRActivityIndicatorBar {
	NSMutableArray *_heighConstaints;
	CGFloat _maxDotHeight;
	CGFloat _minDotHeight;
	CGFloat _step;
}

@synthesize startAnimation = _startAnimation;
@synthesize prepareForSuperview = _prepareForSuperview;

- (void)setPrepareForSuperview:(BOOL)prepareForSuperview {
    if (prepareForSuperview == YES && _prepareForSuperview == NO) {
        [self updateViews];
        _prepareForSuperview = YES;
        _stopAnimation = NO;
        _startAnimation = NO;
    } else if (prepareForSuperview == NO) {
        _prepareForSuperview = NO;
        _heighConstaints = nil;
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (void)setStopAnimation:(BOOL)stopAnimation {
    if (stopAnimation == YES && _startAnimation == YES) {
        
        _startAnimation = NO;
        _stopAnimation = YES;
        
    } else if (stopAnimation == NO) {
        [self setStartAnimation:YES];
    }
}

- (void)setStartAnimation:(BOOL)startAnimation {
    
    if (startAnimation == YES && _prepareForSuperview == NO) {
        
        [self setPrepareForSuperview:YES];
    
    }
    
    if (startAnimation == YES && _startAnimation == NO) {
        _startAnimation = YES;
        
        __weak JRActivityIndicatorBar *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           
            __weak NSArray *constrains = _heighConstaints;
            NSLayoutConstraint *firstConstraint = constrains.firstObject;
            [weakSelf animateConstraint:firstConstraint inConstrainsArray:constrains];
                           
        });
    }
    if (startAnimation == NO) {
        [self setStopAnimation:YES];
    }
}

- (NSInteger)numberOfDots
{
    
	_maxDotHeight = self.frame.size.height * kJRActivityIndicatorBarMaxDotHeightFactor;
	_minDotHeight = self.frame.size.height * kJRActivityIndicatorBarMinDotHeightFactor;
    
	_step = _maxDotHeight * kJRActivityIndicatorBarStepFactor;
    
	CGFloat maxPosition = self.frame.size.width - _minDotHeight;
    
	NSInteger numberOfDots = 0;
    
	if (_maxDotHeight != _minDotHeight) {
        for (CGFloat currentPosition = 0;
             currentPosition <= maxPosition;
             currentPosition = currentPosition + _step) {
            numberOfDots++;
        }
    }
	return numberOfDots;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    [self.subviews makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:_indicatorColor];
}

- (void)updateViews
{
    
	_heighConstaints = nil;
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
	if (!_indicatorColor) {
		_indicatorColor = [JRC WHITE_COLOR];
	}
    
	_heighConstaints = [NSMutableArray new];
    
	NSInteger numberOfDots = [self numberOfDots];
    
	CGFloat startingOffset = (self.frame.size.width - numberOfDots * _step) / 2;
    
	for (NSInteger dotNumber = 0; dotNumber <= numberOfDots; dotNumber++) {
        
		UIView *view = [UIView new];
		[view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
		[self addSubview:view];
        
		NSLayoutConstraint *heightConstraint = JRConstraintMake(view, NSLayoutAttributeHeight, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, _minDotHeight);
		[self addConstraint:heightConstraint];
        
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeCenterY, NSLayoutRelationEqual, self, NSLayoutAttributeCenterY, 1, 0)];
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeWidth, NSLayoutRelationEqual, view, NSLayoutAttributeHeight, 1, 0)];
		[self addConstraint:JRConstraintMake(view, NSLayoutAttributeCenterX, NSLayoutRelationEqual, self, NSLayoutAttributeLeft, 1, startingOffset + dotNumber * _step)];
        
		[self setupItem:view
                  alpha:kJRActivityIndicatorFallApha duration:kNilOptions
               constant:_minDotHeight
             constraint:heightConstraint];
        
		[_heighConstaints addObject:heightConstraint];
	}
    
	[self setNeedsLayout];
	[self layoutIfNeeded];
}

- (void)animateConstraint:(__weak NSLayoutConstraint *)constraint
        inConstrainsArray:(__weak NSArray *)constrains
{
    
    
	if (!constraint || !constrains) {
		return;
	}
    
	NSTimeInterval duration = kJRActivityIndicatorDefaultSpeed;
    
	UIViewAnimationOptions options = (UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionCurveLinear);
    
    __weak JRActivityIndicatorBar *weakSelf = self;
    
	[UIView animateWithDuration:duration
                          delay:kNilOptions
                        options:options
                     animations:_stopAnimation == YES ? NULL : ^{
                         if (weakSelf != nil) {
                             [weakSelf setupItem:constraint.firstItem
                                           alpha:kJRActivityIndicatorRiseApha
                                        duration:duration
                                        constant:_maxDotHeight
                                      constraint:constraint];
                         }
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:duration
                                               delay:kNilOptions
                                             options:options
                                          animations:^{
                                              if (weakSelf != nil) {
                                                  [weakSelf setupItem:constraint.firstItem
                                                                alpha:kJRActivityIndicatorFallApha
                                                             duration:duration
                                                             constant:_minDotHeight
                                                           constraint:constraint];
                                              }
                                          } completion:NULL];
                     }];
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration/kJRActivityIndicatorDurationDivider * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLayoutConstraint *nextConstraint = nil;
        
        NSInteger currentConstraintIndex = [constrains indexOfObject:constraint];
        
        if (currentConstraintIndex != NSNotFound) {
            
            NSInteger nextConstaintIndex = currentConstraintIndex + 1;
            
            if (constrains.count > nextConstaintIndex) {
                nextConstraint = constrains[nextConstaintIndex];
            } else {
                nextConstraint = [constrains firstObject];
            }
            
        }
        
        [weakSelf animateConstraint:nextConstraint
              inConstrainsArray:constrains];
    });
}


- (void)setupItem:(__weak UIView *)item
            alpha:(CGFloat)alpha
         duration:(NSTimeInterval)duration
         constant:(CGFloat)constant
       constraint:(__weak NSLayoutConstraint *)constraint
{
    
	[item setAlpha:alpha];
	[item setBackgroundColor:_indicatorColor];
    
	CGFloat cornerRadius = constant / 2;
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.fromValue = @(item.layer.cornerRadius);
	animation.toValue = @(cornerRadius);
	animation.duration = duration;
    
	[item.layer addAnimation:animation forKey:@"cornerRadius"];
	[item.layer setCornerRadius:cornerRadius];
    
	if (constraint != nil) {
        constraint.constant = constant;
    }
    
	[self layoutIfNeeded];
}

@end
