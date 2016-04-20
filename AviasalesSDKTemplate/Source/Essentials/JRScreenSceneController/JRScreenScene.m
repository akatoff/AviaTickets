//
//  JRScreenScene.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRScreenScene.h"
#import "JRViewController.h"
#import "UIViewController+JRAddChildViewController.h"
#import "JRC.h"
#import "JROverlayView.h"
#import "UIImage+JRUIImage.h"
#import "JRC.h"
#import "JRScreneSceneScrollView.h"
#import "JRViewController+JRScreenScene.h"
#import "NSLayoutConstraint+JRConstraintMake.h"

#define kJRScreenSceneAnimationDamping          0.8
#define kJRScreenSceneAnimationDuration         0.4
#define kJRScreenSceneBottomMargin              15
#define kJRScreenSceneDefaultRadius             2
#define kJRScreenSceneDetachCap                 0.1

#define kJRScreenSceneLeftORRightMarginDefault              30
#define kJRScreenSceneLeftORRightMarginPortraitCompatible   25

#define kJRScreenSceneTitleFont                 [UIFont boldSystemFontOfSize:20]
#define kJRScreenSceneTopMargin                 0
#define kJRScreenSceneScrollViewContentTopMargin    80
#define JRScreenSceneShadowLineHeight 4

@interface JRScreenScene ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) CGFloat accessoryViewWidth;
@property (assign, nonatomic) CGFloat accessoryPortraitViewWidth;
@property (strong, nonatomic) NSLayoutConstraint *accessoryWidthConstraint;
@property (assign, nonatomic) CGFloat mainViewWidth;
@property (assign, nonatomic) CGFloat mainPortraitViewWidth;
@property (strong, nonatomic) NSLayoutConstraint *mainWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *accessoryViewKeyConstraint;
@property (strong, nonatomic) NSLayoutConstraint *mainViewKeyConstraint;
@property (strong, nonatomic) NSMutableArray *accessoryViewConstraints;
@property (strong, nonatomic) NSMutableArray *mainViewConstraints;
@property (strong, nonatomic) UIPanGestureRecognizer *scenePanGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *sceneTapGestureRecognizer;
@property (strong, nonatomic) JRScreneSceneScrollView *mainViewScrollView;
@property (strong, nonatomic) JRScreneSceneScrollView *accessoryViewScrollView;
@property (strong, nonatomic) UINavigationBar *mainViewBar;
@property (strong, nonatomic) UINavigationBar *accessoryViewBar;
@end

@implementation JRScreenScene

- (id)initWithViewController:(UIViewController *)viewController
               portraitWidth:(CGFloat)firstPortraitWidth
              landscapeWidth:(CGFloat)firstLandscapeWidth
{
	self = [super init];
	if (self) {
        
		[self setEdgesForExtendedLayout:UIRectEdgeNone];
		[self setExtendedLayoutIncludesOpaqueBars:YES];
		[self setAutomaticallyAdjustsScrollViewInsets:NO];
        
		_mainViewController = viewController;
		_mainViewWidth = firstLandscapeWidth;
        _mainPortraitViewWidth = firstPortraitWidth == kNilOptions ? _mainViewWidth : firstPortraitWidth;
		_dimWhenUnfocused = NO;
	}
	return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
    
	[self attachMainViewController];
	if (_accessoryViewController) {
        [self attachAccessoryViewController:_accessoryViewController
                              portraitWidth:_accessoryPortraitViewWidth
                             landscapeWidth:_accessoryViewWidth
                             exclusiveFocus:_accessoryExclusiveFocus animated:NO];	}
    
	_sceneTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
	[_sceneTapGestureRecognizer setDelegate:self];
    
	[self.view addGestureRecognizer:_sceneTapGestureRecognizer];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateConstraintsForInterfaceOrientation:self.interfaceOrientation animated:NO];
}

