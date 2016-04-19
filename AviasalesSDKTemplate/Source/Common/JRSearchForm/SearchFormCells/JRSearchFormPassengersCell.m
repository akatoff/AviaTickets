//
//  JRSearchFormPassengersCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 21/01/14.
//
//

#import "JRSearchFormPassengersCell.h"
#import "JRSearchInfoUtils.h"
#import "JRSearchFormPassengerPickerView.h"
#import "JRC.h"
#import "UIImage+ASUIImage.h"
#import "NSLayoutConstraint+JRConstraintMake.h"

@interface JRSearchFormPassengersCell ()

@property (weak, nonatomic) IBOutlet UILabel *passengersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAdultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfChildrenLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfInfantsLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsCollection;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewsCollection;
@property (weak, nonatomic) IBOutlet UIImageView *passengerIcon;
@end


@implementation JRSearchFormPassengersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_passengerIcon setImage:[_passengerIcon.image imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]]];
    [self setAccessibilityLabelWithNSLSKey:@"SF_PASSENGER_CELL"];
}

- (void)updateCell
{    
	[_passengersCountLabel setText:[JRSearchInfoUtils passengersCountStringWithSearchInfo:self.searchInfo]];
	[_numberOfAdultsLabel setText:[NSString stringWithFormat:@"%@", @(self.searchInfo.adults)]];
	[_numberOfChildrenLabel setText:[NSString stringWithFormat:@"%@", @(self.searchInfo.children)]];
	[_numberOfInfantsLabel setText:[NSString stringWithFormat:@"%@", @(self.searchInfo.infants)]];
    
    NSMutableArray *pictures = _imageViewsCollection.mutableCopy;
    [pictures makeObjectsPerformSelector:@selector(setImage:) withObject:nil];
    
    NSMutableArray *labels = _labelsCollection.mutableCopy;
    [labels makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    
    
    if (self.searchInfo.infants > 0) {
        UIImageView *imageView = [pictures firstObject];
        UILabel *label = [labels firstObject];
        [pictures removeObject:imageView];
        [labels removeObject:label];
        [imageView setImage:[[UIImage imageNamed:@"JRSearchFormInfantIcon"] imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]]];
        [label setText:[NSString stringWithFormat:@"%@", @(self.searchInfo.infants)]];
    }
    
    if (self.searchInfo.children > 0) {
        UIImageView *imageView = [pictures firstObject];
        UILabel *label = [labels firstObject];
        [pictures removeObject:imageView];
        [labels removeObject:label];
        [imageView setImage:[[UIImage imageNamed:@"JRSearchFormChildrenIcon"] imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]]];
        [label setText:[NSString stringWithFormat:@"%@", @(self.searchInfo.children)]];
    }
    
    if (labels.count != 3 && self.searchInfo.adults > 0) {
        UIImageView *imageView = [pictures firstObject];
        UILabel *label = [labels firstObject];
        [pictures removeObject:imageView];
        [labels removeObject:label];
        [imageView setImage:[[UIImage imageNamed:@"JRSearchFormAdultIcon"] imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]]];
        [label setText:[NSString stringWithFormat:@"%@", @(self.searchInfo.adults)]];
    }
}

- (void)action {
    [self.item.itemDelegate showPassengerPicker];
}

- (NSString *)accessibilityLabel
{
    return _passengersCountLabel.text;
}

@end
