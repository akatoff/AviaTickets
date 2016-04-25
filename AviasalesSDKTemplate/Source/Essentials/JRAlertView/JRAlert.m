//
//  JRAlertView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRAlert.h"
#import "JRC.h"
#import "JROverlayView.h"
#import "UIWindow+TopMostViewController.h"

typedef void (^JRAlertButtonAction)(void);

#define kAlertViewDefaultWidth 260.f
#define kContentHPadding 35.f
#define kContentVPadding 17.f
#define kButtonHeight 45.f
#define kButtonSeparatorVMargin 10.f
#define kDefaultImageName @"JRAlertCat"
#define kHBorderHMargin 10.f
#define kBackgroundColor [UIColor whiteColor]
#define kButtonColor [UIColor whiteColor]
#define kButtonHPadding 10.f

static NSMutableArray *visibleAlertsTags;

@interface JRAlert ()
@property (nonatomic, strong) UIWindow *prevKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIView *alertInnerView;
@property (nonatomic, strong) JROverlayView *overlayView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) NSArray *buttonsActions;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *borderView;

@property (nonatomic) BOOL isDismissing;
@property (nonatomic) BOOL isNeedShow;
@end

@implementation JRAlert

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self) {
        _message = message;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    if (!self.image) {
        self.image = [UIImage imageNamed:kDefaultImageName];
        _showedImage = YES;
    }
    
    [self.alertView addSubview:self.alertInnerView];
    [self.alertInnerView addSubview:self.contentView];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.borderView];
    
    [self.messageLabel setText:_message];
    
    self.alertView.alpha = 0.f;
    
    [self layoutViews];
}

- (void)addButtonWithTitle:(NSString *)title andBlock:(void (^)(void))actionBlock bold:(BOOL)bold
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.alertInnerView addSubview:button];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = kButtonColor;
    [button setTitleColor:[JRC ALERT_BUTTON] forState:UIControlStateNormal];
    button.titleLabel.font = bold ? [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.f] : [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.f];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 0.5;
    button.titleEdgeInsets = UIEdgeInsetsMake(0, kButtonHPadding, 0, kButtonHPadding);
    
    NSMutableArray *buttons = [self.buttons mutableCopy];
    [buttons addObject:button];
    [self removeTag];
    self.buttons = [NSArray arrayWithArray:buttons];
    [self saveTag];
    
    NSMutableArray *buttonsActions = [self.buttonsActions mutableCopy];
    if (actionBlock) {
        [buttonsActions addObject:actionBlock];
    } else {
        [buttonsActions addObject:[NSNull null]];
    }
    self.buttonsActions = [NSArray arrayWithArray:buttonsActions];
    
    if (_visible) {
        [self layoutViews];
    }
}

- (void)addButtonWithTitle:(NSString *)title andBlock:(void (^)(void))actionBlock
{
    [self addButtonWithTitle:title andBlock:actionBlock bold:NO];
}

- (void)layoutViews
{
        CGFloat borderHeight = JRPixel();
        
        CGRect alertInnerViewFrame = CGRectMake(0, 0, kAlertViewDefaultWidth, 0);
        CGRect contentViewFrame = alertInnerViewFrame;
        
        //image
        CGFloat imageMaxY = 5.f;
        [self.imageView setImage:self.image];
        [self.imageView setFrame:CGRectMake(round(contentViewFrame.size.width/2 - self.image.size.width/2), kContentVPadding, self.image.size.width, self.image.size.height)];
        if (self.image) {
            imageMaxY = CGRectGetMaxY(self.imageView.frame);
        }
        
        //message
        [self.messageLabel setFrame:CGRectMake(kContentHPadding, imageMaxY + kContentVPadding, contentViewFrame.size.width - kContentHPadding*2, 0)];
        [self.messageLabel sizeToFit];
        [self.messageLabel setFrame:CGRectMake(kContentHPadding, imageMaxY + kContentVPadding, contentViewFrame.size.width - kContentHPadding*2, self.messageLabel.frame.size.height)];
        
        contentViewFrame.size.height = CGRectGetMaxY(self.messageLabel.frame) + kContentVPadding;
        alertInnerViewFrame.size.height = contentViewFrame.size.height + kButtonHeight;
        
        [self.contentView setFrame:contentViewFrame];
        [self.alertInnerView setFrame:alertInnerViewFrame];
        
        //button
        CGFloat buttonWidth = self.alertInnerView.frame.size.width / [self.buttons count];
        for (UIButton *button in self.buttons) {
            NSUInteger buttonIndex = [self.buttons indexOfObject:button];
            [button setFrame:CGRectMake(buttonWidth * buttonIndex, CGRectGetMaxY(self.contentView.frame), buttonWidth - (buttonIndex < [self.buttons count] - 1 ? borderHeight : 0), kButtonHeight)];
            
            if (buttonIndex < [self.buttons count] - 1) {
                UIView *buttonSeparator = [UIView new];
                [_alertInnerView addSubview:buttonSeparator];
                [buttonSeparator setFrame:CGRectMake(CGRectGetMaxX(button.frame), CGRectGetMinY(button.frame) + kButtonSeparatorVMargin, borderHeight, kButtonHeight - kButtonSeparatorVMargin*2)];
                buttonSeparator.backgroundColor = [JRC ALERT_BORDER];
            }
        }
        
        //borders
        [self.borderView setFrame:CGRectMake(kHBorderHMargin, _contentView.frame.size.height - borderHeight, _contentView.frame.size.width - kHBorderHMargin*2, borderHeight)];
        
        self.alertView.frame = self.alertInnerView.frame;
        
        //shadow
        self.alertView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.alertView.layer.shadowOpacity = 0.5f;
        self.alertView.layer.shadowRadius = 6.f;
        self.alertView.layer.shadowOffset = CGSizeMake(0, 2.f);
        self.alertView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.alertInnerView.bounds] CGPath];
        
        [self.alertView setFrame:CGRectMake(round(self.containerView.frame.size.width/2 - self.alertView.frame.size.width/2), round(self.containerView.frame.size.height/2 - self.alertView.frame.size.height/2), self.alertView.frame.size.width, self.alertView.frame.size.height)];
}

