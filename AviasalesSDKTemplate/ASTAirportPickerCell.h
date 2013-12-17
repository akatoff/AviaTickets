//
//  ASTAirportPickerCell.h
//  aviasales
//
//  Created by Andrey Zakharevich on 11.12.12.
//
//

#import <UIKit/UIKit.h>

@interface ASTAirportPickerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* cityLabel;
@property (nonatomic, weak) IBOutlet UILabel* airportLabel;
@property (nonatomic, weak) IBOutlet UILabel* iataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *allAirportBadge;

@end
