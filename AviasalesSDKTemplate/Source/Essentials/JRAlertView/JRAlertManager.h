//
//  JRAlertManager.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRFPPopoverController.h"
#import "JRHintViewController.h"
#import "JRAlert.h"
#import "JRAlertTypes.h"

@interface JRAlertManager : NSObject

+ (JRAlertManager *)sharedManager;

- (JRFPPopoverController *)messagePopoverWithType:(JRMessagePopoverType)popoverType withStringParams:(NSArray *)stringParams andUnderlyingView:(UIView *)underlyingView;
- (JRFPPopoverController *)messagePopoverWithType:(JRMessagePopoverType)popoverType withStringParams:(NSArray *)stringParams andUnderlyingView:(UIView *)underlyingView maxNumberOfShowing:(NSInteger)maxNumberOfShowing;

- (JRAlert *)alertWithId:(JRAlertType)alertType withStringParams:(NSArray *)stringParams andDelegate:(id<JRAlertDelegate>) delegate;
- (JRAlert *)showAlertWithId:(JRAlertType)alertType withStringParams:(NSArray *)stringParams andDelegate:(id<JRAlertDelegate>) delegate;
- (JRAlert *)showAlertWithId:(JRAlertType)alertType withStringParams:(NSArray *)stringParams andBlock:(void (^)(NSInteger clickedButtonAtIndex))actionBlock;

- (BOOL)screenshotsShowNextAlert;
- (BOOL)screenshotsShowNextPopoverUnderlyingView:(UIView *)underlyingView;

@end
