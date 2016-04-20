//
//  JRSearchFormSimpleSearchTableView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchFormSimpleSearchTableView.h"

@interface JRSearchFormSimpleSearchTableView ()<UITableViewDelegate, UITableViewDataSource>
@property (assign, nonatomic) CGSize lastObservedSize;
@property (strong, nonatomic) NSArray *tableViewItems;
@end

@implementation JRSearchFormSimpleSearchTableView

void * JRMainViewFrameChangeContext = &JRMainViewFrameChangeContext;

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setDelegate:self];
	[self setDataSource:self];
    
	[self reloadData];
	_lastObservedSize = CGSizeZero;
	[self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:JRMainViewFrameChangeContext];
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"bounds" context:JRMainViewFrameChangeContext];
}

- (NSArray *)items
{
	return _tableViewItems;
}

- (void)setItems:(NSArray *)items
{
	if ([items isKindOfClass:[NSArray class]]) {
		_tableViewItems = items;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _tableViewItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JRSearchFormItem *item = _tableViewItems[indexPath.row];
	if ([item.itemDelegate respondsToSelector:@selector(tableView:heightForItemWithType:)]) {
		return [item.itemDelegate tableView:tableView heightForItemWithType:item.type];
	} else {
		return 44;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JRSearchFormItem *item = _tableViewItems[indexPath.row];
	NSString *cellIdentifier = item.cellIdentifier;
	JRSearchFormCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = LOAD_VIEW_FROM_NIB_NAMED(cellIdentifier);
	}
	[cell setItem:item];
    [cell updateBackgroundViewsForImagePath:indexPath inTableView:tableView];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[(JRSearchFormCell *)[tableView cellForRowAtIndexPath:indexPath] action];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == JRMainViewFrameChangeContext) {
		CGSize currentSize = self.frame.size;
		if (!CGSizeEqualToSize(currentSize, _lastObservedSize)) {
			[self reloadData];
			_lastObservedSize = currentSize;
		}
        
	}
}

@end
