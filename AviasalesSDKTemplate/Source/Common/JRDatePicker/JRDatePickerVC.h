//
//  JRDatePickerVC.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 04/02/14.
//
//

#import "JRViewController.h"
#import "JRDatePickerStateObject.h"

@class JRDatePickerVC;

@protocol JRDatePickerDelegate <NSObject>
@optional
- (void)datePicker:(JRDatePickerVC *)datePickerVC didSelectDepartDate:(NSDate *)departDate inTravelSegment:(ASTTravelSegment *)travelSegment;
@end

@interface JRDatePickerVC : JRViewController

- (instancetype)initWithSearchInfo:(ASTSearchInfo *)searchInfo
                     travelSegment:(ASTTravelSegment *)travelSegment
                              mode:(JRDatePickerMode)mode;

- (instancetype)initWithSearchInfo:(ASTSearchInfo *)searchInfo
                     travelSegment:(ASTTravelSegment *)travelSegment
                              mode:(JRDatePickerMode)mode
           shouldShowSearchToolbar:(BOOL)shouldShowSearchToolbar;

@property (nonatomic, weak) UIPopoverController *parentPopoverController;

@property (nonatomic, weak) id<JRDatePickerDelegate> delegate;

@end
