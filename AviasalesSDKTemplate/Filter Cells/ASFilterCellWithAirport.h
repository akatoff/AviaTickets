//
//  ASFilterCellWithAirport.h
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import <UIKit/UIKit.h>

@class ASRaitingStars;

@interface ASFilterCellWithAirport : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellIataLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet ASRaitingStars *cellRaitingStars;

@end
