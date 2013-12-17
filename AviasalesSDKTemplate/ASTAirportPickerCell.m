//
//  ASTAirportPickerCell.m
//  aviasales
//

#import "ASTAirportPickerCell.h"

@implementation ASTAirportPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [AVIASALES_BUNDLE loadNibNamed:@"ASTAirportPickerCell" owner:self options:nil];
        [self addSubview:_cityLabel];
        [self addSubview:_airportLabel];
        [self addSubview:_iataLabel];
        [self addSubview:_allAirportBadge];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
