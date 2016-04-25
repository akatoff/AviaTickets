//
//  JRSimplePopoverBackgroundView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSimplePopoverBackgroundView.h"
#import "JRC.h"
#import "UIImage+JRUIImage.h"
#define JR_SIMPLE_POPOVER_CORNER_RADIUS 10.f
#define JR_SIMPLE_POPOVER_CONTENT_INSET 6.f
#define JR_SIMPLE_POPOVER_FROM_POINT_MARGIN 10.f

@interface JRSimplePopoverBackgroundView ()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation JRSimplePopoverBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowColor = [[UIColor clearColor] CGColor];
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [UIView new];
        [_backgroundView setBackgroundColor:[JRC COMMON_POPUP_BACKGROUND_COLOR]];
        [_backgroundView setClipsToBounds:YES];
        [self addSubview:_backgroundView];
        _backgroundView.layer.cornerRadius = [[self class] cornerRadius];

        
        _arrowView = [[UIImageView alloc] initWithImage:[[self class] arrowImage]];
        [self addSubview:_arrowView];
    }
    return self;
}

+ (UIImage *)arrowImage
{
    return [[UIImage imageNamed:@"JRSimpleAnnotationArrow"] imageTintedWithColor:[JRC COMMON_POPUP_BACKGROUND_COLOR]];
}

+ (CGFloat)cornerRadius
{
    return JR_SIMPLE_POPOVER_CORNER_RADIUS;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(JR_SIMPLE_POPOVER_CONTENT_INSET, JR_SIMPLE_POPOVER_CONTENT_INSET, JR_SIMPLE_POPOVER_CONTENT_INSET, JR_SIMPLE_POPOVER_CONTENT_INSET);
}

+ (CGFloat)arrowHeight
{
    return [[self class] arrowImage].size.height + JR_SIMPLE_POPOVER_FROM_POINT_MARGIN;
}

+ (CGFloat)arrowBase
{
    return [[self class] arrowImage].size.width;
}

@synthesize arrowDirection = _arrowDirection;
@synthesize arrowOffset = _arrowOffset;

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

- (CGFloat)realArrowHeight
{
    return [[self class] arrowImage].size.height;
}

- (void)layoutSubviews
{
    _backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect backgroundRect = _backgroundView.frame;
    CGRect arrowRect = _arrowView.frame;
    
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionLeft:
            backgroundRect.size.width -= [[self class] arrowHeight];
            backgroundRect.origin.x += [[self class] arrowHeight];
            
            _arrowView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            arrowRect = CGRectMake(JR_SIMPLE_POPOVER_FROM_POINT_MARGIN, round(self.frame.size.height/2 - _arrowView.frame.size.height/2) + _arrowOffset, [self realArrowHeight], [[self class] arrowBase]);
            
            if (_arrowOffset > 0) {
                arrowRect.origin.y = fminf(backgroundRect.size.height - arrowRect.size.height - [[self class] cornerRadius], arrowRect.origin.y);
            } else {
                arrowRect.origin.y = fmaxf([[self class] cornerRadius], arrowRect.origin.y);
            }
            
            break;
            
        case UIPopoverArrowDirectionRight:
            backgroundRect.size.width -= [[self class] arrowHeight];
            
            _arrowView.transform = CGAffineTransformMakeRotation(M_PI_2);
            arrowRect = CGRectMake(self.frame.size.width - [[self class] arrowHeight], round(self.frame.size.height/2 - _arrowView.frame.size.height/2) + _arrowOffset, [self realArrowHeight], [[self class] arrowBase]);
            
            if (_arrowOffset > 0) {
                arrowRect.origin.y = fminf(backgroundRect.size.height - arrowRect.size.height - [[self class] cornerRadius], arrowRect.origin.y);
            } else {
                arrowRect.origin.y = fmaxf([[self class] cornerRadius], arrowRect.origin.y);
            }
            
            break;
            
        case UIPopoverArrowDirectionUp:
            backgroundRect.size.height -= [[self class] arrowHeight];
            backgroundRect.origin.y += [[self class] arrowHeight];
            
            arrowRect = CGRectMake(round(self.frame.size.width/2 - _arrowView.frame.size.width/2) + _arrowOffset, JR_SIMPLE_POPOVER_FROM_POINT_MARGIN, [[self class] arrowBase], [self realArrowHeight]);
            
            if (_arrowOffset > 0) {
                arrowRect.origin.x = fminf(backgroundRect.size.width - arrowRect.size.width - [[self class] cornerRadius], arrowRect.origin.x);
            } else {
                arrowRect.origin.x = fmaxf([[self class] cornerRadius], arrowRect.origin.x);
            }
            
            break;
            
        case UIPopoverArrowDirectionDown:
            backgroundRect.size.height -= [[self class] arrowHeight];
            
            _arrowView.transform = CGAffineTransformMakeScale(1, -1);
            arrowRect = CGRectMake(round(self.frame.size.width/2 - _arrowView.frame.size.width/2) + _arrowOffset, self.frame.size.height - [self realArrowHeight] - JR_SIMPLE_POPOVER_FROM_POINT_MARGIN, [[self class] arrowBase], [self realArrowHeight]);
            
            if (_arrowOffset > 0) {
                arrowRect.origin.x = fminf(backgroundRect.size.width - arrowRect.size.width - [[self class] cornerRadius], arrowRect.origin.x);
            } else {
                arrowRect.origin.x = fmaxf([[self class] cornerRadius], arrowRect.origin.x);
            }
            
        default:
            break;
    }
    
    _arrowView.frame = arrowRect;
    _backgroundView.frame = backgroundRect;
    
}

@end
