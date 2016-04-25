//
//  JRSwipeDeletionTableViewCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSwipeDeletionTableViewCell.h"
#import "JRC.h"
#import "JRSwipeDeletionTableView.h"

#define kAutoCompletionDuration 0.2f
#define kContentViewDefaultFrameFactor 1.f
#define kRightViewMinWidth 44.f
#define kRightViewMaxWidth 65.f

@interface JRSwipeDeletionTableViewCell ()
@property (nonatomic, strong) UIView *swipedView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;
@property (nonatomic) BOOL swipedButtonIsShowed;
@property (nonatomic) BOOL savedSelectedStatus;
@property (nonatomic, strong) JRSwipeDeletionTableView *tableView;
@end

@implementation JRSwipeDeletionTableViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self swipedButtonHideAnimated:NO];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    UIView *superview = self.superview;
    if (superview == nil) {
        return;
    }
    while (![superview isKindOfClass:[JRSwipeDeletionTableView class]]) {
        superview = superview.superview;
        if (!superview) {
            [NSException raise:@"Incorrect tableView type" format:@"JRSwipeDeletionTableViewCell must be placed in JRSwipeDeletionTableView"];
        }
    }
    
    _tableView = (JRSwipeDeletionTableView *)superview;
    
    if (_tableView.disabledSwipe == YES) {
        self.swipingDisabled = YES;
    }
    
    _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureRecognizer:)];
    _gestureRecognizer.delegate = self;
    _gestureRecognizer.enabled = self.swipingDisabled ? NO : YES;
    [self addGestureRecognizer:_gestureRecognizer];
    [self setUserInteractionEnabled:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView.superview addSubview:self.rightView];
    [self.contentView.superview insertSubview:self.deleteBtn aboveSubview:self.rightView];
    
    [self swipedButtonHideAnimated:NO];
    
    CGFloat rightViewWidth = self.swipedView.frame.size.height;
    if (rightViewWidth > kRightViewMaxWidth) {
        rightViewWidth = kRightViewMaxWidth;
    } else if (rightViewWidth < kRightViewMinWidth) {
        rightViewWidth = kRightViewMinWidth;
    }
    [self.rightView setFrame:CGRectMake(self.frame.size.width, 0, rightViewWidth, self.swipedView.frame.size.height)];
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.frame = _rightView.bounds;
    mask.fillColor = [[UIColor blackColor] CGColor];
    
    CGFloat width = _rightView.frame.size.width;
    CGFloat height = _rightView.frame.size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, nil, width, 0);
    CGPathAddLineToPoint(path, nil, width, height);
    CGPathAddLineToPoint(path, nil, 0, height);
    CGPathAddLineToPoint(path, nil, 0, height/2 + 8);
    CGPathAddLineToPoint(path, nil, 8, height/2);
    CGPathAddLineToPoint(path, nil, 0, height/2 - 8);
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathCloseSubpath(path);
    
    mask.path = path;
    CGPathRelease(path);
    
    _rightView.layer.mask = mask;
    
    self.deleteBtn.frame = CGRectMake(self.swipedView.superview.frame.size.width - _rightView.frame.size.width, 0, self.rightView.frame.size.width, self.rightView.frame.size.height);
}

#pragma mark setters & getters

- (UIView *)rightView
{
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = self.swipedViewBackgroundColor;
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    return _rightView;
}

- (UIImage *)swipedButtonImage
{
    if (!_swipedButtonImage) {
        _swipedButtonImage = [UIImage imageNamed:@"JRRowDeleteBtn"];
    }
    return _swipedButtonImage;
}

- (UIButton *)deleteBtn
{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setImage:self.swipedButtonImage forState:UIControlStateNormal];
        _deleteBtn.contentMode = UIViewContentModeCenter;
        _deleteBtn.backgroundColor = [UIColor clearColor];
        _deleteBtn.showsTouchWhenHighlighted = YES;
        
        _deleteBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        _deleteBtn.alpha = 0;
        
        [_deleteBtn setAccessibilityLabelWithNSLSKey:@"JR_SWIPED_CELL_DELETE_BTN"];
    }
    return _deleteBtn;
}

