//
//  ASFilterCellWithOneThumbSlider.m
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import "ASFilterCellWithOneThumbSlider.h"
#import <AviasalesSDK/AviasalesSDK.h>

@implementation ASFilterCellWithOneThumbSlider

- (void)applyPriceString:(NSString *)priceString {
    
    NSString *firstPart = priceString;
    NSString *secondPart = [[AviasalesSDK sharedInstance].currencyCode uppercaseString];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", firstPart, secondPart];
    
    [_cellAttLabel setText:text];
}

- (void)updateSingleSliderWithMinVal:(NSInteger)minVal maxVal:(NSInteger)maxVal val:(NSInteger)val {
    [_cellSlider setMinimumValue:minVal];
    [_cellSlider setMaximumValue:maxVal];
    [_cellSlider setValue:val];
}
@end
