//
//  JRSearchFormTravelClassCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchFormTravelClassCell.h"
#import "NSLayoutConstraint+JRConstraintMake.h"
#import "JRSegmentedControl.h"
#import "UIImage+JRUIImage.h"
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
    
    [self setAccessibilityLabelWithNSLSKey:@"SF_TRAVEL_CLASS_CELL"];
}

- (void)updateCell
{
	BOOL isEconomy = self.searchInfo.travelClass == JRSDKTravelClassEconomy || self.searchInfo.travelClass == JRSDKTravelClassPremiumEconomy;
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
}

- (void)segmentedControl:(JRSegmentedControl *)segmentedControl clickedButtonAtIndex:(NSUInteger)buttonIndex {
    [self.searchInfo setTravelClass:buttonIndex == 0 ? JRSDKTravelClassEconomy : JRSDKTravelClassBusiness];
}

- (void)action
{
    [self.item.itemDelegate showTravelClassPickerFromView:_travelClassLabel];
}

@end
