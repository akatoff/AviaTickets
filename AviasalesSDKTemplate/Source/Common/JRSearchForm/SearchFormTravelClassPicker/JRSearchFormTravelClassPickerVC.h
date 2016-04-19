//
//  JRSearchFormTravelClassPickerVC.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/03/14.
//
//

#import "JRViewController.h"
#import "ASTSearchInfo.h"

@protocol JRSearchFormTravelClassPickerDelegate <NSObject>
- (void)classPickerDidSelectTravelClass;
@end


@interface JRSearchFormTravelClassPickerVC : JRViewController

- (id)initWithDelegate:(id<JRSearchFormTravelClassPickerDelegate>)delegate
            searchInfo:(ASTSearchInfo *)searchInfo;

- (CGSize)contentSize;

@end