- (void)bringFocusToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController == _mainViewController) {
		[self setFocusToMainViewAnimated:animated];
	} else if (viewController == _accessoryViewController) {
		[self setFocusToAccessoryViewAnimated:animated];
	}
}

- (NSArray *)subviews
{
	NSMutableArray *subviews = [[NSMutableArray alloc] init];
	for (UIView *view in self.view.subviews) {
		if (view == _mainViewScrollView ||
		    view == _accessoryViewScrollView) {
			[subviews addObject:view];
		}
	}
	return subviews;
}

- (UIView *)viewByGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
	NSArray *subviews = [[[self subviews] reverseObjectEnumerator] allObjects];
	for (UIView *view in subviews) {
		CGPoint location = [gestureRecognizer locationInView:view];
		if ([view pointInside:location withEvent:nil]) {
			return view;
		}
	}
	return nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	UIView *view = [self viewByGestureRecognizer:gestureRecognizer];
	if (view == _mainViewScrollView) {
		if (_accessoryViewController && _accessoryExclusiveFocus) {
            if (!([_accessoryViewController respondsToSelector:@selector(shouldDetachFromMainViewController)] && ![(JRViewController *)_accessoryViewController shouldDetachFromMainViewController])) {
                [self setFocusToMainViewAnimated:YES];
                [self detachAccessoryViewControllerAnimated:YES updateFocus:NO];
            }
		} else {
            [self setFocusToMainViewAnimated:YES];
        }
	} else if (view == _accessoryViewScrollView) {
		[self setFocusToAccessoryViewAnimated:YES];
	}
	return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (scrollView == _mainViewScrollView) {
		[self setFocusToMainViewAnimated:YES];
	} else if (scrollView == _accessoryViewScrollView) {
		[self setFocusToAccessoryViewAnimated:YES];
	}
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
	CGFloat originX = 0;
	if (_accessoryViewScrollView.bounds.origin.x < 0) {
		originX = fabs(_accessoryViewScrollView.bounds.origin.x);
	}
    CGFloat width = [self accessoryViewWidthForInterfaceOrientation:self.interfaceOrientation];
	CGFloat cap = width * kJRScreenSceneDetachCap;
    
	BOOL isAccessoryViewIsFocused = [self isAccessoryViewIsFocused];
	if (_accessoryViewController &&
	    _accessoryExclusiveFocus &&
	    (![self isAccessoryViewIsFocused] ||
	     originX > cap)) {
            if ((!([_accessoryViewController respondsToSelector:@selector(shouldDetachFromMainViewController)] && ![(JRViewController *)_accessoryViewController shouldDetachFromMainViewController]))) {
                [self setFocusToMainViewAnimated:isAccessoryViewIsFocused];
                [self detachAccessoryViewControllerAnimated:YES updateFocus:NO];
            }
        }
}

static void * JRMainViewFrameChangeContext = &JRMainViewFrameChangeContext;
static void * JRAccessoryViewFrameChangeContext = &JRAccessoryViewFrameChangeContext;
static BOOL observeingMainFrame = NO;
static BOOL observeingAccessoryFrame = NO;

- (void)dealloc
{
	[_mainViewScrollView removeObserver:self forKeyPath:@"bounds" context:JRMainViewFrameChangeContext];
	[_accessoryViewScrollView removeObserver:self forKeyPath:@"bounds" context:JRAccessoryViewFrameChangeContext];
}

- (void)removeMainViewController
{
	[_mainViewBar removeFromSuperview];
	_mainViewBar = nil;
    
	[_mainViewScrollView removeObserver:self forKeyPath:@"bounds" context:JRMainViewFrameChangeContext];
	[_mainViewScrollView removeFromSuperview];
	_mainViewScrollView = nil;
    
	[self deleteChildViewController:_mainViewController];
}

- (void)reattachMainViewController
{
	[self removeMainViewController];
	[self attachMainViewController];
}

