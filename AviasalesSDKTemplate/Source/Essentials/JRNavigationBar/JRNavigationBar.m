//
//  JRNavigationBar.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 06/03/14.
//
//

#import "JRNavigationBar.h"
#import "UIImage+ASUIImage.h"
#import "JRC.h"

@implementation JRNavigationBar

- (void)setTranslucent:(BOOL)translucent {
    [super setTranslucent:translucent];
    if (self.translucent) {
        [self setBackgroundImage:[UIImage imageWithColor:[[JRC NAVIGATION_BAR_BACKGROUND_COLOR] colorWithAlphaComponent:kJRNavigationBarTranslucentAlpha]] forBarMetrics:UIBarMetricsDefault];
    } else {
        [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
}

@end
