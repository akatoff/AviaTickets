//
//  ASPopoverController.h
//  aviasales
//
//  Created by Andrey Zakharevich on 04.02.13.
//
//

#import <UIKit/UIKit.h>

@interface JRSimplePopoverController : UIPopoverController

- (JRSimplePopoverController*)initWithContentViewControllerWithNavigation:(UIViewController*) vc;

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated manual:(BOOL)manual;

@end
