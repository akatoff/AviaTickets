//
//  JRViewController.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 14/01/14.
//
//

#import "JRViewController.h"
#import "JRC.h"
#import "JRScreenScene.h"
#import "JRViewController+JRScreenScene.h"
#import "UIViewController+JRScreenSceneController.h"
#import "NSObject+Accessibility.h"

@interface JRViewController ()
@property (weak, nonatomic) UIButton *menuButton;
@end

@implementation JRViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.view setBackgroundColor:[JRC COMMON_BACKGROUND]];
    
	[self setTitle:NSStringFromClass(self.class)];
	[self setBackgroundColor];
    
    if ([self.navigationController.viewControllers count] > 1 && self.scene.accessoryViewController != self) {
        [self addPopButtonToNavigationItem];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController.navigationBar setTranslucent:NO];
	[self.navigationController.navigationBar.layer removeAllAnimations];
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        if (self.navigationItem.titleView) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.navigationItem.titleView.accessibilityLabel);
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    _viewIsVisible = NO;
    
    if (iPhone()) {
        [self.navigationController.navigationBar.layer removeAllAnimations];
    }
}

- (void)setBackgroundColor
{
	[self.view setBackgroundColor:[JRC COMMON_BACKGROUND]];
}

- (void)addPopButtonToNavigationItem
{
	UIBarButtonItem *popButton = [UINavigationItem barItemWithImageName:kJRBaseBackButtonImageName
                                                                 target:self
                                                                 action:@selector(popAction)];
    [popButton setAccessibilityLabelWithNSLSKey:@"JR_BACK_BTN_TITLE_ACC"];
	[self.navigationItem setLeftBarButtonItem:popButton];
}

- (void)popAction
{
	if (iPhone()) {
		[self.navigationController popViewControllerAnimated:YES];
	} else if (iPad()) {
		if (self.sceneViewController) {
			[self.sceneViewController popViewControllerAnimated:YES];
		} else if (self.navigationController) {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

- (void)popActionToRoot
{
	if (iPhone()) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	} else if (iPad()) {
		[self.sceneViewController popToRootViewControllerAnimated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _viewIsVisible = YES;
}

@end
