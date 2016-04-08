//
//  ASTAviasalesAdLoader.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 08.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTAviasalesAdLoader.h"

#import <AviasalesSDK/AviasalesSDK.h>
#import <AviasalesSDK/AviasalesSearchParams.h>
#import <AviasalesSDK/AviasalesAdvertisementManager.h>

@interface ASTAviasalesAdLoader () <AviasalesAdvertisementManagerDelegate>
@property (strong, nonatomic) AviasalesSearchParams *searchParams;
@property (strong, nonatomic) AviasalesAdvertisementManager *adManager;
@property (strong, nonatomic) void (^callback)(UIView *);
@end

@implementation ASTAviasalesAdLoader

- (instancetype)initWithSearchParams:(AviasalesSearchParams *)searchParams {
    if (self = [super init]) {
        _searchParams = searchParams;
    }
    return self;
}

- (void)loadAdWithCallback:(void (^)(UIView *adView))callback {
    if (self.adManager != nil) {
        return; //Loading has already started
    }

    if (callback == nil) {
        return; //No need to load somesing
    }

    self.callback = callback;
    self.adManager = [[AviasalesSDK sharedInstance] loadAdvertisementWithSearchParams:self.searchParams];
    self.adManager.delegate = self;
}

- (void)dealloc {
    
}

#pragma mark - <AviasalesAdvertisementManagerDelegate>
- (void)advertisementManager:(AviasalesAdvertisementManager *)presenter didLoadAdvertisement:(UIView *)advertisement {
    self.callback(advertisement);
    [self clean];
}

- (void)advertisementManager:(AviasalesAdvertisementManager *)presenter didFailAdLoadingWithError:(NSError *)error {
    self.callback(nil);
    [self clean];
}

#pragma mark - Private
- (void)clean {
    self.callback = nil;
    self.adManager = nil;
}
@end
