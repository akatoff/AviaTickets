//
//  JRSearchFormAirportsCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 20/01/14.
//
//

#import "JRSearchFormAirportsCell.h"
#import "JRSearchFormSimpleSearchTableView.h"
#import "JRLineViewWithPattern.h"
#import "JRC.h"
#import "UIImage+ASUIImage.h"
#import "UIView+FadeAnimation.h"
#import "NSObject+Accessibility.h"

#define JRSearchFormAirportsCellAnimationDuration 0.3

@interface JRSearchFormAirportsCell ()
@property (weak, nonatomic) IBOutlet JRSearchFormSimpleSearchTableView *tableView;
@property (weak, nonatomic) IBOutlet JRLineViewWithPattern *verticalLine;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@end

@implementation JRSearchFormAirportsCell

- (void)setupPatternedLine
{
	UIImage *verticalLinePattern = [[UIImage imageNamed:@"JRVerticalLineSemiTransparentPattern"] imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]];
	verticalLinePattern = [verticalLinePattern imageTintedWithColor:[JRC THEME_COLOR]];
	[_verticalLine setPatternImage:verticalLinePattern];
}

- (void)setupChangeButton
{
	UIImage *changeButtonImage = [[_changeButton imageForState:UIControlStateNormal] imageTintedWithColor:[JRC THEME_COLOR] fraction:0.1];
	[_changeButton setImage:changeButtonImage forState:UIControlStateHighlighted];
    [_changeButton setAccessibilityLabelWithNSLSKey:@"JR_SEARCH_FORM_CHANGE_BTN_TITLE_ACC"];
	[UIView animateWithDuration:JRSearchFormAirportsCellAnimationDuration
                          delay:kNilOptions
                        options:UIViewAnimationOptionOverrideInheritedOptions
                     animations:^{
                         CGFloat alpha = [self changeButtonIsAvalible] ? 1 : 0;
                         [_changeButton setAlpha:alpha];
                     } completion:NULL];
}

- (void)initialSetup
{
	JRSearchFormItem *originItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewOriginAirportItem itemDelegate:self.item.itemDelegate];
	JRSearchFormItem *destinationItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewDestinationAirportItem itemDelegate:self.item.itemDelegate];
	[_tableView setItems:@[originItem, destinationItem]];
	[_tableView reloadData];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setupPatternedLine];
	[self setupChangeButton];
    [_changeButton setImage:[[_changeButton imageForState:UIControlStateNormal] imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]]
                   forState:UIControlStateNormal];
}

- (void)updateCell
{
	[self setupChangeButton];
	[_tableView reloadData];
}

- (void)setItem:(JRSearchFormItem *)item
{
	[super setItem:item];
	[self initialSetup];
}

- (IBAction)chageAction:(UIButton *)sender
{
	ASTTravelSegment *travelSegment = self.searchInfo.travelSegments.firstObject;
	NSString *originIata = travelSegment.originIata;
	travelSegment.originIata = travelSegment.destinationIata;
	travelSegment.destinationIata = originIata;
	[self updateCell];
	[UIView addTransitionFadeToView:self duration:JRSearchFormAirportsCellAnimationDuration];
}

- (BOOL)changeButtonIsAvalible
{
	ASTTravelSegment *travelSegment = self.searchInfo.travelSegments.firstObject;
	if ((travelSegment.originIata || travelSegment.destinationIata) &&
	    ![travelSegment.originIata isEqualToString:travelSegment.destinationIata]) {
		return YES;
	} else {
		return NO;
	}
}

@end
