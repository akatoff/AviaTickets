//
//  JRSearchFormPassengerPickerView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRSearchInfo.h"

@protocol JRSearchFormPassengerPickerViewDelegate<NSObject>
@required
- (void)passengerViewDismiss;
- (void)passengerViewDidChangePassengers;
- (void)passengerViewExceededTheAllowableNumberOfInfants;
@end

@interface JRSearchFormPassengerPickerView : UIView

@property (strong, nonatomic) id<JRSearchFormPassengerPickerViewDelegate>delegate;
@property (strong, nonatomic) JRSearchInfo *searchInfo;

@property (strong, nonatomic) NSArray *passengerViews;

@end
