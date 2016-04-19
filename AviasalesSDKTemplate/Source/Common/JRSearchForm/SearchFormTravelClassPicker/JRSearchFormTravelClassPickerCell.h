//
//  JRSearchResultsSortCell.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/03/14.
//
//

#import <UIKit/UIKit.h>
#import "JRTableViewCell.h"
#import "ASTSearchInfo.h"

@interface JRSearchFormTravelClassPickerCell : JRTableViewCell

@property (weak, nonatomic) ASTSearchInfo *searchInfo;
@property (assign, nonatomic) JRSDKTravelClass travelClass;
@property (weak, nonatomic) IBOutlet UILabel *travelClassTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImage;

@end