- (void)attachMainViewController
{
    
	_mainViewScrollView = [JRScreneSceneScrollView new];
	[_mainViewScrollView setDelegate:self];
	[_mainViewScrollView setAlwaysBounceHorizontal:YES];
	[_mainViewScrollView setAlwaysBounceVertical:NO];
	[_mainViewScrollView setClipsToBounds:NO];
	[_mainViewScrollView setShowsHorizontalScrollIndicator:NO];
	[_mainViewScrollView setShowsVerticalScrollIndicator:NO];
	[_mainViewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
	[self.view addSubview:_mainViewScrollView];
    
	[_mainViewScrollView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:JRMainViewFrameChangeContext];
	[self addChildViewController:_mainViewController toView:_mainViewScrollView];
    
	[self setMainChildConstraintsToCenterWithInterfaceOrientation:self.interfaceOrientation];
	[self createNavigationBarForViewController:_mainViewController];
	[self.view layoutIfNeeded];
    
	[self addMotionEffectsToView:_mainViewScrollView];
    
    
	[self shadowPathMakeForScrollView:_mainViewScrollView boundsView:_mainViewController.view];
	[self addLayerEffectsToView:_mainViewController.view];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
	if (context == JRMainViewFrameChangeContext && !observeingMainFrame) {
		observeingMainFrame = YES;
        
		CGRect newMainContainerFrame = CGRectMake(0, kJRScreenSceneScrollViewContentTopMargin, _mainViewScrollView.bounds.size.width, _mainViewScrollView.bounds.size.height - kJRScreenSceneScrollViewContentTopMargin);
        
		[_mainViewScrollView setContentSize:newMainContainerFrame.size];
		[_mainViewController.view setFrame:newMainContainerFrame];
		[self shadowPathMakeForScrollView:_mainViewScrollView boundsView:_mainViewController.view];
        
		observeingMainFrame = NO;
        
	} else if (context == JRAccessoryViewFrameChangeContext && !observeingAccessoryFrame) {
		observeingAccessoryFrame = YES;
        
        
        
		CGRect newAccessotyContainerFrame = CGRectMake(0, kJRScreenSceneScrollViewContentTopMargin, _accessoryViewScrollView.bounds.size.width, _accessoryViewScrollView.bounds.size.height - kJRScreenSceneScrollViewContentTopMargin);
        
		[_accessoryViewScrollView setContentSize:newAccessotyContainerFrame.size];
		[_accessoryViewController.view setFrame:newAccessotyContainerFrame];
		[self shadowPathMakeForScrollView:_accessoryViewScrollView boundsView:_accessoryViewController.view];
        
		observeingAccessoryFrame = NO;
        
	}
}

- (void)attachAccessoryViewController:(UIViewController *)viewController
                                width:(CGFloat)width
                       exclusiveFocus:(BOOL)exclusiveFocus
                             animated:(BOOL)animated {
    [self attachAccessoryViewController:viewController portraitWidth:kNilOptions landscapeWidth:width exclusiveFocus:exclusiveFocus animated:animated];
}

- (void)attachAccessoryViewController:(UIViewController *)viewController
                        portraitWidth:(CGFloat)secondPortraitWidth
                       landscapeWidth:(CGFloat)secondLandscapeWidth
                       exclusiveFocus:(BOOL)exclusiveFocus
                             animated:(BOOL)animated
{
    if (_accessoryViewController == viewController) {
        return;
    }
	[self removeAccessoryViewController];
    
	_accessoryViewScrollView = [JRScreneSceneScrollView new];
	[_accessoryViewScrollView setDelegate:self];
	[_accessoryViewScrollView setAlwaysBounceHorizontal:YES];
	[_accessoryViewScrollView setAlwaysBounceVertical:NO];
	[_accessoryViewScrollView setClipsToBounds:NO];
	[_accessoryViewScrollView setShowsHorizontalScrollIndicator:NO];
	[_accessoryViewScrollView setShowsVerticalScrollIndicator:NO];
    
	[self.view addSubview:_accessoryViewScrollView];
	[_accessoryViewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
	_accessoryViewController = viewController;
    
    _accessoryViewWidth = secondLandscapeWidth;
    _accessoryPortraitViewWidth = secondPortraitWidth == kNilOptions ? _accessoryViewWidth : secondPortraitWidth;
    
	_accessoryExclusiveFocus = exclusiveFocus;
    
	[_accessoryViewScrollView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:JRAccessoryViewFrameChangeContext];
	[self addChildViewController:_accessoryViewController toView:_accessoryViewScrollView];
    
	[self setSecondChildConstraintsToNowhereWithInterfaceOrientation:self.interfaceOrientation];
	[self createNavigationBarForViewController:_accessoryViewController];
	[self.view layoutIfNeeded];
    
	NSTimeInterval duration = animated ? kJRScreenSceneAnimationDuration : 0;
	[UIView animateWithDuration:duration
                          delay:kNilOptions
         usingSpringWithDamping:kJRScreenSceneAnimationDamping
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            [self setMainChildConstraintsToLeftWithInterfaceOrientation:self.interfaceOrientation];
                            [self setSecondChildConstraintsToRightWithInterfaceOrientation:self.interfaceOrientation];
                            [self.view layoutIfNeeded];
                        } completion:^(BOOL finished) {
                            if (UIAccessibilityIsVoiceOverRunning()) {
                                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _accessoryViewScrollView);
                            }
                        }];
    
	[self addMotionEffectsToView:_accessoryViewScrollView];
	if (_accessoryExclusiveFocus) {
		[self setFocusToAccessoryViewAnimated:animated];
	}
	[self showOverlayIfNeedsForInterfaceOrientation:self.interfaceOrientation animated:animated];
    
    
	[self shadowPathMakeForScrollView:_accessoryViewScrollView boundsView:_accessoryViewController.view];
    
	[self addLayerEffectsToView:_accessoryViewController.view];
}

