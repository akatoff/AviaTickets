//
//  JRSearchFormPassengerPickerView.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 18/04/14.
//
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
