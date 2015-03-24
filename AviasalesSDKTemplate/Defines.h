//
//  Defines.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 01.11.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#ifndef AviasalesSDKTemplate_Defines_h
#define AviasalesSDKTemplate_Defines_h

#define AVIASALES_BUNDLE ([[NSBundle mainBundle] URLForResource:@"AviasalesSDKTemplateBundle" withExtension:@"bundle"] ? [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"AviasalesSDKTemplateBundle" withExtension:@"bundle"]] : [NSBundle mainBundle])

#define AVIASALES_(v) [AVIASALES_BUNDLE localizedStringForKey:(v) value:@"" table:(@"AviasalesTemplateLocalizable")]
#define AVIASALES__(k,v) [AVIASALES_BUNDLE localizedStringForKey:(k) value:(v) table:(@"AviasalesTemplateLocalizable")]

#define AVIASALES_VC_GRANDPA_IS_TABBAR [self.parentViewController.parentViewController respondsToSelector:@selector(tabBar)]

#endif
