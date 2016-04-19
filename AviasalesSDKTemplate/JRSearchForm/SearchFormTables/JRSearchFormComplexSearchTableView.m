//
//  JRSearchFormComplexSearchTable.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 22/01/14.
//
//

#import "JRSearchFormComplexSearchTableView.h"
#import "JRSearchFormComplexSearchTableHeader.h"
#import "JRSearchFormComplexTableClearCell.h"
#import "JRSearchFormComplexSegmentCell.h"
#import "JRSearchFormTravelClassAndPassengersCell.h"
#import "JRSearchInfo.h"

#define kJRSearchFormSimpleSearchTableViewBottomInset 8
#define kJRSearchFormSimpleSearchTableViewHeightForHeader 30


@interface JRSearchFormSimpleSearchTableView ()
- (JRSearchFormCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface JRSearchFormComplexSearchTableView ()<JRSearchFormComplexTableClearCellDelegate, JRSearchFormComplexSegmentCellDelegate>
@property (strong, nonatomic) JRSearchFormComplexSearchTableHeader *header;
@property (weak, nonatomic) JRSearchFormComplexTableClearCell *addSegmentCell;
@property (weak, nonatomic) JRSearchFormTravelClassAndPassengersCell *travelClassAndPassengersCell;
@end

@implementation JRSearchFormComplexSearchTableView

static void * JRComplexTableContentSizeChangeContext = &JRComplexTableContentSizeChangeContext;

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self updateItems];
	[self reloadData];
	[self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:JRComplexTableContentSizeChangeContext];
    
	[self setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, kJRSearchFormSimpleSearchTableViewBottomInset, 0)];
	[self setContentInset:UIEdgeInsetsMake(0, 0, kJRSearchFormSimpleSearchTableViewBottomInset, 0)];
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"contentSize" context:JRComplexTableContentSizeChangeContext];
}

