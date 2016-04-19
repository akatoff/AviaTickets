//
//  JRSearchFormPassengerPickerVC.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 18/04/14.
//
//

#import "JRSearchFormPassengerPickerVC.h"
#import "NSLayoutConstraint+JRConstraintMake.h"

@interface JRSearchFormPassengerPickerVC ()
@end

@implementation JRSearchFormPassengerPickerVC

- (id)init
{
    self = [super init];
    if (self) {
        _pickerView = LOAD_VIEW_FROM_NIB_NAMED(@"JRSearchFormPassengerPickerView");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_pickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_pickerView];
    [self.view addConstraints:JRConstraintsMakeScaleToFill(_pickerView, self.view)];
}

@end
