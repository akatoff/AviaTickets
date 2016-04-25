//
//  NSLayoutConstraint+JRConstraintMake.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "NSLayoutConstraint+JRConstraintMake.h"
#import "JRLayoutConstraint.h"

@implementation NSLayoutConstraint (JRConstraintMake)

NSArray *JRConstraintsMakeScaleToFill(id item,
                                    id toItem) {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeTop, NSLayoutRelationEqual, toItem, NSLayoutAttributeTop, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeLeft, NSLayoutRelationEqual, toItem, NSLayoutAttributeLeft, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeBottom, NSLayoutRelationEqual, toItem, NSLayoutAttributeBottom, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeRight, NSLayoutRelationEqual, toItem, NSLayoutAttributeRight, 1, 0)];
    return constraints;
}

NSArray *JRConstraintsMakeEqualSize(id item,
                                    id toItem) {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeWidth, NSLayoutRelationEqual, toItem, NSLayoutAttributeWidth, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeHeight, NSLayoutRelationEqual, toItem, NSLayoutAttributeHeight, 1, 0)];
    return constraints;
}

NSLayoutConstraint *JRConstraintMake(id item,
                                     NSLayoutAttribute attribute,
                                     NSLayoutRelation relation,
                                     id toItem,
                                     NSLayoutAttribute secondAttribute,
                                     CGFloat multiplier,
                                     CGFloat constant) {
    
    NSLayoutConstraint *constaint = [JRLayoutConstraint constraintWithItem:item
                                        attribute:attribute
                                        relatedBy:relation
                                           toItem:toItem
                                        attribute:secondAttribute
                                       multiplier:multiplier
                                         constant:constant];
    return constaint;
}

@end
