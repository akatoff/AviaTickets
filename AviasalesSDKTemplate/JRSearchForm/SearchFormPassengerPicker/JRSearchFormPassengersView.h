//
//  JRSearchFormPassengersView.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 18/04/14.
//
//

#import <UIKit/UIKit.h>
#import "JRSearchInfo.h"

typedef NS_ENUM (NSUInteger, JRSearchFormPassengersViewType) {
	JRSearchFormPassengersViewAdultsType,
	JRSearchFormPassengersViewChildrenType,
    JRSearchFormPassengersViewInfantsType
};

@class JRSearchFormPassengerPickerView;

@interface JRSearchFormPassengersView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *ellipseImageView;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIImageView *passengerImageView;
@property (weak, nonatomic) IBOutlet UILabel *passengerCount;

@property (weak, nonatomic) JRSearchFormPassengerPickerView *pickerView;
@property (strong, nonatomic) JRSearchInfo *searchInfo;
@property (assign, nonatomic) JRSearchFormPassengersViewType type;

- (void)updateView;

@end
