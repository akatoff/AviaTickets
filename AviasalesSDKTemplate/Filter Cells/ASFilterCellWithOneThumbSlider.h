//
//  ASFilterCellWithOneThumbSlider.h
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import <UIKit/UIKit.h>

@interface ASFilterCellWithOneThumbSlider : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellAttLabel;
@property (weak, nonatomic) IBOutlet UISlider *cellSlider;

- (void)applyPriceString:(NSString *)priceString;
- (void)updateSingleSliderWithMinVal:(NSInteger)minVal maxVal:(NSInteger)maxVal val:(NSInteger)val;
@end
