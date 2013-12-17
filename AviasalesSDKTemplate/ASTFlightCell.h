//
//  ASTFlightCell.h
//  AviasalesSDKTemplate
//

#import <UIKit/UIKit.h>

@class AviasalesFlight;

@interface ASTFlightCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *route;
@property (nonatomic, weak) IBOutlet UILabel *duration;
@property (nonatomic, weak) IBOutlet UIImageView *logo;

@property (nonatomic, weak) IBOutlet UILabel *flightNumber;
@property (nonatomic, weak) IBOutlet UILabel *airline;

@property (nonatomic, weak) IBOutlet UILabel *departureTime;
@property (nonatomic, weak) IBOutlet UILabel *arrivalTime;

@property (nonatomic, weak) IBOutlet UILabel *departureDate;
@property (nonatomic, weak) IBOutlet UILabel *arrivalDate;

@property (nonatomic, weak) IBOutlet UILabel *origin;
@property (nonatomic, weak) IBOutlet UILabel *destination;

- (void)applyFlight:(AviasalesFlight *)flight;

@end
