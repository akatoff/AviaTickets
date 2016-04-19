//
//  JRSearchFormTravelClassPickerVC.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/03/14.
//
//

#import "JRViewController.h"
#import "JRSearchInfo.h"

@protocol JRSearchFormTravelClassPickerDelegate <NSObject>
- (void)classPickerDidSelectTravelClass;
@end


@interface JRSearchFormTravelClassPickerVC : JRViewController

- (id)initWithDelegate:(id<JRSearchFormTravelClassPickerDelegate>)delegate
            searchInfo:(JRSearchInfo *)searchInfo;

- (CGSize)contentSize;

@end