- (void)setSwipedButtonIsShowed:(BOOL)rightViewIsShowed
{
    if (!rightViewIsShowed /*&& _swipedButtonIsShowed != rightViewIsShowed*/) {
        [self didEndHideRightView];
    }
    
    _swipedButtonIsShowed = rightViewIsShowed;
}

- (void)setSwipingDisabled:(BOOL)disabledSwipe
{
    _swipingDisabled = disabledSwipe;
    if (_swipingDisabled) {
        if (_swipedButtonIsShowed) {
            [self swipedButtonHideAnimated:YES];
        }
        _gestureRecognizer.enabled = NO;
    } else {
        _gestureRecognizer.enabled = YES;
    }
}

- (CGFloat)swipedContentViewParallaxRate {
    if (!_swipedContentViewParallaxRate) {
        return kContentViewDefaultFrameFactor;
    }
    return _swipedContentViewParallaxRate;
}

- (UIView *)swipedView
{
    return self.contentView;
}

- (UIColor *)swipedViewBackgroundColor
{
    if (!_swipedViewBackgroundColor) {
        _swipedViewBackgroundColor = [JRC CELL_SWIPE_DELETE_BG];
    }
    return _swipedViewBackgroundColor;
}

#pragma mark show/hide right view

- (void)handleGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    static CGFloat prevXTranslation;
    static BOOL directionIsLeft;
    static CGFloat initialContentViewX;
    static CGFloat initialRightViewX;
    
    if (!prevXTranslation) {
        prevXTranslation = 0;
    }
    
    CGPoint translation = [recognizer translationInView:self.swipedView];
    if (translation.x - prevXTranslation < 0) {
        directionIsLeft = YES;
    } else if (translation.x - prevXTranslation > 0) {
        directionIsLeft = NO;
    }
    prevXTranslation = translation.x;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        initialContentViewX = self.swipedView.frame.origin.x;
        initialRightViewX = self.rightView.frame.origin.x;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGRect contentViewRect = self.swipedView.frame;
        CGFloat newContentViewX = initialContentViewX + translation.x*self.swipedContentViewParallaxRate;
        
        CGRect rightViewRect = self.rightView.frame;
        CGFloat newRightViewX = initialRightViewX + translation.x;

        if (-newContentViewX > _rightView.frame.size.width*self.swipedContentViewParallaxRate) {
            newContentViewX = -_rightView.frame.size.width*self.swipedContentViewParallaxRate;
        } else if (newContentViewX > 0) {
            newContentViewX = 0;
        }
        
        if (newRightViewX < self.frame.size.width - _rightView.frame.size.width) {
            newRightViewX = self.frame.size.width - _rightView.frame.size.width;
            self.swipedButtonIsShowed = YES;
        } else if (newRightViewX > self.frame.size.width) {
            newRightViewX = self.frame.size.width;
            self.swipedButtonIsShowed = NO;
        }
        contentViewRect.origin.x = newContentViewX;
        self.swipedView.frame = contentViewRect;
        
        rightViewRect.origin.x = newRightViewX;
        self.rightView.frame = rightViewRect;
        
        CGFloat rate = 1 - (newRightViewX - (self.frame.size.width - _rightView.frame.size.width)) / _rightView.frame.size.width;
        
        self.deleteBtn.alpha = rate;
        
        if (_swipedButtonAnimationType == JRSwipeDeletionTableViewCellButtonAnimationTypeRotation) {
            self.deleteBtn.transform = CGAffineTransformMakeRotation(-M_PI*0.5*rate);
        }
        
        if (directionIsLeft) {
            [self didStartShowRightView];
        }

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (directionIsLeft) {
            [self swipedButtonShowAnimated:YES];
        } else {
            [self swipedButtonHideAnimated:YES];
        }
    }
}

