//
//  JRSearchFormTravelClassPickerVC.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