- (void)createNavigationBarForViewController:(UIViewController *)viewController
{
    
	UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
	[navigationBar setBackgroundImage:[UIImage imageWithColor:[JRC CLEAR_COLOR]] forBarMetrics:UIBarMetricsDefault];
	[navigationBar setBarStyle:UIBarStyleBlack];
	[self addMotionEffectsToView:navigationBar];
    
	UIScrollView *barScrollView;
	if (viewController == _mainViewController) {
		_mainViewBar = navigationBar;
		barScrollView = _mainViewScrollView;
	} else if (viewController == _accessoryViewController) {
		_accessoryViewBar = navigationBar;
		barScrollView = _accessoryViewScrollView;
	}
	UIView *scrollViewSubview = [barScrollView.subviews firstObject];
    
	if (scrollViewSubview && barScrollView && barScrollView) {
		[navigationBar setItems:@[viewController.navigationItem]];
        
		NSDictionary *titleTextAttributes = @{ NSFontAttributeName : kJRScreenSceneTitleFont };
		[navigationBar setTitleTextAttributes:titleTextAttributes];
        
		[barScrollView addSubview:navigationBar];
		[navigationBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        
		CGFloat height = 65;
		[barScrollView addConstraint:JRConstraintMake(navigationBar, NSLayoutAttributeCenterX, NSLayoutRelationEqual, scrollViewSubview, NSLayoutAttributeCenterX, 1, 0)];
		[barScrollView addConstraint:JRConstraintMake(navigationBar, NSLayoutAttributeTop, NSLayoutRelationEqual, barScrollView, NSLayoutAttributeTop, 1, 0)];
		[barScrollView addConstraint:JRConstraintMake(navigationBar, NSLayoutAttributeWidth, NSLayoutRelationEqual, barScrollView, NSLayoutAttributeWidth, 1, 0)];
		[navigationBar addConstraint:JRConstraintMake(navigationBar, NSLayoutAttributeHeight, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, height)];
	}
}

- (void)addMotionEffectsToView:(UIView *)view
{
	for (UIMotionEffect *effect in view.motionEffects.copy) {
		[view removeMotionEffect:effect];
	}
	UIInterpolatingMotionEffect *xEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	[xEffect setMinimumRelativeValue:@(-kJRInterpolatingMotionEffectMinimumRelativeValueX)];
	[xEffect setMaximumRelativeValue:@(kJRInterpolatingMotionEffectMinimumRelativeValueX)];
	[view addMotionEffect:xEffect];
    
}

- (void)addLayerEffectsToView:(UIView *)view
{
	[view.layer setMasksToBounds:YES];
	[view.layer setCornerRadius:kJRScreenSceneDefaultRadius];
    
}


- (void)setFocusToMainViewAnimated:(BOOL)animated
{
	[self.view bringSubviewToFront:_mainViewScrollView];
	[self showOverlayIfNeedsForInterfaceOrientation:self.interfaceOrientation animated:animated];
}

- (void)setFocusToAccessoryViewAnimated:(BOOL)animated
{
	[self.view bringSubviewToFront:_accessoryViewScrollView];
	[self showOverlayIfNeedsForInterfaceOrientation:self.interfaceOrientation animated:animated];
}

- (void)setAccessoryExclusiveFocus:(BOOL)accessoryExclusiveFocus
{
	_accessoryExclusiveFocus = accessoryExclusiveFocus;
	[self showOverlayIfNeedsForInterfaceOrientation:self.interfaceOrientation animated:YES];
}

- (void)setDimWhenUnfocused:(BOOL)dimWhenUnfocused
{
	_dimWhenUnfocused = dimWhenUnfocused;
	[self showOverlayIfNeedsForInterfaceOrientation:self.interfaceOrientation animated:YES];
}

- (BOOL)isAccessoryViewIsFocused
{
	return [self subviews].lastObject == _accessoryViewScrollView;
}

- (void)detachAccessoryViewControllerAnimated:(BOOL)animated
{
	[self detachAccessoryViewControllerAnimated:animated updateFocus:YES];
}

- (void)detachAccessoryViewControllerAnimated:(BOOL)animated updateFocus:(BOOL)updateFocus
{
	if (_accessoryViewController) {
        
        if ([_mainViewController respondsToSelector:@selector(accessoryWillDetach)]) {
            [_mainViewController performSelector:@selector(accessoryWillDetach)];
        }
        if ([_accessoryViewController respondsToSelector:@selector(accessoryWillDetach)]) {
            [_accessoryViewController performSelector:@selector(accessoryWillDetach)];
        }
        
        BOOL isAccessoryViewWasFocused = [self isAccessoryViewIsFocused];
        if (isAccessoryViewWasFocused) {
            [self.view insertSubview:_mainViewScrollView belowSubview:_accessoryViewScrollView];
        }
        [self setMainChildConstraintsToLeftWithInterfaceOrientation:self.interfaceOrientation];
        if (updateFocus) {
            [self setFocusToMainViewAnimated:YES];
        }
        [self.view layoutIfNeeded];
        
		NSTimeInterval duration = animated ? kJRScreenSceneAnimationDuration * 1.5 : 0;
		[UIView animateWithDuration:duration
                              delay:kNilOptions
             usingSpringWithDamping:kJRScreenSceneAnimationDamping
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionOverrideInheritedOptions animations:^{
                                [self setSecondChildConstraintsToNowhereWithInterfaceOrientation:self.interfaceOrientation];
                                [self setMainChildConstraintsToCenterWithInterfaceOrientation:self.interfaceOrientation];
                                [self.view layoutIfNeeded];
                            } completion:^(BOOL finished) {
                                [self removeAccessoryViewController];
                            } ];
        
	}
}

- (void)removeAccessoryViewController
{
	[_accessoryViewBar removeFromSuperview];
	_accessoryViewBar = nil;
    
	[_accessoryViewScrollView removeObserver:self forKeyPath:@"bounds" context:JRAccessoryViewFrameChangeContext];
	[_accessoryViewScrollView removeFromSuperview];
	_accessoryViewScrollView = nil;
    
	[self deleteChildViewController:_accessoryViewController];
	_accessoryViewController = nil;
	_accessoryExclusiveFocus = NO;
	[self showOverlayIfNeedsForInterfaceOrientation:self.interfaceOrientation animated:NO];
	[self setMainChildConstraintsToCenterWithInterfaceOrientation:self.interfaceOrientation];
}

- (void)setMainChildConstraintsToLeftWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	if (_mainViewScrollView.superview != self.view) {
		return;
	} else if ([_mainViewConstraints isKindOfClass:[NSArray class]]) {
		[self.view removeConstraints:_mainViewConstraints];
	}
    
    
	_mainViewConstraints = [[NSMutableArray alloc] init];
    
	UIView *childView = _mainViewScrollView;
    
    _mainWidthConstraint = JRConstraintMake(childView, NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, [self mainViewWidthForInterfaceOrientation:interfaceOrientation]);
	[_mainViewConstraints addObject:_mainWidthConstraint];
	[_mainViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeTop, NSLayoutRelationEqual, self.view, NSLayoutAttributeTop, 1, kJRScreenSceneTopMargin)];
    
    
	CGFloat leftConstant = kJRScreenSceneLeftORRightMarginDefault;
    if ((_mainViewWidth != _mainPortraitViewWidth || _accessoryViewWidth != _accessoryPortraitViewWidth)
        && UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        leftConstant = kJRScreenSceneLeftORRightMarginPortraitCompatible;
    }
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        // TODO: check menu portrait height
        leftConstant = leftConstant / 2;// + kJRMainScreenMenuPortraitHeight;
	}
	_mainViewKeyConstraint = JRConstraintMake(childView, NSLayoutAttributeLeft, NSLayoutRelationEqual, self.view, NSLayoutAttributeLeft, 1, leftConstant);
	[_mainViewConstraints addObject:_mainViewKeyConstraint];
	[_mainViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeBottom, NSLayoutRelationEqual, self.view, NSLayoutAttributeBottom, 1, -kJRScreenSceneBottomMargin)];
    
	[self.view addConstraints:_mainViewConstraints];
}

- (void)setMainChildConstraintsToCenterWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	if (_mainViewScrollView.superview != self.view) {
		return;
	} else if ([_mainViewConstraints isKindOfClass:[NSArray class]]) {
		[self.view removeConstraints:_mainViewConstraints];
	}
    
    
	_mainViewConstraints = [[NSMutableArray alloc] init];
    
	UIView *childView = _mainViewScrollView;
    
	_mainWidthConstraint = JRConstraintMake(childView, NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, [self mainViewWidthForInterfaceOrientation:interfaceOrientation]);
	[_mainViewConstraints addObject:_mainWidthConstraint];
	[_mainViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeTop, NSLayoutRelationEqual, self.view, NSLayoutAttributeTop, 1, kJRScreenSceneTopMargin)];
	_mainViewKeyConstraint = JRConstraintMake(childView, NSLayoutAttributeCenterX, NSLayoutRelationEqual, self.view, NSLayoutAttributeCenterX, 1, 0);
	[_mainViewConstraints addObject:_mainViewKeyConstraint];
	[_mainViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeBottom, NSLayoutRelationEqual, self.view, NSLayoutAttributeBottom, 1, -kJRScreenSceneBottomMargin)];
    
	[self.view addConstraints:_mainViewConstraints];
}

- (void)setSecondChildConstraintsToRightWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	if (_accessoryViewScrollView.superview != self.view) {
		return;
	} else if ([_accessoryViewConstraints isKindOfClass:[NSArray class]]) {
		[self.view removeConstraints:_accessoryViewConstraints];
	}
    
	_accessoryViewConstraints = [[NSMutableArray alloc] init];
    
	UIView *childView = _accessoryViewScrollView;
    
	[_accessoryViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeTop, NSLayoutRelationEqual, self.view, NSLayoutAttributeTop, 1, kJRScreenSceneTopMargin)];
    
    CGFloat rightConstant = kJRScreenSceneLeftORRightMarginDefault;
    if ((_mainViewWidth != _mainPortraitViewWidth || _accessoryViewWidth != _accessoryPortraitViewWidth)
        && UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        rightConstant = kJRScreenSceneLeftORRightMarginPortraitCompatible;
    }
    
	_accessoryViewKeyConstraint = JRConstraintMake(childView, NSLayoutAttributeRight, NSLayoutRelationEqual, self.view, NSLayoutAttributeRight, 1, -rightConstant);
	[_accessoryViewConstraints addObject:_accessoryViewKeyConstraint];
	[_accessoryViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeBottom, NSLayoutRelationEqual, self.view, NSLayoutAttributeBottom, 1,  -kJRScreenSceneBottomMargin)];
    _accessoryWidthConstraint = JRConstraintMake(childView, NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, [self accessoryViewWidthForInterfaceOrientation:interfaceOrientation]);
	[_accessoryViewConstraints addObject:_accessoryWidthConstraint];
    
	[self.view addConstraints:_accessoryViewConstraints];
}

- (void)setSecondChildConstraintsToNowhereWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (_accessoryViewScrollView.superview != self.view) {
		return;
	} else if ([_accessoryViewConstraints isKindOfClass:[NSArray class]]) {
		[self.view removeConstraints:_accessoryViewConstraints];
	}
    
	_accessoryViewConstraints = [[NSMutableArray alloc] init];
    
	UIView *childView = _accessoryViewScrollView;
    
	[_accessoryViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeTop, NSLayoutRelationEqual, self.view, NSLayoutAttributeTop, 1, kJRScreenSceneTopMargin)];
	_accessoryViewKeyConstraint = JRConstraintMake(childView, NSLayoutAttributeRight, NSLayoutRelationEqual, self.view, NSLayoutAttributeRight, 1, 500);
	[_accessoryViewConstraints addObject:_accessoryViewKeyConstraint];
	[_accessoryViewConstraints addObject:JRConstraintMake(childView, NSLayoutAttributeBottom, NSLayoutRelationEqual, self.view, NSLayoutAttributeBottom, 1,  -kJRScreenSceneBottomMargin)];
	_accessoryWidthConstraint = JRConstraintMake(childView, NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, [self accessoryViewWidthForInterfaceOrientation:interfaceOrientation]);
	[_accessoryViewConstraints addObject:_accessoryWidthConstraint];
    
	[self.view addConstraints:_accessoryViewConstraints];
}


