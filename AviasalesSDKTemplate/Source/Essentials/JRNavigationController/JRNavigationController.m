//
//  JRNavigationController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRNavigationController.h"
#import "UIImage+JRUIImage.h"
#import "JRNavigationBar.h"
#import "JRC.h"
#import "JRAlertManager.h"

#define kJRNavigationControllerBorderTag    12345678

@interface JRNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL pushInProgress;
@property (strong, nonatomic) NSDate *lastInteractivePopGestureBeginDate;

@property (nonatomic, strong) UIButton *screenshotAlertsButton;
@property (nonatomic, strong) UIButton *screenshotPopoversButton;

@end

@implementation JRNavigationController

- (id)init
{
	self = [super initWithNavigationBarClass:[JRNavigationBar class] toolbarClass:nil];
	return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithNavigationBarClass:[JRNavigationBar class] toolbarClass:nil];
	if (self && rootViewController) {
		[self setViewControllers:@[rootViewController] animated:NO];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setupNavigationBar];
	if (iPhone()) {
        [self setDelegate:self];
        __weak JRNavigationController *weakSelf = self;
        [self.interactivePopGestureRecognizer setDelegate:weakSelf];
		[self.view setBackgroundColor:[JRC NAVIGATION_BAR_BACKGROUND_COLOR]];
	}

#ifdef SCREENSHOTS
    [self addScreenshotsFunctions];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController.navigationBar.layer removeAllAnimations];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.navigationController.navigationBar.layer removeAllAnimations];
}

- (void)setupNavigationBar
{
	UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:kJRNavigationControllerDefaultTextSize];
	NSDictionary *titleTextAttributes = @{ NSFontAttributeName : boldSystemFont };
    
	UINavigationBar *navigationBar = [self navigationBar];
    
	[navigationBar setBarStyle:UIBarStyleBlack];
	[navigationBar setBarTintColor:[JRC NAVIGATION_BAR_BACKGROUND_COLOR]];
	[navigationBar setTitleTextAttributes:titleTextAttributes];
	[navigationBar setTranslucent:NO];
    
    [navigationBar setShadowImage:[[UIImage alloc] init]];
    
	CGFloat borderHeight = JRPixel();
    
	UIView *darkBorder = [UIView new];
	[darkBorder setFrame:CGRectMake(0, navigationBar.bounds.size.height - borderHeight, navigationBar.bounds.size.width, borderHeight)];
	[darkBorder setBackgroundColor:[JRC BAR_DARK_BOTTOM_BORDER]];
	[darkBorder setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
	[navigationBar addSubview:darkBorder];
    
	UIView *lightBorder = [UIView new];
	[lightBorder setFrame:CGRectMake(0, navigationBar.bounds.size.height, navigationBar.bounds.size.width, borderHeight)];
	[lightBorder setBackgroundColor:[JRC BAR_LIGHT_BOTTOM_BORDER]];
	[lightBorder setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    
	[navigationBar addSubview:lightBorder];
}

- (void)removeAllBordersFromNavigationBar {
    for (UIView *border in self.navigationBar.subviews.copy) {
        if ([border tag] == kJRNavigationControllerBorderTag) {
            [border removeFromSuperview];
        }
    }
}
#pragma mark UINavigationControllerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        
        BOOL topViewControllerIsEqualToFirstViewController = self.topViewController == self.viewControllers.firstObject;
        
        NSTimeInterval secondsAfterLastBegin = _lastInteractivePopGestureBeginDate ?
        [[NSDate date] timeIntervalSinceDate:_lastInteractivePopGestureBeginDate] : MAXFLOAT;
        
        if (self.pushInProgress == YES ||
            topViewControllerIsEqualToFirstViewController == YES ||
            secondsAfterLastBegin < 2) {
            return NO;
        } else {
            self.lastInteractivePopGestureBeginDate = [NSDate date];
            return YES;
        }
    }
    return YES;
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.pushInProgress = YES;
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.pushInProgress = NO;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (void)removeAllViewControllersExceptCurrent
{
    self.viewControllers = @[[self.viewControllers lastObject]];
}

#pragma mark autorotation

- (BOOL)shouldAutorotate
{
    if (iPhone() && !_allowedIphoneAutorotate) {
        return NO;
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (iPhone() && !_allowedIphoneAutorotate) {
        return UIInterfaceOrientationMaskPortrait;
    }
	return [super supportedInterfaceOrientations];
}

#pragma mark screenshots

- (void)addScreenshotsFunctions
{
    _screenshotAlertsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 20, 10, 10)];
    [_screenshotAlertsButton setAccessibilityLabelWithNSLSKey:@"JR_SCREENSHOT_ALERTS_BTN"];
    _screenshotAlertsButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_screenshotAlertsButton];
    [_screenshotAlertsButton addTarget:self action:@selector(screenshotAlertsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _screenshotPopoversButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + 30, 20, 10, 10)];
    [_screenshotPopoversButton setAccessibilityLabelWithNSLSKey:@"JR_SCREENSHOT_POPOVERS_BTN"];
    _screenshotPopoversButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_screenshotPopoversButton];
    [_screenshotPopoversButton addTarget:self action:@selector(screenshotPopoversAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)screenshotAlertsAction:(id)sender
{
    if (![[JRAlertManager sharedManager] screenshotsShowNextAlert]) {
        [_screenshotAlertsButton removeFromSuperview];
    }
}

- (void)screenshotPopoversAction:(id)sender
{
    if (![[JRAlertManager sharedManager] screenshotsShowNextPopoverUnderlyingView:self.view]) {
        [_screenshotPopoversButton removeFromSuperview];
    }
}

@end