- (void)show
{
    if (_isDismissing) {
        _isNeedShow = YES;
        return;
    }
    if (![self.buttons count]) {
        [self addButtonWithTitle:NSLS(@"ALERT_DEFAULT_BUTTON") andBlock:nil];
    }
    
    [self layoutViews];
    
    if (!_allowedShowSameAlerts && [self isShowingAlertWithSameTag]) {
        return;
    }
    
    self.overlayView = [JROverlayView showInView:self.containerView];
    self.overlayView.backgroundColor = [UIColor clearColor];
    [self.containerView insertSubview:self.alertView aboveSubview:self.overlayView];
    
    self.overlayView.hidden = NO;
    
    _alertWindow.hidden = NO;
    [_alertWindow makeKeyAndVisible];
    
    [self attachPopUpAnimation];
    
    [UIView animateWithDuration:0.225 animations:^{
        self.alertView.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (UIAccessibilityIsVoiceOverRunning()) {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.alertView);
        }
    }];
    
    _visible = YES;
    
    [self saveTag];
}

- (void)dismissAnimated:(BOOL)animated
{
    _isDismissing = YES;
    if (animated) {
        [self detachPopUpAnimation];
    }

    [UIView animateWithDuration:animated ? 0.225 : 0 animations:^{
        self.alertView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.overlayView hide];
        
        self.alertWindow.hidden = YES;
        [self.prevKeyWindow makeKeyAndVisible];
        
        self.containerView = nil;
        self.alertWindow = nil;
        self.overlayView = nil;
        self.prevKeyWindow = nil;
        
        _isDismissing = NO;
        
        if (_isNeedShow) {
            _isNeedShow = NO;
            [self show];
        }
    }];
    
    _visible = NO;
    
    [self removeTag];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    UIButton *button = (self.buttons)[buttonIndex];
    if (button) {
        [self buttonAction:button];
    }
}

- (void)buttonAction:(UIButton *)button
{
    NSUInteger index = [self.buttons indexOfObject:button];
    if (index != NSNotFound) {
        if ((self.buttonsActions)[index] != [NSNull null]) {
            JRAlertButtonAction action = (self.buttonsActions)[index];
            action();
            if (_commonActionBlock) {
                _commonActionBlock(index);
            }
        }
        
        if ([_delegate respondsToSelector:@selector(alert:withId:clickedButtonAtIndex:)]) {
            [_delegate alert:self withId:self.alertType clickedButtonAtIndex:index];
        }
        
        [self dismissAnimated:YES];
    }
}

- (void)dealloc
{
    [self removeTag];
}

#pragma mark alert tags

- (NSNumber *)alertTag
{
    return @([[NSString stringWithFormat:@"%@-%@-%@", self.message, @(self.showedImage), @([self.buttons count])] hash]);
}

- (BOOL)isShowingAlertWithSameTag
{
    NSNumber *tag = [self alertTag];
    if ([visibleAlertsTags containsObject:tag]) {
        return YES;
    }
    return NO;
}

