//
//  ASTVideoAdPlayerProxy.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTVideoAdPlayerProxy.h"

@implementation ASTVideoAdPlayerProxy {
    BOOL _interrupted;
}

- (void)setPlayer:(id<ASTVideoAdPlayer>)player {
    _player = player;
    if (_interrupted) {
        [player stop];
    }
}

#pragma mark - <VideoAdPlayer>

- (void)stop {
    _interrupted = YES;
    [self.player stop];
}

@end
