//
//  JRSearchResultsSortCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/03/14.
//
//

#import <UIKit/UIKit.h>
#import "JRSearchInfoUtils.h"
#import "JRTableViewCell.h"

@interface JRSearchFormTravelClassPickerCell : JRTableViewCell

@property (weak, nonatomic) JRSearchInfo *searchInfo;
@property (assign, nonatomic) JRTravelClass travelClass;
@property (weak, nonatomic) IBOutlet UILabel *travelClassTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImage;

@end