- (void)updateTravelClassAndPassengersCellSetting
{
	CGFloat contentSizeHeight = 0;
	for (JRSearchFormItem *item in self.items) {
		contentSizeHeight += [item.itemDelegate tableView:self heightForItemWithType:item.type];
	}
	contentSizeHeight += kJRSearchFormSimpleSearchTableViewHeightForHeader;
	CGFloat complexSearchTableFrameHeight = self.frame.size.height;
    
	if (contentSizeHeight > complexSearchTableFrameHeight) {
		if (_travelClassAndPassengers && _travelClassAndPassengersConstraint) {
			[_travelClassAndPassengers.superview removeConstraint:_travelClassAndPassengersConstraint];
            [_travelClassAndPassengers.superview layoutIfNeeded];
		}
		[self setScrollEnabled:YES];
		[_travelClassAndPassengersCell setHidden:NO];
	} else if (contentSizeHeight < complexSearchTableFrameHeight) {
		if (_travelClassAndPassengers && _travelClassAndPassengersConstraint) {
			[_travelClassAndPassengers.superview addConstraint:_travelClassAndPassengersConstraint];
            [_travelClassAndPassengers.superview layoutIfNeeded];
		}
		[self setScrollEnabled:NO];
		[_travelClassAndPassengersCell setHidden:YES];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
	if (context == JRComplexTableContentSizeChangeContext) {
		[self updateTravelClassAndPassengersCellSetting];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)addTravelSegment {
    
    JRSearchInfo *searchInfo = self.itemDelegate.searchInfo;
    while (searchInfo.travelSegments.count <= 1) {
        JRTravelSegment *travelSegment = [JRTravelSegment MR_createInContext:searchInfo.managedObjectContext];
        [searchInfo addTravelSegment:travelSegment];
    }
    
    JRTravelSegment *travelSegment = [JRTravelSegment MR_createInContext:searchInfo.managedObjectContext];
    [searchInfo addTravelSegment:travelSegment];
    
    [self updateItems];
    
    JRSearchFormItem *lastConfigurationItem = nil;
    for (JRSearchFormItem *item in self.items) {
        if (lastConfigurationItem.type == JRSearchFormTableViewComplexSegmentItem &&
            item.type != JRSearchFormTableViewComplexSegmentItem) {
            NSInteger indexOfAddedItem = [self.items indexOfObject:lastConfigurationItem];
            if (indexOfAddedItem != NSNotFound) {
                [self beginUpdates];
                NSIndexPath *indexOfFirstItemToReload = [NSIndexPath indexPathForItem:indexOfAddedItem - 1 inSection:0];
                [self reloadRowsAtIndexPaths:@[indexOfFirstItemToReload] withRowAnimation:UITableViewRowAnimationFade];
                NSIndexPath *indexOfItemToAdd = [NSIndexPath indexPathForItem:indexOfAddedItem inSection:0];
                [self reloadRowsAtIndexPaths:@[indexOfItemToAdd] withRowAnimation:UITableViewRowAnimationFade];
                [self insertRowsAtIndexPaths:@[indexOfItemToAdd] withRowAnimation:UITableViewRowAnimationRight];
                
                [self endUpdates];
            }
            break;
        }
        
        if (item.type == JRSearchFormTableViewComplexSegmentItem) {
            lastConfigurationItem = item;
        }
    }
}

- (void)removeLastSegment
{
	JRSearchInfo *searchInfo = self.itemDelegate.searchInfo;
    [searchInfo removeTravelSegment:searchInfo.travelSegments.lastObject];
    [self updateItems];
    
    JRSearchFormItem *lastConfigurationItem = nil;
    for (JRSearchFormItem *item in self.items) {
        if (lastConfigurationItem.type == JRSearchFormTableViewComplexSegmentItem &&
            item.type != JRSearchFormTableViewComplexSegmentItem) {
            NSInteger indexOfLastItem = [self.items indexOfObject:lastConfigurationItem];
            if (indexOfLastItem != NSNotFound && searchInfo.travelSegments.count > 1) {
                [self beginUpdates];
                
                [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfLastItem  inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfLastItem + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfLastItem + 2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                [self endUpdates];
            } else {
                [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        }
        
        if (item.type == JRSearchFormTableViewComplexSegmentItem) {
            lastConfigurationItem = item;
        }
    }
}

- (void)deleteTravelSegment:(JRTravelSegment *)travelSegmentToDelete {
    [self.itemDelegate.searchInfo removeTravelSegment:travelSegmentToDelete];
    [self reloadData];
}

- (void)reloadData
{
	[self updateItems];
	[super reloadData];
}

- (void)setItemDelegate:(id<JRSearchFormItemDelegate>)itemDelegate
{
	_itemDelegate = itemDelegate;
	[self updateItems];
}

- (void)updateItems
{
	NSMutableArray *items = [[NSMutableArray alloc] init];
    
    JRSearchFormItem *firstComplexConfigurationItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewComplexSegmentItem
                                                                           itemDelegate:_itemDelegate];
    [items addObject:firstComplexConfigurationItem];
    
    JRSearchFormItem *secondComplexConfigurationItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewComplexSegmentItem
                                                                           itemDelegate:_itemDelegate];
    [items addObject:secondComplexConfigurationItem];
    
	
    [self.itemDelegate.searchInfo.travelSegments enumerateObjectsUsingBlock:^(JRTravelSegment *obj, NSUInteger idx, BOOL *stop) {
        
        if (idx > 1) {
            JRSearchFormItem *complexConfigurationItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewComplexSegmentItem
                                                                                   itemDelegate:_itemDelegate];
            [items addObject:complexConfigurationItem];
        }
        
    }];
    
	JRSearchFormItem *complexAddConfigurationItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewComplexAddSegmentItem itemDelegate:_itemDelegate];
	[items addObject:complexAddConfigurationItem];
	JRSearchFormItem *travelClassAndPassengersItem = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewItemTravelClassAndPassengersType itemDelegate:_itemDelegate];
	[items addObject:travelClassAndPassengersItem];
	[self setItems:items];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if ([cell isKindOfClass:[JRSearchFormComplexTableClearCell class]]) {
		_addSegmentCell = cell;
		[_addSegmentCell setAddCellDelegate:self];
	}
    if ([cell isKindOfClass:[JRSearchFormComplexSegmentCell class]]) {
        JRSearchFormComplexSegmentCell *segmentCell = cell;
		[segmentCell setSegmentCellDelegate:self];
	}
    
	if ([cell isKindOfClass:[JRSearchFormComplexSegmentCell class]]) {
		JRSearchInfo *searchInfo = self.itemDelegate.searchInfo;
		JRTravelSegment *travelSegment = nil;
        if (searchInfo.travelSegments.count > indexPath.row) {
            travelSegment = (searchInfo.travelSegments)[indexPath.row];
        }
		[cell setTravelSegment:travelSegment];
	} else if ([cell isKindOfClass:[JRSearchFormTravelClassAndPassengersCell class]]) {
		_travelClassAndPassengersCell = (JRSearchFormTravelClassAndPassengersCell *)cell;
		BOOL shouldHideCell = !self.scrollEnabled;
		[cell setHidden:shouldHideCell];
	}
	[cell setAlpha:1];
    [cell updateBackgroundViewsForImagePath:indexPath inTableView:tableView];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kJRSearchFormSimpleSearchTableViewHeightForHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (!_header) {
		NSString *headerIdentifier = @"JRSearchFormComplexSearchTableHeader";
		_header = LOAD_VIEW_FROM_NIB_NAMED(headerIdentifier);
	}
	return _header;
}

@end
