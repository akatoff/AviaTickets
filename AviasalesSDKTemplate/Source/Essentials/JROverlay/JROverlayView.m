//
//  JROverlayView.m
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 25/04/14.
//
//

#import "JROverlayView.h"

@interface JROverlayView ()
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, strong) NSString *overlayTag;
@property (nonatomic) BOOL visible;
@end

@implementation JROverlayView

+ (JROverlayView *)showInView:(UIView *)view
{
    return [self showInView:view withTag:nil];
}

+ (JROverlayView *)showInView:(UIView *)view withTag:(NSString *)tag
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[JROverlayView class]] && [[(JROverlayView *)subview overlayTag] isEqualToString:tag]) {
            if (![(JROverlayView *)subview visible]) {
                [(JROverlayView *)subview show];
            }
            return (JROverlayView *)subview;
        }
    }
    
    JROverlayView *overlay = [JROverlayView new];
    overlay.containerView = view;
    overlay.overlayTag = tag;
    [overlay show];
    
    return overlay;
}

+ (void)hideAllInView:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[JROverlayView class]]) {
            [(JROverlayView *)subview hide];
        }
    }
}

+ (void)hideInView:(UIView *)view withTag:(NSString *)tag
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[JROverlayView class]] && [[(JROverlayView *)subview overlayTag] isEqualToString:tag]) {
            [(JROverlayView *)subview hide];
        }
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.alpha = 0.f;
    }
    return self;
}

- (void)show
{
    [self.containerView addSubview:self];
    
    [self setFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.f;
    }];
    
    _visible = YES;
}

- (void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    _visible = NO;
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

- (void)dealloc
{
    
}

@end
