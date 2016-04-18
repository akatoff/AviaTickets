//
//  ASTVideoAdPlayerProxy.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASTVideoAdPlayer.h"

@interface ASTVideoAdPlayerProxy : NSObject <ASTVideoAdPlayer>
@property (strong, nonatomic, nullable) id<ASTVideoAdPlayer> player;
@end
