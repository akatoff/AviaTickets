#import <Foundation/Foundation.h>
#import "ASTGate.h"


@interface ASTPrice : NSObject <JRSDKPrice>

@property (nonatomic, retain) ASTGate *gate;

@end