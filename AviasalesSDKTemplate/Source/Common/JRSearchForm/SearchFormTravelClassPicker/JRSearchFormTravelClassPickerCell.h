//
//  JRSearchFormTravelClassPickerCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRTableViewCell.h"
#import "JRSearchInfo.h"

@interface JRSearchFormTravelClassPickerCell : JRTableViewCell

@property (weak, nonatomic) JRSearchInfo *searchInfo;
@property (assign, nonatomic) JRSDKTravelClass travelClass;
@property (weak, nonatomic) IBOutlet UILabel *travelClassTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImage;

@end
