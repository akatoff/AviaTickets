//
//  JRAlertView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRAlertTypes.h"

@class JRAlert;

@protocol JRAlertDelegate <NSObject>
@optional
- (void)alert:(JRAlert *)alert withId:(JRAlertType)alertType clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface JRAlert : UIViewController

- (id)initWithMessage:(NSString *)message;
- (void)show;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
- (void)addButtonWithTitle:(NSString *)title andBlock:(void (^)(void))actionBlock bold:(BOOL)bold;
- (void)addButtonWithTitle:(NSString *)title andBlock:(void (^)(void))actionBlock;

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) BOOL showedImage;
@property (nonatomic) BOOL allowedShowSameAlerts;
@property (nonatomic, readonly) BOOL visible;
@property (nonatomic, weak) id<JRAlertDelegate> delegate;
@property (nonatomic, copy) void (^commonActionBlock)(NSInteger clickedButtonIndex);
@property (nonatomic) JRAlertType alertType;

@end
