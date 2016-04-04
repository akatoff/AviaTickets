//
//  ASTNativeAdLoader.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppodealNativeAd;

@interface ASTNativeAdLoader : NSObject
- (void)loadAd:(void(^)(ASTNativeAdLoader *, AppodealNativeAd *))callback;
@end
