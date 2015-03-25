//
//  ASFilterCellWithTwoThumbsSlider.m
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import "ASFilterCellWithTwoThumbsSlider.h"


@implementation ASFilterCellWithTwoThumbsSlider {
    BOOL _sliderSetup;
}

- (void)setSliderSetup {
    
    _sliderSetup = YES;
    
    UIImage *image = nil;
    
    image = [UIImage imageNamed:@"AviasalesSDKTemplateBundle.bundle/slider-default7-trackBackground"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 3.0)];
    _cellSlider.trackBackgroundImage = image;
    
    image = [UIImage imageNamed:@"AviasalesSDKTemplateBundle.bundle/slider-default7-track"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    _cellSlider.trackImage = image;
    
    image = [UIImage imageNamed:@"AviasalesSDKTemplateBundle.bundle/slider-default7-handle"];
    _cellSlider.lowerHandleImageNormal = image;
    _cellSlider.upperHandleImageNormal = image;
    
    image = [UIImage imageNamed:@"AviasalesSDKTemplateBundle.bundle/slider-default7-handle"];
    _cellSlider.lowerHandleImageHighlighted = image;
    _cellSlider.upperHandleImageHighlighted = image;
}

- (void)updateTwoThumbsSliderWithMinVal:(NSInteger)minVal maxVal:(NSInteger)maxVal uppVal:(NSInteger)uppVal lowVal:
(NSInteger)lowVal text:(NSString *)text {
    if (!_sliderSetup) {
        [self setSliderSetup];
    }
    [_cellSlider setMaximumValue:1];
    [_cellSlider setMinimumValue:0];
    [_cellSlider setUpperValue:1];
    [_cellSlider setLowerValue:0];
    [_cellSlider setMinimumRange:0];
    
    [_cellSlider setMaximumValue:maxVal];
    [_cellSlider setMinimumValue:minVal];
    [_cellSlider setUpperValue:uppVal];
    [_cellSlider setLowerValue:lowVal];
    [_cellAccessoryLabel setText:text];
    [_cellSlider setMinimumRange:(_cellSlider.maximumValue - _cellSlider.minimumValue) / 10];
}

@end
