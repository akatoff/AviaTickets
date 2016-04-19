//
//  JRSearchFormTravelClassCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 21/01/14.
//
//

#import "JRSearchFormTravelClassCell.h"
#import "NSLayoutConstraint+JRConstraintMake.h"
#import "JRSegmentedControl.h"
#import "UIImage+ASUIImage.h"
#import "JRC.h"
#import "JRSearchInfoUtils.h"

#define kJRSearchFormTravelClassCellAnimationDuration 0.15

@interface JRSearchFormTravelClassCell ()<JRSegmentedControlDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *travelClassImageContainer;
@property (weak, nonatomic) IBOutlet UILabel *travelClassLabel;
@property (weak, nonatomic) IBOutlet UIView *segmentControlContainer;
@property (strong, nonatomic) JRSegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UIImageView *travelClassIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeftMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *travelClassLabelLeftMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowsRightMarginConstraint;
@end

@implementation JRSearchFormTravelClassCell {
	UIImageView *_travelClassImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _travelClassIcon.image = [_travelClassIcon.image imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]];
    
    if (Aviasales() && iPad()) {
        
        _segControl = [[JRSegmentedControl alloc] initWithItems:@[NSLS(@"JR_SEARCHINFO_ECONOMY"), NSLS(@"JR_SEARCHINFO_BUSINESS")]];
        [_segControl setDelegate:self];
        
        
        [_segControl setSegmentedControlStyle:JRSegmentedControlStyleRoundContent];
        [_segControl setSegmentLabelFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
        [_segControl setSegmentNormalLabelFont:[UIFont fontWithName:@"HelveticaNeue" size:17.5]];
        [_segControl setRibbonTintColor:[JRC WHITE_COLOR]];
        [_segControl setSegmentedControlStrokeColor:[JRC SF_SEGMENTED_CONTROL_BACKGROUND_COLOR]];
        [_segControl setSegmentTitleTintColor:[JRC SF_SEGMENTED_CONTROL_BACKGROUND_COLOR]];
        [_segControl setSegmentStrokeColor:[JRC SF_SEGMENTED_CONTROL_BACKGROUND_COLOR]];
        [_segControl setSegmentTitleTintColor:[JRC THEME_COLOR]];
        [_segControl setSegmentNormalTitleTintColor:[JRC SF_SEGMENTED_CONTROL_SEGMENT_TITLE_TINT]];
        
        [_segmentControlContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_segmentControlContainer addSubview:_segControl];
        [_segmentControlContainer setBackgroundColor:nil];
        
        [_segControl selectSegmentAtIndex:0 animated:NO];
    }
    
    if (JetRadar() && iPad()) {
        _imageViewLeftMarginConstraint.constant = _travelClassLabelLeftMarginConstraint.constant = 20.0f;
        _arrowsRightMarginConstraint.constant = 38.0f;
    }
    
    [self setAccessibilityLabelWithNSLSKey:@"SF_TRAVEL_CLASS_CELL"];
    if (iPad()) {
        self.isAccessibilityElement = NO;
    }
}

- (void)updateCell
{
	BOOL isEconomy = self.searchInfo.travelClass == JRTravelClassEconomy || self.searchInfo.travelClass == JRTravelClassPremiumEconomy;
	UIImage *image = [UIImage imageNamed:isEconomy ? @"JRSearchFormTravelClassEconomy" : @"JRSearchFormTravelClassBusiness"];
    image = [image imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]];
    
	if (_travelClassImage == nil && _travelClassImageContainer != nil) {
		_travelClassImage = [[UIImageView alloc] initWithImage:image];
		[_travelClassImage setContentMode:UIViewContentModeCenter];
		[_travelClassImage setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_travelClassImageContainer addSubview:_travelClassImage];
		[_travelClassImageContainer addConstraints:JRConstraintsMakeScaleToFill(_travelClassImage, _travelClassImageContainer)];
	}
	[_travelClassImage setImage:image];
	[_travelClassLabel setText:[JRSearchInfoUtils travelClassStringWithTravelClass:self.searchInfo.travelClass]];
    if (Aviasales() && iPad()) {
        [_segControl selectSegmentAtIndex:isEconomy ? 0 : 1 animated:NO];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

- (void)segmentedControl:(JRSegmentedControl *)segmentedControl clickedButtonAtIndex:(NSUInteger)buttonIndex {
    [self.searchInfo setTravelClass:buttonIndex == 0 ? JRTravelClassEconomy : JRTravelClassBusiness];
}

- (void)action
{
    if (iPad() && Aviasales()) {
        return;
    }
    
    if (Aviasales()) {
        BOOL isEconomy = self.searchInfo.travelClass == JRTravelClassEconomy;
        [self.searchInfo setTravelClass:isEconomy ? JRTravelClassBusiness : JRTravelClassEconomy];
        [self updateCell];
        
        [CATransaction begin];
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:isEconomy ? kCATransitionFromTop : kCATransitionFromBottom];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:kJRSearchFormTravelClassCellAnimationDuration];
        [_travelClassImage.layer addAnimation:animation forKey:@"kCATransition"];
        [_travelClassLabel.layer addAnimation:animation forKey:@"kCATransition"];
        
        __weak __typeof(& *self
                        ) weakSelf = self;
        double delayInSeconds = kJRSearchFormTravelClassCellAnimationDuration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.item.itemDelegate travelClassDidSelect];
        });
    } else {
        [self.item.itemDelegate showTravelClassPickerFromView:_travelClassLabel];
    }
}

@end
