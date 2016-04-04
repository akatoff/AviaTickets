//
//  ASTTableManagerUnion.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTTableManagerUnion.h"

@interface ASTTableManagerUnion ()
@property (strong, nonatomic) id<ASTTableManager> first;
@property (strong, nonatomic) id<ASTTableManager> second;
@end

@implementation ASTTableManagerUnion
- (instancetype)initWithFirstManager:(id<ASTTableManager>)firstManager
                       secondManager:(id<ASTTableManager>)secondManager
              secondManagerPositions:(NSIndexSet *)secondManagerPositions {
    if (self = [super init]) {
        _first = firstManager;
        _second = secondManager;
        _secondManagerPositions = secondManagerPositions;
    }
    return self;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.first numberOfSectionsInTableView:tableView] + self.secondManagerPositions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger index = indexPath.section;
    UITableViewCell *result;
    if ([self isSecondTableIndex:index]) {
        NSIndexPath *const pathInSeconTable = [self indexPathFromSecondTableWithIndex:index];
        result = [self.second tableView:tableView cellForRowAtIndexPath:pathInSeconTable];
    } else {
        NSIndexPath *const pathInFirstTable = [self indexPathFromFirstTableWithIndex:index];
        result = [self.first tableView:tableView cellForRowAtIndexPath:pathInFirstTable];
    }
    return result;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger index = indexPath.section;
    if ([self isSecondTableIndex:index]) {
        if ([self.second respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            NSIndexPath *const pathInSeconTable = [self indexPathFromSecondTableWithIndex:index];
            [self.second tableView:tableView didSelectRowAtIndexPath:pathInSeconTable];
        }
    } else {
        if ([self.first respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            NSIndexPath *const pathInFirstTable = [self indexPathFromFirstTableWithIndex:index];
            [self.first tableView:tableView didSelectRowAtIndexPath:pathInFirstTable];
        }
    }
}

#pragma mark - Private
- (BOOL)isSecondTableIndex:(NSInteger)index {
    return [self.secondManagerPositions containsIndex:index];
}

- (NSIndexPath *)indexPathFromSecondTableWithIndex:(NSInteger)index {
    const NSInteger newIndex = [self.secondManagerPositions countOfIndexesInRange:NSMakeRange(0, index)];
    return [NSIndexPath indexPathForRow:0 inSection:newIndex];
}

- (NSIndexPath *)indexPathFromFirstTableWithIndex:(NSInteger)index {
    const NSInteger newIndex = index - [self.secondManagerPositions countOfIndexesInRange:NSMakeRange(0, index)];
    return [NSIndexPath indexPathForRow:0 inSection:newIndex];
}
@end
