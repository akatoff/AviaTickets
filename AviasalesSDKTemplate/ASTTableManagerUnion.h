//
//  ASTTableManagerUnion.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTTableManager.h"

/**
 * Works with one cell per section
 */
@interface ASTTableManagerUnion : NSObject <ASTTableManager>
@property (strong, nonatomic) NSIndexSet *secondManagerPositions;

- (instancetype)initWithFirstManager:(id<ASTTableManager>)firstManager
                       secondManager:(id<ASTTableManager>)secondManager
              secondManagerPositions:(NSIndexSet *)secondManagerPositions;
@end
