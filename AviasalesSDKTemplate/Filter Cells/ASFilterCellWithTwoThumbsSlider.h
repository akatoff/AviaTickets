//
//  ASFilterCellWithTwoThumbsSlider.h
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import <UIKit/UIKit.h>

@class NMRangeSlider;

@interface ASFilterCellWithTwoThumbsSlider : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet NMRangeSlider *cellSlider;
@property (weak, nonatomic) IBOutlet UILabel *cellAccessoryLabel;

- (void)setSliderSetup;
- (void)updateTwoThumbsSliderWithMinVal:(NSInteger)minVal maxVal:(NSInteger)maxVal uppVal:(NSInteger)uppVal lowVal:(NSInteger)lowVal text:(NSString *)text;
@end
