//
//  NSLayoutConstraint+JRConstraintMake.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 20/12/13.
//
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (JRConstraintMake)

NSArray *JRConstraintsMakeScaleToFill(id item,
                                      id toItem);

NSArray *JRConstraintsMakeEqualSize(id item,
                                    id toItem);

NSLayoutConstraint *JRConstraintMake(id item,
                                     NSLayoutAttribute attribute,
                                     NSLayoutRelation relation,
                                     id toItem,
                                     NSLayoutAttribute secondAttribute,
                                     CGFloat multiplier,
                                     CGFloat constant);
@end
