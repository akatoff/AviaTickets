//
//  UIView+NSLS.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 20/03/14.
//
//

#import "UIView+NSLS.h"

@implementation UIView (NSLS)

- (void)setNSLSKey:(NSString *)NSLSKey
{
    NSString *localizedString = NSLS(NSLSKey);
    id strongSelf = self;
    if ([strongSelf isKindOfClass:[UILabel class]]) {
        UILabel *label = strongSelf;
        [label setText:localizedString];
    } else if ([strongSelf isKindOfClass:[UIButton class]]) {
        UIButton *button = strongSelf;
        [button setTitle:localizedString forState:UIControlStateNormal];
    }
    
    [self setAccessibilityLabelWithNSLSKey:NSLSKey];
}

@end