- (void)saveTag
{
    if (!_visible) {
        return;
    }
    if (!visibleAlertsTags) {
        visibleAlertsTags = [NSMutableArray array];
    }
    [visibleAlertsTags addObject:[self alertTag]];
}

- (void)removeTag
{
    [visibleAlertsTags removeObject:[self alertTag]];
    if (![visibleAlertsTags count]) {
        visibleAlertsTags = nil;
    }
}

#pragma mark getters and setters

- (UIView *)alertView
{
    if (!_alertView) {
        _alertView = [UIView new];
        _alertView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _alertView;
}

- (UIView *)alertInnerView
{
    if (!_alertInnerView) {
        _alertInnerView = [UIView new];
        _alertInnerView.backgroundColor = kBackgroundColor;
        _alertInnerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _alertInnerView.layer.cornerRadius = 10.f;
        _alertInnerView.layer.masksToBounds = YES;
    }
    return _alertInnerView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = kBackgroundColor;
    }
    return _contentView;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.font = [UIFont systemFontOfSize:15.f];
        _messageLabel.textColor = [JRC ALERT_MESSAGE];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.backgroundColor = [UIColor clearColor];
    }
    return _messageLabel;
}

- (UIView *)containerView
{
    if (!_containerView) {
        UIApplication *application = [UIApplication sharedApplication];
        _prevKeyWindow = [application keyWindow];
        if (!_prevKeyWindow) {
            _prevKeyWindow = [[application windows] firstObject];
            [_prevKeyWindow makeKeyAndVisible];
        }
        
        _alertWindow = [[UIWindow alloc] initWithFrame:_prevKeyWindow.frame];
        _alertWindow.backgroundColor = [UIColor clearColor];
        _alertWindow.rootViewController = self;
        _alertWindow.hidden = YES;
        [_alertWindow setWindowLevel:UIWindowLevelAlert];

        _containerView = self.view;
        [_alertWindow addSubview:_containerView];
        [_containerView setFrame:_alertWindow.frame];
    }
    return _containerView;
}

- (UIView *)borderView
{
    if (!_borderView) {
        _borderView = [UIView new];
        self.borderView.backgroundColor = [JRC ALERT_BORDER];
    }
    return _borderView;
}

- (NSArray *)buttons
{
    if (!_buttons) {
        _buttons = @[];
    }
    return _buttons;
}

- (NSArray *)buttonsActions
{
    if (!_buttonsActions) {
        _buttonsActions = @[];
    }
    return _buttonsActions;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)setMessage:(NSString *)message
{
    [self removeTag];
    _message = message;
    [self saveTag];
    
    [self.messageLabel setText:_message];
    
    if (_visible) {
        [self layoutViews];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    if (!_image) {
        self.showedImage = NO;
    } else {
        self.showedImage = YES;
    }
}

- (void)setShowedImage:(BOOL)showedImage
{
    [self removeTag];
    _showedImage = showedImage;
    [self saveTag];
    
    if (_showedImage) {
        if (!_image) {
            _image = [UIImage imageNamed:kDefaultImageName];
        }
    } else {
        _image = nil;
    }
    
    if (_visible) {
        [self layoutViews];
    }
}

#pragma mark process rotation

- (BOOL)shouldAutorotate
{
    return [[_prevKeyWindow topMostController] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[_prevKeyWindow topMostController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[_prevKeyWindow topMostController] preferredInterfaceOrientationForPresentation];
}

#pragma mark animation

- (void)attachPopUpAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.25, 0.25, 1);
    CATransform3D scale2 = CATransform3DMakeScale(0.75, 0.75, 1);
    CATransform3D scale3 = CATransform3DMakeScale(1.0, 1.0, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale5 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = @[[NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            [NSValue valueWithCATransform3D:scale5]];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = @[@0.1f,
                           @0.4f,
                           @0.5f,
                           @0.6f,
                           @1.0f];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.265;
    
    [_alertView.layer addAnimation:animation forKey:@"popup"];
}

- (void)detachPopUpAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale5 = CATransform3DMakeScale(0.0, 0.0, 1);
    CATransform3D scale4 = CATransform3DMakeScale(0.75, 0.75, 1);
    CATransform3D scale3 = CATransform3DMakeScale(1.0, 1.0, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = @[[NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            [NSValue valueWithCATransform3D:scale5]];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = @[@0.1f,
                           @0.4f,
                           @0.7f,
                           @0.8f,
                           @1.0f];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.duration = 0.225;
    
    [_alertView.layer addAnimation:animation forKey:@"popup"];
}

@end
