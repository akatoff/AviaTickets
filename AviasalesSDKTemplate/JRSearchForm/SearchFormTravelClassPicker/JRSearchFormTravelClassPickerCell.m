//
//  JRSearchResultsSortCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/03/14.
//
//

#import "JRSearchFormTravelClassPickerCell.h"

#import "JRC.h"
#import "UIImage+ASUIImage.h"
@interface JRSearchFormTravelClassPickerCell ()

@end

@implementation JRSearchFormTravelClassPickerCell

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)setTravelClass:(JRTravelClass)travelClass {
    _travelClass = travelClass;
    [_travelClassTitleLabel setText:[JRSearchInfoUtils travelClassStringWithTravelClass:_travelClass]];
    [_checkboxImage setHidden:_searchInfo.travelClass == _travelClass ? NO : YES];
}

@end
