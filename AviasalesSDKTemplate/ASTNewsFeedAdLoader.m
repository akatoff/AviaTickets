//
//  ASTNewsFeedAdLoader.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Appodeal/AppodealNativeAdView.h>
#import "ASTNewsFeedAdLoader.h"
#import "ASTNativeAdLoader.h"

@interface ASTNewsFeedAdLoader ()
@property (strong, nonatomic) ASTNativeAdLoader *loader;
@end

@implementation ASTNewsFeedAdLoader
- (instancetype)init {
    if (self = [super init]) {
        _loader = [[ASTNativeAdLoader alloc] init];
    }
    return self;
}

- (void)loadAdWithSize:(CGSize)size callback:(void(^)(AppodealNativeAdView *))callback {

    __weak typeof(self) bself = self;
    [self.loader loadAd:^(AppodealNativeAd *ad) {
        typeof(self) sSelf = bself;
        if (sSelf == nil) {
            return;
        }

        AppodealNativeAdView *adView;
        if (sSelf.rootViewController != nil) {
            AppodealNativeAdViewAttributes *const attributes = [[AppodealNativeAdViewAttributes alloc] init];
            attributes.width = size.width;
            attributes.heigth = size.height;
            adView = [AppodealNativeAdView nativeAdViewWithType:AppodealNativeAdTypeNewsFeed
                                                    andNativeAd:ad
                                                  andAttributes:attributes
                                             rootViewController:sSelf.rootViewController];
        } else {
            adView = nil;
        }

        callback(adView);
    }];
}
@end
