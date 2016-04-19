//
//  JRAlertManager.m
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 01/10/14.
//  Copyright (c) 2014 aviasales. All rights reserved.
//

#import "JRAlertManager.h"
#import "JRC.h"


#define AS_SK_NUMBER_OF_HINTS_SHOWING @"AS_SK_NUMBER_OF_HINTS_SHOWING"


@interface JRAlertManager ()
@property (nonatomic, strong) JRFPPopoverController *popover;
@end

@implementation JRAlertManager

+ (JRAlertManager *)sharedManager
{
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (JRFPPopoverController *)hintPopoverWithUnderlyingView:(UIView *)underlyingView andMessage:(NSString *)message andTitle:(NSString *)title textAlignment:(NSTextAlignment)textAlignment {
    JRHintViewController *hintVC = [[JRHintViewController alloc] initWithText:message andTitle:title];
    _popover = [[JRFPPopoverController alloc] initWithViewController:hintVC delegate:nil underlyingView:underlyingView];
    _popover.hideOnTouch = YES;
    [_popover setBlurTintColor:[JRC COMMON_HINT_POPOVER_BLUR_TINT]];
    [_popover setArrowDirection:FPPopoverNoArrow];
    [_popover setContentSize:hintVC.view.frame.size];
    
    hintVC.textLabel.textAlignment = textAlignment;
    
    return _popover;
}

- (JRFPPopoverController *)messagePopoverWithType:(JRMessagePopoverType)popoverType withStringParams:(NSArray *)stringParams andUnderlyingView:(UIView *)underlyingView
{
    JRFPPopoverController *popover = nil;
    
    switch (popoverType) {
            /* Search form */
            
        case JRMessagePopoverTypeSearchFormExceededTheAllowableNumberOfInfants: {
            popover = [self hintPopoverWithUnderlyingView:underlyingView andMessage:NSLS(@"JR_SEARCH_FORM_EXCEEDED_THE_ALLOWABLE_NUMBER_OF_INFANTS") andTitle:nil textAlignment:0];
            break;
        }
            
        case JRMessagePopoverTypeSearchFormEmptyOriginError:
            popover = [self hintPopoverWithUnderlyingView:underlyingView andMessage:NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_ORIGIN_ERROR") andTitle:nil textAlignment:0];
            break;
            
        case JRMessagePopoverTypeSearchFormEmptyDestinationAirportError:
            popover = [self hintPopoverWithUnderlyingView:underlyingView andMessage:NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_DESTINATION_ERROR") andTitle:nil textAlignment:0];
            break;
            
        case JRMessagePopoverTypeSearchFormSameCityError:
            popover = [self hintPopoverWithUnderlyingView:underlyingView andMessage:NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_SAME_CITY_ERROR") andTitle:nil textAlignment:0];
            break;
            
        case JRMessagePopoverTypeSearchFormEmptyDepartureAirportError:
            popover = [self hintPopoverWithUnderlyingView:underlyingView andMessage:NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_DEPARTURE_DATE") andTitle:nil textAlignment:0];
            break;
            
        default:
            break;
    }
    
    return popover;
}

- (JRFPPopoverController *)messagePopoverWithType:(JRMessagePopoverType)popoverType withStringParams:(NSArray *)stringParams andUnderlyingView:(UIView *)underlyingView maxNumberOfShowing:(NSInteger)maxNumberOfShowing
{
    static NSMutableDictionary *wasShowingHints;
    if (!wasShowingHints) {
        wasShowingHints = [NSMutableDictionary dictionary];
    }
    if (maxNumberOfShowing > 0) {
        NSString *hintStorageKey = [NSString stringWithFormat:@"popover_%@", @(popoverType)];
        NSInteger currentNumberOfShowing = 0;
        id storageData = [JRUserDefaults() valueForKey:AS_SK_NUMBER_OF_HINTS_SHOWING];
        NSMutableDictionary *numberOfShowings = [NSMutableDictionary dictionary];
        if ([storageData isKindOfClass:[NSDictionary class]]) {
            numberOfShowings = [(NSDictionary *)storageData mutableCopy];
            currentNumberOfShowing = [[numberOfShowings objectForKey:hintStorageKey] integerValue];
        }
        if (![[wasShowingHints objectForKey:hintStorageKey] boolValue] && currentNumberOfShowing < maxNumberOfShowing) {
            currentNumberOfShowing++;
            [numberOfShowings setObject:@(currentNumberOfShowing) forKey:hintStorageKey];
            [JRUserDefaults() setValue:[numberOfShowings copy] forKey:AS_SK_NUMBER_OF_HINTS_SHOWING];
            [JRUserDefaults() synchronize];
            [wasShowingHints setObject:@(1) forKey:hintStorageKey];
            return [self messagePopoverWithType:popoverType withStringParams:stringParams andUnderlyingView:underlyingView];
        }
        return nil;
    } else {
        return [self messagePopoverWithType:popoverType withStringParams:stringParams andUnderlyingView:underlyingView];
    }
}

#pragma mark alerts

- (JRAlert *)showAlertWithId:(JRAlertType)alertType withStringParams:(NSArray *)stringParams andDelegate:(id<JRAlertDelegate>) delegate
{
    JRAlert *alert = [self alertWithId:alertType withStringParams:stringParams andDelegate:delegate];
    [alert show];
    
    return alert;
}

- (JRAlert *)showAlertWithId:(JRAlertType)alertType withStringParams:(NSArray *)stringParams andBlock:(void (^)(NSInteger clickedButtonAtIndex))actionBlock {
    JRAlert *alert = [self alertWithId:alertType withStringParams:stringParams andDelegate:nil andBlock:actionBlock];
    [alert show];
    
    return alert;
}

- (JRAlert *)alertWithId:(JRAlertType)alertType withStringParams:(NSArray *)stringParams andDelegate:(id<JRAlertDelegate>) delegate {
    return [self alertWithId:alertType withStringParams:stringParams andDelegate:delegate andBlock:nil];
}

- (JRAlert *)alertWithId:(JRAlertType)alertType withStringParams:(NSArray *)stringParams andDelegate:(id<JRAlertDelegate>) delegate andBlock:(void (^)(NSInteger clickedButtonAtIndex))actionBlock
{
    JRAlert *alert = nil;
    switch (alertType) {
        case JRAlertTypeWithText:
            alert = [[JRAlert alloc] initWithMessage:stringParams.firstObject];
            break;
        
        default:
            break;
    }
    
    if (alert) {
        alert.delegate = delegate;
        alert.alertType = alertType;
        if (actionBlock) {
            alert.commonActionBlock = actionBlock;
        }
    } else if (Debug()) {
        [NSException raise:@"Incorrect alert!" format:@"Not found alert!"];
    }
    
    return alert;
}

#pragma mark screenshots

- (BOOL)screenshotsShowNextAlert
{
    static int alertId = 1;
    
    JRAlert *alert = [self showAlertWithId:alertId withStringParams:@[@"[first string]", @"[second string]", @"[third string]", @"[fourth string]", @"[fifth string]"] andDelegate:nil];
    if (alert) {
        alertId++;
        return YES;
    } else {
        alertId = 1;
        return NO;
    }
}

- (BOOL)screenshotsShowNextPopoverUnderlyingView:(UIView *)underlyingView
{
    static int popoverId = 1;
    
    JRFPPopoverController *popover = [self messagePopoverWithType:popoverId withStringParams:@[@"[first string]", @"[second string]", @"[third string]", @"[fourth string]", @"[fifth string]"] andUnderlyingView:underlyingView];
    if (popover) {
        popoverId++;
        
        [popover presentPopoverFromPoint:CGPointMake(underlyingView.frame.size.width/2, underlyingView.frame.size.height/2 + 100)];
        
        return YES;
    } else {
        popoverId = 1;
        return NO;
    }
}

@end
