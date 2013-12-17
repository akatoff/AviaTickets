//
//  ASFilterCellWithMobileSwitch.m
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import "ASFilterCellWithMobileSwitch.h"

@implementation ASFilterCellWithMobileSwitch

- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self setBackgroundColor:[UIColor clearColor]];
        [_cellLabel setText:@"Агентства с мобильным интерфейсом"];
    }
    return self;
}

@end
