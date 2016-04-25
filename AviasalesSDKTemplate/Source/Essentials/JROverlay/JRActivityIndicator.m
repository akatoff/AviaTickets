//
//  JRActivityIndicator.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRActivityIndicator.h"
#import "JRC.h"
#import "JRActivityIndicatorBar.h"
#import "JROverlayView.h"

#define kIndicatorViewDefaultWidth 260.f
#define kContentHPadding 35.f
#define kContentVPadding 17.f
#define kShowDelayDefault 0.3
#define kHideDelayDefault 0.5

static NSMutableDictionary *visibleIndicatorsInView;
//{
//    viewKey:
//    {
//        typeKey: count
//    }
//}

@interface JRActivityIndicator ()
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong) JROverlayView *overlayView;
@property (nonatomic, strong) UIView *indicatorInnerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) JRActivityIndicatorBar *activityIndicatorBarView;
@property (nonatomic, readonly) BOOL visible;
@end

@implementation JRActivityIndicator

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:self.indicatorInnerView];
    [self.indicatorInnerView addSubview:self.titleLabel];
    [self.indicatorInnerView addSubview:self.activityIndicatorBarView];
    
    [self.titleLabel setText:_title];
    
    self.alpha = 0.f;
    
    [self layoutViews];
}

- (void)layoutViews
{
    CGRect indicatorInnerViewFrame = CGRectMake(0, 0, kIndicatorViewDefaultWidth, 0);
    
    [self.titleLabel setFrame:CGRectMake(kContentHPadding, kContentVPadding, indicatorInnerViewFrame.size.width - kContentHPadding*2, 0)];
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(kContentHPadding, kContentVPadding, indicatorInnerViewFrame.size.width - kContentHPadding*2, self.titleLabel.frame.size.height)];
    
    [self.activityIndicatorBarView setFrame:CGRectMake(kContentHPadding, CGRectGetMaxY(self.titleLabel.frame) + kContentVPadding, indicatorInnerViewFrame.size.width - kContentHPadding*2, 9)];
    
    indicatorInnerViewFrame.size.height = CGRectGetMaxY(self.activityIndicatorBarView.frame) + kContentVPadding;
    
    [self.indicatorInnerView setFrame:indicatorInnerViewFrame];
    [self setFrame:indicatorInnerViewFrame];
    
    //shadow
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.8f;
    self.layer.shadowRadius = 6.f;
    self.layer.shadowOffset = CGSizeMake(0, 2.f);
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.indicatorInnerView.bounds] CGPath];
    
    [self.activityIndicatorBarView setPrepareForSuperview:YES];
    
    [self setFrame:CGRectMake(round(self.containerView.frame.size.width/2 - self.frame.size.width/2), round(self.containerView.frame.size.height/2 - self.frame.size.height/2), self.frame.size.width, self.frame.size.height)];
}

- (void)show
{
    if (!self.title) {
        self.title = NSLS(@"ACTIVITY_INDICATOR_DEFAULT_TITLE");
    }
    
    [self layoutViews];
    
    [self.containerView addSubview:self];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(finishShowing) withObject:nil afterDelay:kShowDelayDefault];
    
    [JRActivityIndicator increaseCountForIndicatorsInView:self.containerView withTitle:self.title];
}

- (void)finishShowing
{
    self.overlayView = [JROverlayView showInView:self.containerView];
    self.overlayView.backgroundColor = [UIColor clearColor];
    
    [self.containerView insertSubview:self aboveSubview:self.overlayView];
    
    [self.activityIndicatorBarView setStartAnimation:YES];
    
    [self.containerView bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        
    }];
    
    _visible = YES;
}

- (void)hide
{
    if ([JRActivityIndicator indicatorsCountInView:self.containerView withTitle:self.title] > 1) {
        [JRActivityIndicator decreaseCountForIndicatorsInView:self.containerView withTitle:self.title];
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.visible) {
        [self performSelector:@selector(finishHiding) withObject:nil afterDelay:kHideDelayDefault];
    } else {
        [self finishHiding];
    }
}

- (void)finishHiding
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.overlayView hide];
    }];

    [self.activityIndicatorBarView setStopAnimation:YES];
    
    [self removeFromSuperview];
    [self.overlayView removeFromSuperview];
    
    _visible = NO;
    
    [JRActivityIndicator decreaseCountForIndicatorsInView:self.containerView withTitle:self.title];
}

- (void)dealloc
{
    [self.activityIndicatorBarView setStopAnimation:YES];
    
    if (self.visible) {
        [JRActivityIndicator decreaseCountForIndicatorsInView:self.containerView withTitle:self.title];
    }
}

#pragma mark getters and setters

