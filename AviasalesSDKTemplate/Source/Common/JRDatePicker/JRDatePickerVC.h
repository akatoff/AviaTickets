//
//  JRDatePickerVC.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRViewController.h"
#import "JRDatePickerStateObject.h"

@class JRDatePickerVC;

@protocol JRDatePickerDelegate <NSObject>
@optional
- (void)datePicker:(JRDatePickerVC *)datePickerVC didSelectDepartDate:(NSDate *)departDate inTravelSegment:(JRTravelSegment *)travelSegment;
@end

@interface JRDatePickerVC : JRViewController

- (instancetype)initWithSearchInfo:(JRSearchInfo *)searchInfo
                     travelSegment:(JRTravelSegment *)travelSegment
                              mode:(JRDatePickerMode)mode;

- (instancetype)initWithSearchInfo:(JRSearchInfo *)searchInfo
                     travelSegment:(JRTravelSegment *)travelSegment
                              mode:(JRDatePickerMode)mode
           shouldShowSearchToolbar:(BOOL)shouldShowSearchToolbar;

@property (nonatomic, weak) UIPopoverController *parentPopoverController;

@property (nonatomic, weak) id<JRDatePickerDelegate> delegate;

@end
