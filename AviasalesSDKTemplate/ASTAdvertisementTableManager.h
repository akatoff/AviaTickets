//
//  ASTAdvertisementTableManager.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTTableManager.h"

@interface ASTAdvertisementTableManager : NSObject <ASTTableManager>
@property (strong, nonatomic) NSArray<UIView *> *ads;
+ (CGFloat)appodealAdHeight;
@end