- (void)updateConstraintsForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation animated:(BOOL)animated
{
	[self showOverlayIfNeedsForInterfaceOrientation:toInterfaceOrientation animated:animated];
	if (_accessoryViewController) {
		[self setMainChildConstraintsToLeftWithInterfaceOrientation:toInterfaceOrientation];
        [self setSecondChildConstraintsToRightWithInterfaceOrientation:toInterfaceOrientation];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration delay:kNilOptions options:UIViewAnimationOptionOverrideInheritedOptions animations:^{
         [self updateConstraintsForInterfaceOrientation:toInterfaceOrientation animated:YES];
    } completion:NULL];
}
    

- (BOOL)showOverlayIfNeedsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         animated:(BOOL)animated
{
    
    BOOL portraitCompatible = _mainViewWidth != _mainPortraitViewWidth || _accessoryViewWidth != _accessoryPortraitViewWidth;
	if ((_accessoryViewController &&  (_accessoryExclusiveFocus || _dimWhenUnfocused)) ||
	    (!portraitCompatible && _accessoryViewController && !_accessoryExclusiveFocus && !_dimWhenUnfocused && UIInterfaceOrientationIsPortrait(interfaceOrientation))) {
        
		NSArray *subviews = [self subviews];
		UIView *view = [subviews firstObject];
		JROverlayView *overlay;
		if (view == subviews.firstObject && view == _mainViewScrollView) {
			overlay = [JROverlayView showInView:_mainViewController.view withTag:@"mainViewOverlay"];
		} else {
            [JROverlayView hideInView:_mainViewController.view withTag:@"mainViewOverlay"];
		}
		if (view == subviews.firstObject && view == _accessoryViewScrollView) {
            overlay = [JROverlayView showInView:_accessoryViewController.view withTag:@"accessoryViewOverlay"];
		} else {
            [JROverlayView hideInView:_accessoryViewController.view withTag:@"accessoryViewOverlay"];
		}
		[overlay setBackgroundColor:[[JRC BLACK_COLOR] colorWithAlphaComponent:0.15]];
		[overlay.layer setCornerRadius:kJRScreenSceneDefaultRadius];
        
		return YES;
        
	} else {
        [JROverlayView hideInView:_mainViewController.view withTag:@"mainViewOverlay"];
        [JROverlayView hideInView:_accessoryViewController.view withTag:@"accessoryViewOverlay"];

		return NO;
	}
}

