//
//  ASRaitingStars.m
//

#import "ASRaitingStars.h"
@implementation ASRaitingStars

- (void)setRating:(NSNumber *)rating {
    UIImageView *stars = (UIImageView *)[self viewWithTag:1];
    CGRect starsFrame = stars.frame;
    starsFrame.size.width = 59 / 5 * [rating floatValue];
    [stars setFrame:starsFrame];
}

@end
