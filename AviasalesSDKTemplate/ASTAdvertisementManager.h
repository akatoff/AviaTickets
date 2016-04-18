//
//  ASTAdvertisementManager.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ASTVideoAdPlayer;
@class AppodealNativeAdView;
@class AviasalesSearchParams;

@interface ASTAdvertisementManager : NSObject
+ (instancetype)sharedInstance;

@property (assign, nonatomic) BOOL showsAdOnAppStart;
@property (assign, nonatomic) BOOL showsAdDuringSearch;
@property (assign, nonatomic) BOOL showsAdOnSearchResults;

/**
 * Установите YES, чтобы загружать тестовую рекламу
 * Работает только в DEBUG режиме
 */
@property (assign, nonatomic) BOOL testingEnabled;

- (void)initializeAppodealWithAPIKey:(NSString *)appodealAPIKey;

- (void)presentFullScreenAdFromViewControllerIfNeeded:(UIViewController *)viewController;

- (id<ASTVideoAdPlayer>)presentVideoAdInViewIfNeeded:(UIView *)view
                               rootViewController:(UIViewController *)viewController;

- (void)viewController:(UIViewController *)viewController
  loadNativeAdWithSize:(CGSize)size
              ifNeededWithCallback:(void (^)(AppodealNativeAdView *))callback;

- (void)loadAviasalesAdWithSearchParams:(AviasalesSearchParams *)searchParams
                               ifNeededWithCallback:(void(^)(UIView *))callback;
@end
