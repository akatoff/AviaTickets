//
//  JRSearchFormPassengersView.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 18/04/14.
//
//

#import "JRSearchFormPassengersView.h"
#import "JRC.h"
#import "JRSearchFormPassengerPickerView.h"
#import "UIImage+ASUIImage.h"
#import "JRAlertManager.h"

@interface JRSearchFormPassengersView ()
@property (nonatomic, strong) NSString *ageText;
@end

@implementation JRSearchFormPassengersView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    [_ellipseImageView setImage:[_ellipseImageView.image imageTintedWithColor:[JRC SF_PASSENGERS_BG]]];
    [_ellipseImageView.layer setBorderWidth:JRPixel()];
    [_ellipseImageView.layer setBorderColor:[JRC WHITE_COLOR].CGColor];
    [_ellipseImageView.layer setCornerRadius:_ellipseImageView.image.size.height/2];
    
    [_minusButton setImage:[[_minusButton imageForState:UIControlStateNormal] imageTintedWithColor:[JRC SF_PASSENGERS_BG]] forState:UIControlStateNormal];
    [_plusButton setImage:[[_plusButton imageForState:UIControlStateNormal] imageTintedWithColor:[JRC SF_PASSENGERS_BG]] forState:UIControlStateNormal];
    
    [_minusButton setImage:[[_minusButton imageForState:UIControlStateNormal] imageTintedWithColor:[JRC SF_PASSENGERS_BG] fraction:0.75] forState:UIControlStateHighlighted];
    [_plusButton setImage:[[_plusButton imageForState:UIControlStateNormal] imageTintedWithColor:[JRC SF_PASSENGERS_BG] fraction:0.75] forState:UIControlStateHighlighted];
}

- (void)setSearchInfo:(ASTSearchInfo *)searchInfo {
    _searchInfo = searchInfo;
    [self updateView];
}

- (void)setType:(JRSearchFormPassengersViewType)type {
    _type = type;
    [self updateView];
    
    _ageText = NSLS(@"JR_SEARCH_FORM_PASSENGERS_OLDER_THEN_12");
    if (_type == JRSearchFormPassengersViewChildrenType) {
        _ageText = NSLS(@"JR_SEARCH_FORM_PASSENGERS_FROM_2_TO_12_YEARS");
    } else if (_type == JRSearchFormPassengersViewInfantsType) {
        _ageText = NSLS(@"JR_SEARCH_FORM_PASSENGERS_UP_TO_2_YEARS");
    }
    _minusButton.accessibilityLabel = [NSString stringWithFormat:NSLS(@"JR_SEARCH_FORM_PASSENGERS_DECREASE_BTN_TITLE_ACC"), _ageText];
    _plusButton.accessibilityLabel = [NSString stringWithFormat:NSLS(@"JR_SEARCH_FORM_PASSENGERS_INCREASE_BTN_TITLE_ACC"), _ageText];
}

- (void)updateView {
    [self checkPassangersLimit];
    UIImage *passengerImage = nil;
    NSString *passengerCountString = nil;
    switch (_type) {
        case JRSearchFormPassengersViewAdultsType: {
            passengerImage = [UIImage imageNamed:@"JRSearchFormAdultPassenger"];
            passengerCountString = [NSString stringWithFormat:@"%@", @(_searchInfo.adults)];
        } break;
        case JRSearchFormPassengersViewChildrenType: {
            passengerImage = [UIImage imageNamed:@"JRSearchFormChildPassenger"];
            passengerCountString = [NSString stringWithFormat:@"%@", @(_searchInfo.children)];
        } break;
        case JRSearchFormPassengersViewInfantsType: {
            passengerImage = [UIImage imageNamed:@"JRSearchFormInfantPassenger"];
            passengerCountString = [NSString stringWithFormat:@"%@", @(_searchInfo.infants)];
        } break;
        default:
            break;
    }
    
    [_passengerImageView setImage:passengerImage];
    [_passengerCount setText:passengerCountString];
    
    _passengerCount.accessibilityLabel = [NSString stringWithFormat:NSLS(@"JR_SEARCH_FORM_PASSENGERS_COUNT_ACC"), _passengerCount.text, _ageText];
    
    _minusButton.accessibilityValue = _plusButton.accessibilityValue = _passengerCount.text;
}

