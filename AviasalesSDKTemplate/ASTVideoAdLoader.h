//
//  ASTVideoAdLoader.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppodealNativeMediaView;

@interface ASTVideoAdLoader : NSObject
@property (weak, nonatomic) UIViewController *rootViewController;
- (void)loadVideoAd:(void(^)(AppodealNativeMediaView *))callback;
@end
