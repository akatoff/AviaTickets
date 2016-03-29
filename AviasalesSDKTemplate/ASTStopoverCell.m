//
//  ASTStopoverCell.m
//  AviasalesSDKTemplate
//

#import "ASTStopoverCell.h"

#import <AviasalesSDK/AviasalesSDK.h>

#import "ASTCommonFunctions.h"

@implementation ASTStopoverCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)applyFlight:(AviasalesFlight *)nextFlight {
    
    _duration.text = nextFlight.formattedDelay;
    
    _place.text = [NSString stringWithFormat:@"%@ %@", nextFlight.origin.city, nextFlight.origin.iata];
    
}

@end
