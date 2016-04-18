//
//  ASTAdvertisementManager.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Appodeal/Appodeal.h>

#import "ASTAdvertisementManager.h"
#import "ASTVideoAdLoader.h"
#import "ASTVideoAdPlayer.h"
#import "ASTVideoAdPlayerProxy.h"
#import "ASTNewsFeedAdLoader.h"
#import "ASTAviasalesAdLoader.h"

@interface AppodealNativeMediaView() <ASTVideoAdPlayer>
@end

@implementation ASTAdvertisementManager {
    NSMutableSet *_adLoaders;
}

+ (instancetype)sharedInstance {
    static ASTAdvertisementManager *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[ASTAdvertisementManager alloc] init];
    });
    return result;
}

- (instancetype)init {
    if (self = [super init]) {
        _showsAdOnAppStart = YES;
        _showsAdDuringSearch = YES;
        _showsAdOnSearchResults = YES;
        _adLoaders = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)initializeAppodealWithAPIKey:(NSString *)appodealAPIKey {
    [Appodeal initializeWithApiKey:appodealAPIKey
                             types:AppodealAdTypeInterstitial | AppodealAdTypeNativeAd | AppodealAdTypeNonSkippableVideo | AppodealAdTypeNativeAd | AppodealAdTypeSkippableVideo];
}

- (void)presentFullScreenAdFromViewControllerIfNeeded:(UIViewController *)viewController {
    if (!self.showsAdOnAppStart) {
        return;
    }
    [Appodeal showAd:AppodealShowStyleVideoOrInterstitial rootViewController:viewController];
}

- (id<ASTVideoAdPlayer>)presentVideoAdInViewIfNeeded:(UIView *)view
                               rootViewController:(UIViewController *)viewController {
    if (!self.showsAdDuringSearch) {
        return nil;
    }

    ASTVideoAdPlayerProxy *const playerProxy = [[ASTVideoAdPlayerProxy alloc] init];

    ASTVideoAdLoader *const videoLoader = [[ASTVideoAdLoader alloc] init];
    videoLoader.rootViewController = viewController;

    NSMutableSet *const loaders = _adLoaders;
    [loaders addObject:videoLoader];

    [videoLoader loadVideoAd:^(AppodealNativeMediaView *adView) {
        [loaders removeObject:videoLoader];

        if (adView != nil) {
            adView.frame = view.bounds;
            [view addSubview:adView];
            [adView play];
        }

        playerProxy.player = adView;
    }];

    return playerProxy;
}

- (void)viewController:(UIViewController *)viewController
  loadNativeAdWithSize:(CGSize)size
  ifNeededWithCallback:(void (^)(AppodealNativeAdView *))callback {
    if (callback == nil) {
        return;
    }

    if (!self.showsAdOnSearchResults) {
        callback(nil);
    }

    ASTNewsFeedAdLoader *const loader = [[ASTNewsFeedAdLoader alloc] init];
    loader.rootViewController = viewController;

    NSMutableSet *const loaders = _adLoaders;
    [loaders addObject:loader];

    [loader loadAdWithSize:size callback:^(AppodealNativeAdView *adView) {
        [loaders removeObject:loader];
        callback(adView);
    }];
}

- (void)loadAviasalesAdWithSearchParams:(AviasalesSearchParams *)searchParams
                   ifNeededWithCallback:(void(^)(UIView *))callback {
    if (callback == nil) {
        return;
    }
    ASTAviasalesAdLoader *const loader = [[ASTAviasalesAdLoader alloc] initWithSearchParams:searchParams];

    NSMutableSet *const loaders = _adLoaders;
    [loaders addObject:loader];

    [loader loadAdWithCallback:^(UIView *adView) {
        [loaders removeObject:loader];
        callback(adView);
    }];
}

- (void)setTestingEnabled:(BOOL)testingEnabled {
#ifdef DEBUG
    _testingEnabled = testingEnabled;
    [Appodeal setTestingEnabled:testingEnabled];
#endif
}

@end
