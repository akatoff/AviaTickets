//
//  JRSearchFormTravelClassAndPassengersCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 21/01/14.
//
//

#import "JRSearchFormTravelClassAndPassengersCell.h"
#import "JRSearchFormSimpleSearchTableView.h"

@interface JRSearchFormTravelClassAndPassengersCell ()
@property (weak, nonatomic) IBOutlet JRSearchFormSimpleSearchTableView *tableView;
@end

@implementation JRSearchFormTravelClassAndPassengersCell

- (void)initialSetup
{
	JRSearchFormItem *passengersItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewPassengersItem itemDelegate:self.item.itemDelegate];
	JRSearchFormItem *travelClassItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewTravelClassItem itemDelegate:self.item.itemDelegate];
	if (iPhone()) {
        [_tableView setItems:@[passengersItem, travelClassItem]];
    } else {
        [_tableView setItems:@[travelClassItem, passengersItem]];
    }
	[_tableView reloadData];
}

- (void)setItem:(JRSearchFormItem *)item
{
	[super setItem:item];
	[self initialSetup];
}

- (void)updateCell
{
	[_tableView reloadData];
}


@end
