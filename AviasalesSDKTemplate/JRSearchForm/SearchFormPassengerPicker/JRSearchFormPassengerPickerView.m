//
//  JRSearchFormPassengerPickerView.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 18/04/14.
//
//

#import "JRSearchFormPassengerPickerView.h"
#import "JRSearchFormPassengersView.h"
#import "NSLayoutConstraint+JRConstraintMake.h"
#import "JRC.h"

@interface JRSearchFormPassengerPickerView ()

@property (weak, nonatomic) IBOutlet UIView *adultsContainer;
@property (weak, nonatomic) IBOutlet UIView *childrenContainer;
@property (weak, nonatomic) IBOutlet UIView *infantsContainer;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation JRSearchFormPassengerPickerView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_okButton setBackgroundColor:[JRC SF_CELL_IMAGES_TINT]];
    
    [self setBackgroundColor:iPhone() ? [JRC COMMON_BACKGROUND] : [JRC CLEAR_COLOR]];
    
    [_adultsContainer setBackgroundColor:[JRC CLEAR_COLOR]];
    JRSearchFormPassengersView *adulstView = LOAD_VIEW_FROM_NIB_NAMED(@"JRSearchFormPassengersView");
    [_adultsContainer addSubview:adulstView];
    [_adultsContainer addConstraints:JRConstraintsMakeScaleToFill(adulstView, _adultsContainer)];
    [adulstView setType:JRSearchFormPassengersViewAdultsType];
    
    [_childrenContainer setBackgroundColor:[JRC CLEAR_COLOR]];
    JRSearchFormPassengersView *childrenView = LOAD_VIEW_FROM_NIB_NAMED(@"JRSearchFormPassengersView");
    [_childrenContainer addSubview:childrenView];
    [_childrenContainer addConstraints:JRConstraintsMakeScaleToFill(childrenView, _childrenContainer)];
    [childrenView setType:JRSearchFormPassengersViewChildrenType];
    
    [_infantsContainer setBackgroundColor:[JRC CLEAR_COLOR]];
    JRSearchFormPassengersView *infantsView = LOAD_VIEW_FROM_NIB_NAMED(@"JRSearchFormPassengersView");
    [_infantsContainer addSubview:infantsView];
    [_infantsContainer addConstraints:JRConstraintsMakeScaleToFill(infantsView, _infantsContainer)];
    [infantsView setType:JRSearchFormPassengersViewInfantsType];
    
    _passengerViews = @[adulstView, childrenView, infantsView];
    [_passengerViews makeObjectsPerformSelector:@selector(setPickerView:) withObject:self];
}

- (void)setSearchInfo:(JRSearchInfo *)searchInfo {
    _searchInfo = searchInfo;
    [_passengerViews makeObjectsPerformSelector:@selector(setSearchInfo:) withObject:_searchInfo];
}

- (IBAction)buttonAction:(id)sender {
    [_delegate passengerViewDismiss];
}

@end