- (IBAction)minusAction:(id)sender {
    
    switch (_type) {
        case JRSearchFormPassengersViewAdultsType: {
            [_searchInfo setAdults:_searchInfo.adults - 1];
        } break;
        case JRSearchFormPassengersViewChildrenType: {
            [_searchInfo setChildren:_searchInfo.children - 1];
        } break;
        case JRSearchFormPassengersViewInfantsType: {
            [_searchInfo setInfants:_searchInfo.infants - 1];
        } break;
        default:
            break;
    }
    [_pickerView.passengerViews makeObjectsPerformSelector:@selector(updateView)];
    
    [_pickerView.delegate passengerViewDidChangePassengers];
}

- (IBAction)plusAction:(id)sender {
    
    switch (_type) {
        case JRSearchFormPassengersViewAdultsType: {
            [_searchInfo setAdults:_searchInfo.adults + 1];
        } break;
        case JRSearchFormPassengersViewChildrenType: {
            [_searchInfo setChildren:_searchInfo.children + 1];
        } break;
        case JRSearchFormPassengersViewInfantsType: {
            NSInteger infants = _searchInfo.infants + 1;
            if (infants <= _searchInfo.adults) {
                [_searchInfo setInfants:infants];
            } else {
                [_pickerView.delegate passengerViewExceededTheAllowableNumberOfInfants];
                if (iPad()) {
                    [self showExceededTheAllowableNumberOfInfantsPopover];
                }
            }
        } break;
        default:
            break;
    }
    [_pickerView.passengerViews makeObjectsPerformSelector:@selector(updateView)];
    
    [_pickerView.delegate passengerViewDidChangePassengers];
}

- (void)checkPassangersLimit {
    NSInteger adultsNumber = _searchInfo.adults;
    NSInteger childrenNumber = _searchInfo.children;
    NSInteger babiesNumber = _searchInfo.infants;
    
    NSInteger maximumSeats = 9;
    NSInteger maximumAdults = maximumSeats - childrenNumber;
    
    
    if (_type == JRSearchFormPassengersViewAdultsType) {
        adultsNumber == maximumAdults ? [_plusButton setEnabled:NO] : [_plusButton setEnabled:YES];
        adultsNumber == 1 ? [_minusButton setEnabled:NO] : [_minusButton setEnabled:YES];
    }
    
    if (_type == JRSearchFormPassengersViewChildrenType) {
        NSInteger maximumChild = maximumSeats - adultsNumber;
        
        childrenNumber == maximumChild ? [_plusButton setEnabled:NO] : [_plusButton setEnabled:YES];
        childrenNumber == 0 ? [_minusButton setEnabled:NO] : [_minusButton setEnabled:YES];
    }
    
    if (_type == JRSearchFormPassengersViewInfantsType) {
        
        if (babiesNumber > adultsNumber) {
            _searchInfo.infants = adultsNumber;
        }
        
        [_plusButton setAlpha: babiesNumber >= adultsNumber ? 0.5 : 1];
        
        babiesNumber == 0 ? [_minusButton setEnabled:NO] : [_minusButton setEnabled:YES];
        
    }
}

- (void)showExceededTheAllowableNumberOfInfantsPopover
{
    JRFPPopoverController *popover = [[JRAlertManager sharedManager] messagePopoverWithType:JRMessagePopoverTypeSearchFormExceededTheAllowableNumberOfInfants withStringParams:nil andUnderlyingView:self.superview];
    [popover setArrowDirection:FPPopoverNoArrow];
    [popover presentPopoverFromView:[[_pickerView passengerViews] objectAtIndex:1]];
    
    __weak JRFPPopoverController *weakError = popover;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakError dismissPopoverAnimated:YES];
    });
}

@end
