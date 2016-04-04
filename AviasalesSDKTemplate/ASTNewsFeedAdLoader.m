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

- (void)loadAd:(void (^)(ASTNewsFeedAdLoader *, AppodealNativeAdView *))callback {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *res = [[UIView alloc] init];
        res.backgroundColor = [UIColor greenColor];
        callback(self, res);
    });
    return;
    //TODO: remove previous lines

    __weak typeof(self) bself = self;
    [self.loader loadAd:^(ASTNativeAdLoader *loader, AppodealNativeAd *ad) {
        typeof(self) sSelf = bself;
        if (sSelf == nil) {
            return;
        }

        AppodealNativeAdView *adView;
        if (sSelf.rootViewController != nil) {
            AppodealNativeAdViewAttributes *const attributes = [[AppodealNativeAdViewAttributes alloc] init];
            adView = [AppodealNativeAdView nativeAdViewWithType:AppodealNativeAdTypeNewsFeed
                                                    andNativeAd:ad
                                                  andAttributes:attributes
                                             rootViewController:sSelf.rootViewController];
        } else {
            adView = nil;
        }

        callback(sSelf, adView);
    }];
}
@end
