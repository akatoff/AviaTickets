#import <Foundation/Foundation.h>


@interface ASTTravelSegment : NSObject <JRSDKTravelSegment>

- (BOOL)isValidSegment;

#pragma mark - Copying

- (ASTTravelSegment *)copy;

@end