- (void)shadowPathMakeForScrollView:(UIScrollView *)view boundsView:(UIView *)boundsView
{
    
	[view.layer setShadowRadius:kJRScreenSceneDefaultRadius];
	[view.layer setShadowOffset:CGSizeMake(0, 1)];
	[view.layer setShadowOpacity:1];
	[view.layer setShadowColor:[[JRC SCENE_SHADOW_COLOR] CGColor]];
    
	UIBezierPath *path = [UIBezierPath new];
    
	CGFloat lineHeight = JRScreenSceneShadowLineHeight;
    
	CGRect viewBounds = CGRectMake(boundsView.bounds.origin.x, boundsView.bounds.origin.y + kJRScreenSceneScrollViewContentTopMargin, view.frame.size.width, view.frame.size.height);
    
	[path moveToPoint:CGPointMake(viewBounds.origin.x, viewBounds.origin.y)];
	[path addLineToPoint:CGPointMake(viewBounds.size.width, viewBounds.origin.y)];
	[path addLineToPoint:CGPointMake(viewBounds.size.width, viewBounds.size.height)];
    
	[path addLineToPoint:CGPointMake(viewBounds.origin.x, viewBounds.size.height)];
	[path addLineToPoint:CGPointMake(viewBounds.origin.x, viewBounds.origin.y + lineHeight)];
	[path addLineToPoint:CGPointMake(viewBounds.origin.x + lineHeight, viewBounds.origin.y + lineHeight)];
	[path addLineToPoint:CGPointMake(viewBounds.origin.x + lineHeight, viewBounds.size.height - lineHeight)];
	[path addLineToPoint:CGPointMake(viewBounds.size.width - lineHeight, viewBounds.size.height - lineHeight)];
	[path addLineToPoint:CGPointMake(viewBounds.size.width - lineHeight, viewBounds.origin.y + lineHeight)];
	[path addLineToPoint:CGPointMake(viewBounds.origin.x, viewBounds.origin.y + lineHeight)];
    
	CGPathRef newPath = path.CGPath;
    
	view.layer.shadowPath = newPath;
}

- (CGFloat)mainViewWidthForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation) ? _mainViewWidth : _mainPortraitViewWidth;
}

- (CGFloat)accessoryViewWidthForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation) ? _accessoryViewWidth : _accessoryPortraitViewWidth;
}

@end

