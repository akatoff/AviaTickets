//
//  JRPrice.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRGate.h"


@interface JRPrice : NSObject <JRSDKPrice>

@property (nonatomic, retain) JRGate *gate;

@end