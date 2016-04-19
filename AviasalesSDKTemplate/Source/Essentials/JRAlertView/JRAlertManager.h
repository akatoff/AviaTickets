//
//  JRAlertManager.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 01/10/14.
//  Copyright (c) 2014 aviasales. All rights reserved.
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
