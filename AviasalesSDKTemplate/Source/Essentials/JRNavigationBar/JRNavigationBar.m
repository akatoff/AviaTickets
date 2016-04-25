//
//  JRNavigationBar.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRNavigationBar.h"
#import "UIImage+JRUIImage.h"
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
