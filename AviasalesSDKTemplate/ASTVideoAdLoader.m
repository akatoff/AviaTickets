//
//  ASTVideoAdLoader.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTVideoAdLoader.h"
#import "ASTNativeAdLoader.h"
#import <Appodeal/AppodealNativeMediaView.h>

@interface ASTVideoAdLoader()
@property (strong, nonatomic) ASTNativeAdLoader *nativeAdLoader;
@end

@implementation ASTVideoAdLoader

- (instancetype)init {
    if (self = [super init]) {
        _nativeAdLoader = [[ASTNativeAdLoader alloc] init];
    }
    return self;
}

- (void)loadVideoAd:(void(^)(AppodealNativeMediaView *))callback {
    if (callback == nil) {
        return;
    }

    __weak typeof(self) bself = self;

    [self.nativeAdLoader loadAd:^(AppodealNativeAd *ad) {
        typeof(self) sSelf = bself;
        if (sSelf == nil) {
            return;
        }

        AppodealNativeMediaView *result;

        if (sSelf.rootViewController != nil) {
            result = [[AppodealNativeMediaView alloc] initWithNativeAd:ad andRootViewController: sSelf.rootViewController];
            [result prepareToPlay];
        } else {
            result = nil;
        }

        callback(result);
    }];
}
@end