- (void)swipedButtonShowAnimated:(BOOL)animated
{
    CGRect contentViewRect = self.swipedView.frame;
    CGRect rightViewRect = self.rightView.frame;
    contentViewRect.origin.x = -_rightView.frame.size.width*self.swipedContentViewParallaxRate;
    rightViewRect.origin.x = self.frame.size.width - _rightView.frame.size.width;
    
    [self didStartShowRightView];
    if (animated) {[self.deleteBtn setNeedsDisplay];
        [UIView animateWithDuration:kAutoCompletionDuration animations:^{
            self.swipedView.frame = contentViewRect;
            self.rightView.frame = rightViewRect;
            
            self.deleteBtn.alpha = 1;
            
            if (_swipedButtonAnimationType == JRSwipeDeletionTableViewCellButtonAnimationTypeRotation) {
                self.deleteBtn.transform = CGAffineTransformMakeRotation(-M_PI*0.5);;
            }
        } completion:^(BOOL finished) {
            self.deleteBtn.alpha = 1;
            self.swipedButtonIsShowed = YES;
        }];
    } else {
        self.swipedView.frame = contentViewRect;
        self.rightView.frame = rightViewRect;
        self.swipedButtonIsShowed = YES;
        self.deleteBtn.alpha = 1;
    }
}

- (void)swipedButtonHideAnimated:(BOOL)animated
{
    CGRect contentViewRect = self.swipedView.frame;
    CGRect rightViewRect = self.rightView.frame;
    contentViewRect.origin.x = 0;
    rightViewRect.origin.x = self.frame.size.width;
    
    if (animated) {
        [UIView animateWithDuration:kAutoCompletionDuration animations:^{
            self.swipedView.frame = contentViewRect;
            self.rightView.frame = rightViewRect;
            
            self.deleteBtn.alpha = 0;
            
            if (_swipedButtonAnimationType == JRSwipeDeletionTableViewCellButtonAnimationTypeRotation) {
                self.deleteBtn.transform = CGAffineTransformMakeRotation(M_PI*0);
            }
        } completion:^(BOOL finished) {
            self.deleteBtn.alpha = 0;
            self.swipedButtonIsShowed = NO;
        }];
    } else {
        self.swipedView.frame = contentViewRect;
        self.rightView.frame = rightViewRect;
        self.swipedButtonIsShowed = NO;
        self.deleteBtn.alpha = 0;
    }
}

- (void)didStartShowRightView
{
    if (!self.savedSelectedStatus) {
        self.savedSelectedStatus = self.selected;
    }
    self.selected = NO;
    
    self.tableView.swipedCell = self;
    
    [_deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didEndHideRightView
{
    if (self.savedSelectedStatus) {
        self.selected = self.savedSelectedStatus;
        self.savedSelectedStatus = NO;
    }
    
    self.tableView.swipedCell = nil;
    
    [_deleteBtn removeTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark other

- (void)deleteBtnAction:(id)sender
{
    if ([_swipeDeletionDelegate respondsToSelector:@selector(swipedDeleteButtonClickedInCell:)]) {
        [_swipeDeletionDelegate swipedDeleteButtonClickedInCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected && self.swipedButtonIsShowed) {
        [self swipedButtonHideAnimated:YES];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.swipedButtonIsShowed) {
        NSSet* allTouches = [event allTouches];
        UITouch* touch = [allTouches anyObject];
        if (touch.tapCount == 1) {
            [self swipedButtonHideAnimated:YES];
            return nil;
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark gesture recognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _gestureRecognizer) {
        CGPoint velocity = [gestureRecognizer velocityInView:self];
        
        if (fabs(velocity.x) > fabs(velocity.y)) {
            if (!self.swipedButtonIsShowed && self.rightView.frame.origin.x <= self.frame.size.width && velocity.x < 0) {//open
                return YES;
            } else if (self.rightView.frame.origin.x == self.frame.size.width - _rightView.frame.size.width && velocity.x > 0) {//close
                return YES;
            }
        }
        
        return NO;
    }
    
    return YES;
}

@end
