//
//  JRSwipeDeletionTableViewCell.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 25/03/14.
//
//

#import <UIKit/UIKit.h>
#import "JRTableViewCell.h"

typedef enum : NSUInteger {
    JRSwipeDeletionTableViewCellButtonAnimationTypeDefault = 0,
    JRSwipeDeletionTableViewCellButtonAnimationTypeRotation,
} JRSwipeDeletionTableViewCellButtonAnimationType;

@class JRSwipeDeletionTableViewCell;

@protocol JRSwipeDeletionTableViewCellDelegate <NSObject>
- (void)swipedDeleteButtonClickedInCell:(JRSwipeDeletionTableViewCell *)cell;
@end

@interface JRSwipeDeletionTableViewCell : JRTableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic) JRSwipeDeletionTableViewCellButtonAnimationType swipedButtonAnimationType;
@property (nonatomic, strong) UIImage *swipedButtonImage;
@property (nonatomic, strong) UIColor *swipedViewBackgroundColor;
@property (nonatomic, assign) CGFloat swipedContentViewParallaxRate;
@property (nonatomic, readonly) BOOL swipedButtonIsShowed;
@property (nonatomic) BOOL swipingDisabled;
@property (nonatomic, weak) id<JRSwipeDeletionTableViewCellDelegate> swipeDeletionDelegate;

- (void)swipedButtonShowAnimated:(BOOL)animated;
- (void)swipedButtonHideAnimated:(BOOL)animated;

@end
