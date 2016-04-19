//
//  ASPopoverController.m
//  aviasales
//
//  Created by Andrey Zakharevich on 04.02.13.
//
//

#import "JRSimplePopoverController.h"
#import "JRSimplePopoverBackgroundView.h"
#import "JRC.h"
#import "UIImage+ASUIImage.h"

@implementation JRSimplePopoverController
{
    BOOL withNavigation;
    BOOL sizeAdapted;
}

- (JRSimplePopoverController*)initWithContentViewControllerWithNavigation:(UIViewController*) vc {
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [nc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    CGRect frame = vc.view.frame;
    nc.view.frame = frame;
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:[JRC COMMON_POPUP_BACKGROUND_COLOR]] forBarMetrics:UIBarMetricsDefault];
    
    self = [super initWithContentViewController:nc];
    if (self) {
        withNavigation = YES;
        sizeAdapted = NO;
        self.popoverContentSize = nc.view.frame.size;
        [self setPopoverBackgroundViewClass:[JRSimplePopoverBackgroundView class]];
    }
    return self;
}

- (JRSimplePopoverController*)initWithContentViewController:(UIViewController*)vc {
    self = [super initWithContentViewController:vc];
    if (self) {
        withNavigation = NO;
        self.popoverContentSize = vc.view.frame.size;
        [self setPopoverBackgroundViewClass:[JRSimplePopoverBackgroundView class]];
    }
    return self;
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated manual:(BOOL)manual {
    if (manual) {
        sizeAdapted = NO;
    }
    [self setPopoverContentSize:size animated:animated];
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated {
    if (withNavigation && !sizeAdapted) {
        size.height += 37;
        sizeAdapted = YES;
    }
    [super setPopoverContentSize:size animated:animated];
}

@end
