//
//  Defines.h
//  aviasales
//
//  Created by Всеволод Биллевич on 30.10.11.
//  Copyright 2011 CleverPumpkin. All rights reserved.
//
//  Use this file for keeping settings and constants which are used throughout the project

#ifndef AviasalesSDKTemplate_Defines_h
#define AviasalesSDKTemplate_Defines_h


#define AVIASALES_BUNDLE ([[NSBundle mainBundle] URLForResource:@"AviasalesSDKTemplateBundle" withExtension:@"bundle"] ? [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"AviasalesSDKTemplateBundle" withExtension:@"bundle"]] : [NSBundle mainBundle])

#define AVIASALES_(v) [AVIASALES_BUNDLE localizedStringForKey:(v) value:@"" table:(@"AviasalesTemplateLocalizable")]
#define AVIASALES__(k,v) [AVIASALES_BUNDLE localizedStringForKey:(k) value:(v) table:(@"AviasalesTemplateLocalizable")]

#define AVIASALES_VC_GRANDPA_IS_TABBAR [self.parentViewController.parentViewController respondsToSelector:@selector(tabBar)]


//------------------------
// MACRO
//------------------------

#define JR_ANY_AIRPORT @"ANY"
#define JR_OTHER_ALLIANCES @"OTHER_ALLIANCES"

#define AS_MARKER [[JRUserSettings sharedManager] marker]
#define LOAD_VIEW_FROM_NIB_NAMED(X) [[AVIASALES_BUNDLE loadNibNamed:X owner:self options:nil] objectAtIndex : 0]
#define LANDSCAPE_NAME(X) [NSString stringWithFormat : @"%@_landscape", X]
#define dispatch_main_sync_safe(block) \
if ([NSThread isMainThread]) \
{ \
block(); \
} \
else \
{ \
dispatch_sync(dispatch_get_main_queue(), block); \
}

#define IS_NON_EMPTY_STRING(object) (object && [object isKindOfClass:[NSString class]] && [object length] > 0)

//------------------------
// DEFINES
//------------------------

NSUserDefaults *JRUserDefaults();
CGFloat JRPixel();

//------------------------
// TARGETS & CONFIGURATIONS
//------------------------

BOOL Simulator();
BOOL iPhone();
BOOL iPhone4Inch();
BOOL iPhone35Inch();
BOOL iPhone47Inch();
BOOL iPhone55Inch();
BOOL iPad();

typedef NS_ENUM(NSInteger, DeviceSizeType) {
    DeviceSizeTypeIPhone55Inch, // iPhone 6+
    DeviceSizeTypeIPhone47Inch, // iPhone 6
    DeviceSizeTypeIPhone4Inch,  // iPhone 5, 5c, 5s,
    DeviceSizeTypeIPhone35Inch, // iPhone 4s
    DeviceSizeTypeIPad          // For all iPads
};

DeviceSizeType CurrentDeviceSizeType() __attribute__((const));

BOOL iOSVersionEqualTo(NSString *version);
BOOL iOSVersionGreaterThan(NSString *version);
BOOL iOSVersionGreaterThanOrEqualTo(NSString *version);
BOOL iOSVersionLessThan(NSString *version);
BOOL iOSVersionLessThanOrEqualTo(NSString *version);

CGFloat iPhoneSizeValue(CGFloat defaultValue, CGFloat iPhone6Value, CGFloat iPhone6PlusValue);

BOOL Debug();

//------------------------
// LOCALIZATION
//------------------------

NSString *NSLS(NSString *key);
NSString *NSLSP(NSString *key, float pluralValue);

#endif
