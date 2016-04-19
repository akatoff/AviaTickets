//
//  JRSearchFormTravelClassPickerVC.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 24/03/14.
//
//

#import "JRSearchFormTravelClassPickerVC.h"
#import "UIView+FadeAnimation.h"
#import "JRC.h"
#import "UIImage+ASUIImage.h"
#import "JRTableViewCell.h"
#import "JRSearchInfoUtils.h"
#import "JRSearchFormTravelClassPickerCell.h"

#define kJRSearchFormTravelClassPickerWeight 200
#define kJRSearchFormTravelClassPickerCellHeight 44

#define kJRSearchFormTravelClassPickerReloadAnimationDutation 0.2

@interface JRSearchFormTravelClassPickerVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id<JRSearchFormTravelClassPickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;

@property (weak, nonatomic) ASTSearchInfo *searchInfo;

@end

@implementation JRSearchFormTravelClassPickerVC

- (id)initWithDelegate:(id<JRSearchFormTravelClassPickerDelegate>)delegate
            searchInfo:(ASTSearchInfo *)searchInfo {
    self = [super init];
	if (self) {
		_delegate = delegate;
        _searchInfo = searchInfo;
		[self rebuildTable];
	}
	return self;
}

- (void)rebuildTable
{
	_items = [NSMutableArray new];
    [_items addObject:@(JRSDKTravelClassEconomy)];
    [_items addObject:@(JRSDKTravelClassPremiumEconomy)];
    [_items addObject:@(JRSDKTravelClassBusiness)];
    [_items addObject:@(JRSDKTravelClassFirst)];
    [_tableView reloadData];
}

- (void)dealloc {
    [_delegate classPickerDidSelectTravelClass];
}

- (CGSize)contentSize
{
	return CGSizeMake(kJRSearchFormTravelClassPickerWeight, kJRSearchFormTravelClassPickerCellHeight * _items.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JRSDKTravelClass travelClass = [_items[indexPath.row] integerValue];
    NSString *cellIdentifier = @"JRSearchFormTravelClassPickerCell";
    JRSearchFormTravelClassPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = LOAD_VIEW_FROM_NIB_NAMED(cellIdentifier);
        [cell setSearchInfo:_searchInfo];
    }
    [cell.customBackgroundView setBackgroundColor:[JRC CLEAR_COLOR]];
    [cell.customSelectedBackgroundView setBackgroundColor:[[JRC WHITE_COLOR] colorWithAlphaComponent:0.2]];
    [cell setTravelClass:travelClass];
    
    [cell setBottomLineVisible:YES];
    [cell setShowLastLine:NO];
    [cell setBottomLineInsets:UIEdgeInsetsMake(0, 22, 0, 0)];
    [cell setBottomLineColor:[[JRC WHITE_COLOR] colorWithAlphaComponent:0.5]];
    
    [cell updateBackgroundViewsForImagePath:indexPath inTableView:tableView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchInfo setTravelClass:[_items[indexPath.row] integerValue]];
	[_tableView reloadData];
    
	NSTimeInterval duration = kJRSearchFormTravelClassPickerReloadAnimationDutation;
	[UIView addTransitionFadeToView:_tableView duration:duration];
    
	__weak JRSearchFormTravelClassPickerVC *weakSelf = self;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.delegate classPickerDidSelectTravelClass];
    });
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end
