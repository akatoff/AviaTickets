//
//  ASFilterCellWithView.m
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import "ASFilterCellWithView.h"
#import <AviasalesSDK/AviasalesSDK.h>

@implementation ASFilterCellWithView


- (void)applyPriceString:(NSString *)priceString {
    
    NSString *firstPart = priceString;
    NSString *secondPart = [[AviasalesSDK sharedInstance].currencyCode uppercaseString];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", firstPart, secondPart];
    [_cellAttLabel setText:text];
}

@end
