//
//  ASFilterCellWithView.h
//  aviasales
//
//  Created by Ruslan on 24/12/12.
//
//

#import <UIKit/UIKit.h>

@class ASRaitingStars;

@interface ASFilterCellWithView : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellAttLabel;
@property (weak, nonatomic) IBOutlet ASRaitingStars *cellRatingView;

- (void)applyPriceString:(NSString *)priceString;

@end
