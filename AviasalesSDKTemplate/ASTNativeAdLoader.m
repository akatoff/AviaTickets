//
//  ASTNativeAdLoader.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Appodeal/AppodealNativeAdService.h>

#import "ASTNativeAdLoader.h"

@interface ASTNativeAdLoader () <AppodealNativeAdServiceDelegate>
@property (strong, nonatomic) AppodealNativeAdService *appodeal;
@property (copy, nonatomic) void (^callback)(ASTNativeAdLoader *, AppodealNativeAd *);
@end

@implementation ASTNativeAdLoader
- (instancetype)init {
    if (self = [super init]) {
        _appodeal = [[AppodealNativeAdService alloc] init];
        _appodeal.delegate = self;
    }
    return self;
}

- (void)loadAd:(void(^)(ASTNativeAdLoader *, AppodealNativeAd *))callback {
    if (callback == nil) {
        return;
    }
    if (self.callback != nil) {
        NSLog(@"ad loading already started");
        return;
    }

    self.callback = callback;

    [_appodeal loadAd];
}

#pragma mark - <AppodealNativeAdServiceDelegate>
- (void)nativeAdServiceDidLoad:(AppodealNativeAd *)nativeAd {
    self.callback(self, nativeAd);
}

- (void)nativeAdServiceDidFailedToLoad {
    self.callback(self, nil);
}
@end

