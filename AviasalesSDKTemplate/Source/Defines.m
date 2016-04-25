//
//  Defines.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "Defines.h"
#import <Foundation/Foundation.h>
#import "SLLocalization.h"

//------------------------
// DEFINES
//------------------------

NSUserDefaults *JRUserDefaults() {
    return [NSUserDefaults standardUserDefaults];
}

CGFloat JRPixel() {
    return 1.0f / [UIScreen mainScreen].scale;
}

//------------------------
// TARGETS & CONFIGURATIONS
//------------------------

BOOL Simulator() {
    return [[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"];
}

BOOL iPhone() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

BOOL iPhoneWithHeight(CGFloat height) {
    CGSize screneSize = [[ UIScreen mainScreen ] bounds ].size;
    return iPhone() && (fabs( ( double ) MAX(screneSize.width, screneSize.height) - ( double )height ) < DBL_EPSILON );
}

BOOL iPhone4Inch() {
    return iPhoneWithHeight(568);
}
BOOL iPhone35Inch() {
    return iPhoneWithHeight(480);
}
BOOL iPhone47Inch() {
    return iPhoneWithHeight(667);
}
BOOL iPhone55Inch() {
    return iPhoneWithHeight(736);
}

BOOL iPad() {
    return (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad);
}

DeviceSizeType __attribute__((const))  CurrentDeviceSizeType() {
    static BOOL wasTypeDefined = NO;
    static DeviceSizeType res;
    if (wasTypeDefined) {
        return res;
    } else {
        res = iPad()    ?   DeviceSizeTypeIPad :
        iPhone55Inch()  ?   DeviceSizeTypeIPhone55Inch:
        iPhone47Inch()  ?   DeviceSizeTypeIPhone47Inch:
        iPhone4Inch()   ?   DeviceSizeTypeIPhone4Inch:
        /* otherwise */     DeviceSizeTypeIPhone35Inch;
        
        wasTypeDefined = YES;
        return res;
    }
}

BOOL iOSVersionEqualTo(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame);
}

BOOL iOSVersionGreaterThan(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending);
}

BOOL iOSVersionGreaterThanOrEqualTo(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending);
}

BOOL iOSVersionLessThan(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending);
}
BOOL iOSVersionLessThanOrEqualTo(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending);
}

CGFloat iPhoneSizeValue(CGFloat defaultValue, CGFloat iPhone6Value, CGFloat iPhone6PlusValue) {
    switch (CurrentDeviceSizeType()) {
        case DeviceSizeTypeIPad:
        case DeviceSizeTypeIPhone55Inch:
            return iPhone6PlusValue;
        case DeviceSizeTypeIPhone47Inch:
            return iPhone6Value;
        default:
            return defaultValue;
    }
}

BOOL Debug() {
#if DEBUG
    return YES;
#else
    return NO;
#endif
}

//------------------------
// LOCALIZATION
//------------------------

NSString *NSLS(NSString *key) {
    return [[NSBundle mainBundle] localizedStringForKey :key value : @"" table : nil];
}

NSString *NSLSP(NSString *key, float pluralValue) {
    return SLPluralizedString(key, pluralValue, nil);
}
