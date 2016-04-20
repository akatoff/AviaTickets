//
//  NSLayoutConstraint+JRConstraintMake.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
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
