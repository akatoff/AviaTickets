//
//  JRSearchFormPassengerPickerView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
    
    [self setBackgroundColor:[JRC COMMON_BACKGROUND]];
    
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
