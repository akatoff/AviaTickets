//
//  JRFPPopoverController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFPPopoverController.h"
#import "JRC.h"
#import "FPPopoverView+DrawRect.h"
#import "FPPopoverView+DrawRect.h"

#define kJRFPPopoverControllerDefaultOpacity        0.8f
#define kJRFPPopoverControllerDefaultShadowRadius   6
#define kJRFPPopoverControllerDefaultInterations    2
#define kJRFPPopoverControllerDefaultBlurRadus      20
#define kJRFPPopoverControllerDefaultUpdateInterval 1/36

@interface FPPopoverController ()
- (void)setupView;
- (void)deviceOrientationDidChange:(NSNotification*)notification;
@end

@implementation JRFPPopoverController {
    UIView *_tintView;
}

- (id)initWithViewController:(UIViewController*)viewController
				   delegate:(id<FPPopoverControllerDelegate>)delegate
              underlyingView:(UIView *)underlyingView {
    self = [super initWithViewController:viewController delegate:delegate];
    if (self) {
        
        self.border = NO;
        self.tint = FPPopoverWhiteTint;
        self.contentView.draw3dBorder = NO;
        
        
        self.contentView.layer.shadowRadius = kJRFPPopoverControllerDefaultShadowRadius;
        self.contentView.layer.shadowOffset = CGSizeZero;
        self.contentView.layer.masksToBounds = NO;
        
        [self setUnderlyingView:underlyingView];
        
        __weak JRFPPopoverController *weakSelf = self;
        [self.touchView setTouchedOutsideBlock:^{
            [weakSelf dismissPopoverAnimated:YES];
        }];
        [viewController.view setBackgroundColor:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_accessibilityIsNoModal) {
        self.view.accessibilityViewIsModal = YES;
    }
}

- (void)setAccessibilityIsNoModal:(BOOL)accessibilityIsNoModal
{
    _accessibilityIsNoModal = accessibilityIsNoModal;
    self.view.accessibilityViewIsModal = !_accessibilityIsNoModal;
}

- (void)setUnderlyingView:(UIView *)underlyingView {
    if (underlyingView) {
        [self.blurView setUnderlyingView:underlyingView];
    }
    self.contentView.layer.shadowOpacity = underlyingView == nil ? kJRFPPopoverControllerDefaultOpacity : 0;
}

- (FXBlurView *)blurView {
    if (!_blurView) {
        
        UIViewAutoresizing mask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        _blurView = [[FXBlurView alloc] initWithFrame:self.contentView.frame];
        [_blurView setIterations:kJRFPPopoverControllerDefaultInterations];
        [_blurView setBlurRadius:kJRFPPopoverControllerDefaultBlurRadus];
        [_blurView setUpdateInterval:kJRFPPopoverControllerDefaultUpdateInterval];
        [_blurView setDynamic:NO];
        [_blurView setAutoresizingMask:mask];
        
        _tintView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [_tintView setAutoresizingMask:mask];
        
        [self.contentView insertSubview:_blurView atIndex:0];
        [self.contentView insertSubview:_tintView aboveSubview:_blurView];
        
    }
    return _blurView;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self.blurView setDynamic:NO];
    [self.blurView setBlurEnabled:NO];
    [self setBlurTintColor:backgroundColor];
}

- (void)presentPopoverFromPoint:(CGPoint)fromPoint {
    [super presentPopoverFromPoint:fromPoint];
    [self updateMask];
    [_blurView updateAsynchronously:NO completion:NULL];
    [_blurView setDynamic:YES];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [[[window subviews] lastObject] addSubview:self.view];

    if (UIAccessibilityIsVoiceOverRunning()) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.view);
    }
}

- (void)presentPopoverFromPoint:(CGPoint)fromPoint inView:(UIView *)view
{
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    UIView *parentView = [[window subviews] firstObject];
    fromPoint = [view convertPoint:fromPoint toView:parentView];
    
    [self presentPopoverFromPoint:fromPoint];
}

-(void)dismissPopoverAnimated:(BOOL)animated completion:(FPPopoverCompletion)completionBlock
{
    [super dismissPopoverAnimated:animated completion:completionBlock];
}


- (void)updateMask {
    
    UIBezierPath *bezierPath = [self.contentView newBezierPathPathWithBorderWidth:kNilOptions arrowDirection:self.contentView.arrowDirection];
    CAShapeLayer *blurViewMask = [CAShapeLayer layer];
    [blurViewMask setPath:bezierPath.CGPath];
    _blurView.layer.mask = blurViewMask;
    
    CAShapeLayer *tintViewMask = [CAShapeLayer layer];
    [tintViewMask setPath:bezierPath.CGPath];
    _tintView.layer.mask = tintViewMask;;
}


- (void)setBlurTintColor:(UIColor *)blurTintColor {
    _blurTintColor = blurTintColor;
    [_tintView setBackgroundColor:_blurTintColor];
}

- (void)setContentSize:(CGSize)contentSize
{
    if (self.arrowDirection == FPPopoverArrowDirectionUp || self.arrowDirection == FPPopoverNoArrow || self.arrowDirection == FPPopoverArrowDirectionDown) {
        [super setContentSize:CGSizeMake(contentSize.width + JRFPPopoverWidthDiffForVerticalArrow, contentSize.height + JRFPPopoverHeightDiffForVerticalArrow)];
    } else {
        [super setContentSize:contentSize];
    }
}

- (void)setHideOnTouch:(BOOL)hideOnTouch
{
    _hideOnTouch = hideOnTouch;
    
    if (_hideOnTouch) {
        [self.touchView setTouchedInsideBlock:^{
            [self dismissPopoverAnimated:YES];
        }];
    } else {
        [self.touchView setTouchedInsideBlock:nil];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self setupView];
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    if (self.hideOnRotate) {
        [self dismissPopoverAnimated:YES];
    }
}

- (void)setupView
{
    if (!self.view.window) {
        return;
    }
    [super setupView];
}

@end