- (UIView *)indicatorInnerView
{
    if (!_indicatorInnerView) {
        _indicatorInnerView = [UIView new];
        _indicatorInnerView.backgroundColor = [UIColor whiteColor];
        _indicatorInnerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _indicatorInnerView.layer.cornerRadius = 10.f;
        _indicatorInnerView.layer.masksToBounds = YES;
    }
    return _indicatorInnerView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:15.f];
        _titleLabel.textColor = [JRC COMMON_TEXT];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UIView *)containerView
{
    if (!_containerView) {
        UIApplication *application = [UIApplication sharedApplication];
        UIWindow *window = [application keyWindow];
        if (!window) {
            window = [[application windows] firstObject];
            [window makeKeyAndVisible];
        }
        
        return [[window subviews] firstObject];
    }
    return _containerView;
}

- (JRActivityIndicatorBar *)activityIndicatorBarView
{
    if (!_activityIndicatorBarView) {
        _activityIndicatorBarView = [[JRActivityIndicatorBar alloc] init];
        _activityIndicatorBarView.indicatorColor = [JRC SECOND_THEME_COLOR];
    }
    return _activityIndicatorBarView;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [self.titleLabel setText:_title];
    [self.titleLabel setAccessibilityLabelWithNSLSKey:nil andText:_title];
    
    if (_visible) {
        [self layoutViews];
    }
}

#pragma mark manager

+ (JRActivityIndicator *)showInView:(UIView *)view withTitle:(NSString *)title
{
    if ([self indicatorsCountInView:view withTitle:title] > 0) {
        JRActivityIndicator *existIndicator = [self indicatorInView:view withTitle:title];
        if (existIndicator) {
            [self increaseCountForIndicatorsInView:view withTitle:title];
            return existIndicator;
        } else {
            [self resetCountForIndicatorsInView:view withTitle:title];
        }
    }
    
    JRActivityIndicator *indicator = [[JRActivityIndicator alloc] init];
    indicator.containerView = view;
    indicator.title = title;
    [indicator show];
    
    return indicator;
}

+ (void)hideAllFromView:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[JRActivityIndicator class]]) {
            NSUInteger count = [self indicatorsCountInView:view withTitle:[(JRActivityIndicator *)subview title]];
            for (int i = 0; i < count; i++) {
                [(JRActivityIndicator *)subview hide];
            }
        }
    }
}

#pragma mark indicators stack

+ (id<NSCopying>)viewKeyForView:(UIView *)view
{
    return [NSValue valueWithNonretainedObject:view];
}

- (id<NSCopying>)viewKey
{
    return [JRActivityIndicator viewKeyForView:self.containerView];
}

+ (id<NSCopying>)typeKeyForTitle:(NSString *)title
{
    return @([title hash]);
}

- (id<NSCopying>)typeKey
{
    return [JRActivityIndicator typeKeyForTitle:self.title];
}

+ (void)increaseCountForIndicatorsInView:(UIView *)view withTitle:(NSString *)title
{
    if (visibleIndicatorsInView == nil) {
        visibleIndicatorsInView = [NSMutableDictionary dictionary];
    }
    if (visibleIndicatorsInView[[self viewKeyForView:view]] == nil) {
        visibleIndicatorsInView[[self viewKeyForView:view]] = [NSMutableDictionary dictionary];
    }
    if (visibleIndicatorsInView[[self viewKeyForView:view]][[self typeKeyForTitle:title]] == nil) {
        visibleIndicatorsInView[[self viewKeyForView:view]][[self typeKeyForTitle:title]] = @(0);
    }
    
    visibleIndicatorsInView[[self viewKeyForView:view]][[self typeKeyForTitle:title]] = @([self indicatorsCountInView:view withTitle:title] + 1);
}

+ (void)decreaseCountForIndicatorsInView:(UIView *)view withTitle:(NSString *)title
{
    if ([self indicatorsCountInView:view withTitle:title] > 0) {
        visibleIndicatorsInView[[self viewKeyForView:view]][[self typeKeyForTitle:title]] = @([self indicatorsCountInView:view withTitle:title] - 1);
    }
}

+ (void)resetCountForIndicatorsInView:(UIView *)view withTitle:(NSString *)title
{
    if (visibleIndicatorsInView[[self viewKeyForView:view]]) {
        visibleIndicatorsInView[[self viewKeyForView:view]][[self typeKeyForTitle:title]] = @(0);
    }
}

+ (NSUInteger)indicatorsCountInView:(UIView *)view withTitle:(NSString *)title
{
    NSNumber *indicatorsCount = visibleIndicatorsInView[[self viewKeyForView:view]][[self typeKeyForTitle:title]];
    return [indicatorsCount integerValue];
}

- (NSUInteger)indicatorsCount
{
    return [JRActivityIndicator indicatorsCountInView:self.containerView withTitle:self.title];
}

+ (JRActivityIndicator *)indicatorInView:(UIView *)view withTitle:(NSString *)title
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[JRActivityIndicator class]] && [[(JRActivityIndicator *)subview title] isEqualToString:title]) {
            return (JRActivityIndicator *)subview;
        }
    }
    return nil;
}

@end
