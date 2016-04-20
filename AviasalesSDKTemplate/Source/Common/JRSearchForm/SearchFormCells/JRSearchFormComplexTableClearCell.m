//
//  JRSearchFormComplexTableClearCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchFormComplexTableClearCell.h"
#import "JRC.h"
#import "UIImage+JRUIImage.h"

#define JRSearchFormComplexTableClearCellMinTravelSegmentsCount 1
#define JRSearchFormComplexTableClearCellMaxTravelSegmentsCount 8
#define JRSearchFormComplexAnimationDuration 0.25


@interface JRSearchFormComplexTableClearCell ()
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@end


@implementation JRSearchFormComplexTableClearCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIEdgeInsets buttonImageInsets = UIEdgeInsetsMake(0, 14, 0, 14);
    [_addButton setTitleColor:[JRC THEME_COLOR] forState:UIControlStateNormal];
    
    [_addButton setBackgroundImage:[[[UIImage imageNamed:@"JRSearchFormAddButton"]
                                    imageTintedWithColor:[JRC THEME_COLOR]]
                                    resizableImageWithCapInsets:buttonImageInsets
                                    resizingMode:UIImageResizingModeStretch]
                          forState:UIControlStateNormal];
    
    [_addButton setBackgroundImage:[[[UIImage imageNamed:@"JRSearchFormAddButtonHi"]
                                    imageTintedWithColor:[JRC THEME_COLOR]]
                                    resizableImageWithCapInsets:buttonImageInsets
                                    resizingMode:UIImageResizingModeStretch]
                          forState:UIControlStateHighlighted];
}

- (void)updateCell
{
    [_addButton setEnabled:self.searchInfo.travelSegments.count < JRSearchFormComplexTableClearCellMaxTravelSegmentsCount];
    
    
    if (self.searchInfo.travelSegments.count >= 3) {
        [_removeButton setEnabled:YES];
    } else if (self.searchInfo.travelSegments.count == 2) {
        JRTravelSegment *secondTravelSegment = (self.searchInfo.travelSegments)[1];
        BOOL shouldEnableButton = secondTravelSegment.originIata || secondTravelSegment.destinationIata || secondTravelSegment.departureDate;
        [_removeButton setEnabled:shouldEnableButton];
    } else {
        [_removeButton setEnabled:NO];
    }
    
}
- (IBAction)addTravelSegment:(id)sender {
    [self.addCellDelegate addTravelSegment];
}

- (IBAction)removeButtonAction:(id)sender
{
	[self.addCellDelegate removeLastSegment];
}

@end
