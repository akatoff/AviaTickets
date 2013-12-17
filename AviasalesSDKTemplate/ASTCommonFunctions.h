//
//  ASTCommonFunctions.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 22.10.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASTCommonFunctions : NSObject

+ (NSString *)formatPrice:(NSNumber *)price;
+ (NSString *)choosePluralForNumber:(NSInteger)num from:(NSString *)one andFrom:(NSString *)two andFrom:(NSString *)five;

@end
