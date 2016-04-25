//
//  JRSearchFormTravelClassPickerCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchFormTravelClassPickerCell.h"

#import "JRC.h"
#import "UIImage+JRUIImage.h"
#import "JRSearchInfoUtils.h"

@interface JRSearchFormTravelClassPickerCell ()

@end

@implementation JRSearchFormTravelClassPickerCell

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)setTravelClass:(JRSDKTravelClass)travelClass {
    _travelClass = travelClass;
    [_travelClassTitleLabel setText:[JRSearchInfoUtils travelClassStringWithTravelClass:_travelClass]];
    [_checkboxImage setHidden:_searchInfo.travelClass == _travelClass ? NO : YES];
}

@end
