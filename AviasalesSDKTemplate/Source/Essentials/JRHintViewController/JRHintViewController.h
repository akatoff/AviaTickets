//
//  JRHintViewController.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 08/04/14.
//
//

#import <UIKit/UIKit.h>

@interface JRHintViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
- (id)initWithText:(NSString *)text andTitle:(NSString *)title;
@end
