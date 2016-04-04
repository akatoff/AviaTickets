//
//  ASTNewsFeedAdLoader.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppodealNativeAdView;

@interface ASTNewsFeedAdLoader : NSObject
@property (weak, nonatomic) UIViewController *rootViewController;
- (void)loadAd:(void(^)(ASTNewsFeedAdLoader *, AppodealNativeAdView *))callback;
@end
