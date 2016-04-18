//
//  ASTAviasalesAdLoader.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 08.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AviasalesSearchParams;

@interface ASTAviasalesAdLoader : NSObject
- (instancetype)initWithSearchParams:(AviasalesSearchParams *)searchParams;

/**
 * callback - returns nil if error occured
 */
- (void)loadAdWithCallback:(void (^)(UIView *adView))callback;
@end
