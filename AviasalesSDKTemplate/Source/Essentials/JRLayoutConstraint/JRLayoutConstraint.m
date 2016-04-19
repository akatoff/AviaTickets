//
//  JRLayoutConstraint.m
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 03/06/15.
//  Copyright (c) 2015 aviasales. All rights reserved.
//

#import "JRLayoutConstraint.h"

@implementation JRLayoutConstraint

+ (instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c {

    //fix ios 8.3 crash
    if (!view2 && attr2 != NSLayoutAttributeNotAnAttribute) {
        JRLayoutConstraint *dummyConstraint = (JRLayoutConstraint *)[NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
        dummyConstraint.priority = UILayoutPriorityFittingSizeLevel;
        return dummyConstraint;
    }
    
    return (JRLayoutConstraint *)[NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c];
}

@end
